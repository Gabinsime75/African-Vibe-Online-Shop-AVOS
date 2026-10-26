# AVOS Trace Context Propagation

## Purpose and scope

Preserve W3C `traceparent`, `tracestate`, and `baggage` across the external
HTTP entry point and internal gRPC calls. A request must retain its trace ID
across service boundaries; recording services create child spans. Missing or
invalid trace headers must not reuse the context of an earlier request.

Context propagation is separate from span export. Development currently disables
collector export. Existing trace context must still cross service boundaries.
With a non-recording provider, a service can forward the remote parent without
creating a recorded child span. Recording/export requires the SDK configuration
and collector integration validated in Phase 10.

This change does not install a collector, create observability infrastructure,
or claim that a complete customer trace is already visible in a trace backend.

## Service coverage

| Service | Transport instrumentation | Implementation |
|---|---|---|
| frontend | OpenTelemetry HTTP handler and gRPC client stats handlers | Preserve request context; name exported spans `frontend`; honor parent sampling |
| checkoutservice | gRPC server and client stats handlers | Initialize W3C propagators before the export flag; retain request-context forwarding |
| productcatalogservice | gRPC server stats handler | Name exported spans `productcatalogservice`; honor parent sampling |
| shippingservice | gRPC server stats handler | Existing W3C propagation retained |
| cartservice | ASP.NET Core W3C request activities and OpenTelemetry instrumentation | Existing inbound propagation retained; no outbound business RPCs |
| currencyservice | grpc-js instrumentation | Initialize propagation even when `ENABLE_OTEL=false` |
| paymentservice | grpc-js instrumentation | Initialize propagation even when `ENABLE_OTEL=false` |
| emailservice | Python gRPC server instrumentation | Initialize extraction even when `ENABLE_OTEL=false` |
| recommendationservice | Python gRPC server and client instrumentation | Extract and forward context even when `ENABLE_TRACING=0` |
| adservice | OpenTelemetry Java gRPC server interceptor | Replace placeholder tracing; support propagation with export disabled |
| shoppingassistantservice | W3C extraction and scoped server span | Extract inbound metadata, scope context to the request, and detach on every exit |

The suspended load generator is a supporting HTTP client. It does not need a
service-side gRPC interceptor. Trace headers can be supplied during controlled
tests; no load-generator activation is included here.

## Export configuration

Existing development export flags remain unchanged. Enabling export requires a
reachable approved collector and network policy permitting the telemetry path.

| Services | Export control |
|---|---|
| frontend, productcatalogservice, recommendationservice, shoppingassistantservice | `ENABLE_TRACING=1` |
| cartservice, checkoutservice, shippingservice, currencyservice, paymentservice, emailservice | `ENABLE_OTEL=true` |
| adservice | Remove `DISABLE_TRACING`; configure OTLP endpoint before enabling export |

Frontend and product catalog currently use `COLLECTOR_SERVICE_ADDR` for their
gRPC exporter connection. Other services use their SDK's OTLP environment
configuration. Do not enable export by assuming a collector exists.

Adservice pins OpenTelemetry SDK 1.67.0 and gRPC instrumentation 2.33.0-alpha,
which declares API 1.67.0 compatibility. The alpha suffix is the upstream
instrumentation artifact's published version, not an unpinned dependency.
Its SDK closes after the gRPC shutdown drain rather than in a competing SDK
shutdown hook.

## Request handling rules

- Forward the active request context on outbound gRPC calls.
- Preserve trace identity and incoming sampling decisions; export-off mode does
  not provide a complete set of recorded spans.
- Use W3C propagation at the application boundary. Istio transport telemetry does
  not replace application context forwarding.
- Do not put credentials, cookies, payment details, customer identifiers, prompts,
  or image content in baggage or span attributes. Baggage is distributed metadata,
  not a secret store or an authorization mechanism.
- Limit attributes to operational metadata. Do not enable request/response payload
  capture or arbitrary gRPC metadata capture.
- Reject invalid trace context as a parent and start from a clean request context.
  Explicitly scoped context must be detached on success and failure.

## Validation

The patch adds transport-level tests using local servers, fake dependencies, and
in-memory telemetry. These tests require neither AWS calls nor a collector.

- Go: HTTP-to-gRPC trace ID, tracestate, baggage, sampled/unsampled parents, and
  missing/invalid-header isolation; run with the race detector.
- Node.js: real inbound grpc-js requests preserve W3C context with export disabled;
  a subsequent request does not inherit the previous trace or baggage.
- Python recommendation: real recommendation-to-catalog RPCs forward context with
  export disabled and isolate the following request.
- Python email: real inbound gRPC extraction works with export disabled.
- Python assistant: real gRPC requests produce correctly parented server spans;
  missing/invalid headers do not inherit prior context.
- Java: a local gRPC server verifies the remote parent and a fresh request using
  an in-memory span exporter. The full Java build and test suite must pass CI.

Deployment validation must verify promoted runtime artifacts. A complete
cross-language customer trace, collector delivery, sampling configuration, and
backend visibility remain Phase 10 / end-to-end validation evidence. Assistant
live deployment remains dependent on its approved AWS integrations.
