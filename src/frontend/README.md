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

Set `ENV_PLATFORM=aws` in Amazon EKS. The deployment can also supply `CLUSTER_NAME`, `AWS_REGION`, and `POD_NAME` for the diagnostic footer.

## Optional settings

```text
ENABLE_ASSISTANT=true
ENABLE_TRACING=1
COLLECTOR_SERVICE_ADDR=otel-collector:4317
FRONTEND_MESSAGE=Welcome to AVOS
BASE_URL=
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
