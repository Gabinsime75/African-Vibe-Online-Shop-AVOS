# AVOS Service Lifecycle

## Health and readiness

The HTTP frontend uses /_healthz. Business gRPC servers expose the standard
Health/Check API. The load generator is a bounded test client, not a server.

Cart uses named readiness and liveness checks. Readiness requires its store;
liveness checks the running process without probing Redis. Startup uses
liveness so Redis unavailability does not restart an otherwise healthy process.
The empty service name retains dependency-aware overall health.
Unknown cart health service names return NOT_FOUND.

Other existing probes remain unchanged. Their current health checks must not
be described as end-to-end dependency or AWS model-access validation.

## Shutdown behavior

On SIGTERM or SIGINT, stop admitting requests and allow active requests to
finish within a bounded grace period. Force closure after that period.
Do not use the signal context as the parent of active HTTP request contexts.

| Service | Lifecycle behavior |
|---|---|
| frontend | Withdraw health; drain HTTP for up to 25 seconds; close downstream connections |
| cartservice | ASP.NET Core graceful hosting; 20-second shutdown timeout; stopping health is NOT_SERVING |
| productcatalogservice | Publish NOT_SERVING; drain gRPC for 10 seconds; force stop on expiry |
| adservice | Enter terminal health state; await shutdown for 10 seconds; force shutdown if needed |
| recommendationservice | Handle SIGTERM/SIGINT; publish NOT_SERVING; use configured drain, default 5 seconds |
| shoppingassistantservice | Enter terminal health state before a 10-second gRPC drain; wait for completion |
| checkoutservice | Existing NOT_SERVING transition and bounded 10-second gRPC drain |
| shippingservice | Existing NOT_SERVING transition and bounded 10-second gRPC drain |
| currencyservice | Existing tryShutdown with a 10-second force-stop timer |
| paymentservice | Existing tryShutdown with a 10-second force-stop timer |
| emailservice | Existing signal handling, NOT_SERVING transition, and 10-second drain |

Deployed workload manifests currently allow 30 seconds for termination.
Keep drain, cleanup, telemetry flush, and any future preStop hook within that
shared budget. Configure recommendation shutdown grace below the Pod budget.
Readiness withdrawal does not roll back already completed business operations.

## Verification and rollout

Tests cover HTTP drain completion and forced closure, gRPC drain completion
and forced closure, cart readiness during store failure, cart stopping health,
assistant shutdown ordering, and recommendation process exit after SIGTERM.
Use simulated dependencies; these tests require no live AWS resources.

Source changes require successful CI, image publication, and reviewed Git image
promotion before their lifecycle behavior is active in EKS.
The cart probe names are compatible with the prior handler, which ignored
service names; dependency-independent liveness requires the new application image.

After promotion, verify health, fresh Argo CD reconciliation, actual runtime
images, and a controlled rolling replacement. Keep the load generator suspended
except during an approved bounded verification window.

Shoppingassistantservice live readiness remains pending its infrastructure
and GitOps deployment. This source change does not close the Phase 9 live gate.
