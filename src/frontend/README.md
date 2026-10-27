# AVOS Frontend

The AVOS frontend is the customer-facing Go service. It serves the web interface, creates anonymous shopping sessions, and communicates with backend services through gRPC.

## Responsibilities

| Capability | Role |
|---|---|
| Storefront UI | Displays AVOS products, recommendations, promotions, cart, and checkout pages. |
| Session management | Creates an anonymous session ID without requiring customer registration. |
| gRPC orchestration | Calls the catalog, cart, currency, recommendation, checkout, shipping, and advertisement services. |
| Shopping assistant | Sends customer prompts to the optional AVOS shopping-assistant service. |
| OpenTelemetry | Exports frontend traces to the configured OpenTelemetry Collector. |

## Required environment variables

```text
PRODUCT_CATALOG_SERVICE_ADDR
CURRENCY_SERVICE_ADDR
CART_SERVICE_ADDR
RECOMMENDATION_SERVICE_ADDR
CHECKOUT_SERVICE_ADDR
SHIPPING_SERVICE_ADDR
AD_SERVICE_ADDR
SHOPPING_ASSISTANT_SERVICE_ADDR
```

Deployment metadata (`CLUSTER_NAME`, `AWS_REGION`, and `POD_NAME`) is available in startup logs. Customer pages do not display infrastructure or session identifiers.

## Optional settings

```text
ENABLE_ASSISTANT=true
ENABLE_TRACING=1
COLLECTOR_SERVICE_ADDR=otel-collector:4317
FRONTEND_MESSAGE=Welcome to AVOS
BASE_URL=
SESSION_COOKIE_SECURE=false
PORT=8080
LISTEN_ADDR=0.0.0.0
```

## Validate locally

```bash
go mod tidy
go test ./...
go build ./...
```

## Build the container

```bash
docker build -t avos/frontend:local .
```

## Storefront identity and sessions

The AVOS logo, favicon, palette, product catalog, and images are versioned repository
assets. Product IDs and protobuf packages remain stable for existing clients.
ZAR is selectable alongside the existing currencies; conversion uses the existing
catalog of demonstration rates.

`BASE_URL` accepts an empty value or a local path prefix such as `/shop`.
Routes, image links, CSS backgrounds, cookie paths, and redirects honor that
prefix. External URLs, dot segments, and query strings are rejected at startup.

Each visitor receives a random UUIDv4 `avos_session-id`. Existing valid AVOS
sessions are retained; malformed and former shared-session IDs are replaced.
Cookies are host-only, HttpOnly, SameSite=Lax, and scoped to the storefront path.
They are renewed for the existing 48-hour lifetime. Set
`SESSION_COOKIE_SECURE=true` when the public endpoint is HTTPS. Direct TLS and
HTTPS identified by the approved ingress proxy also enable Secure cookies.
The deployment must trust forwarded headers only from its approved ingress path.
HTTP development remains supported; cookie flags do not turn HTTP into HTTPS.

The old shared-session setting is no longer supported. Sessions identify
anonymous carts, not authenticated customer accounts. Logout clears only AVOS
cookies. The demonstration cart currently uses in-memory storage; managed cart
persistence is a separate Phase 9.6 deliverable.

Checkout uses sample details and a simulated payment card. Public pages explicitly
state that payment, confirmation, and fulfillment are simulated. Request errors
retain server-side diagnostics and show a customer-facing status and support
reference instead of backend exceptions.
