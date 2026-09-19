# AVOS Checkout Service

The Checkout Service orchestrates the AVOS purchase workflow across the Cart, Product Catalog, Currency, Payment, Shipping, and Email services.

## Architecture role

| Component | Role |
| --- | --- |
| Checkout gRPC API | Receives validated order-placement requests from the AVOS frontend. |
| Cart Service | Supplies the customer's cart and clears it after a completed order. |
| Product Catalog Service | Supplies the current price for every cart item. |
| Currency Service | Converts product and shipping prices into the customer's selected currency. |
| Payment Service | Processes the simulated charge and returns a transaction ID. |
| Shipping Service | Calculates shipping cost and creates shipment tracking information. |
| Email Service | Sends a best-effort order confirmation after checkout succeeds. |
| OpenTelemetry | Exports distributed traces through the AVOS OpenTelemetry Collector. |

The protobuf package remains `hipstershop` temporarily because it is the shared internal wire contract used by the imported services. Customer-visible names and the Go module identity are AVOS.

## Checkout flow

1. Validate the customer, currency, address, email, and payment fields.
2. Retrieve the customer's cart from Cart Service.
3. Retrieve product prices and convert them into the requested currency.
4. Retrieve and convert the shipping quote.
5. Calculate the complete order total.
6. Charge the payment through Payment Service.
7. Create the shipment through Shipping Service.
8. Clear the cart and request a confirmation email without reversing a completed order if either best-effort action fails.

Payment and shipment are non-idempotent operations, so the service does not automatically retry them. A future order-persistence phase should add an order ledger, idempotency keys, and compensation workflow before AVOS handles real payments.

## Configuration

| Variable | Required | Default | Role |
| --- | --- | --- | --- |
| `PRODUCT_CATALOG_SERVICE_ADDR` | Yes | — | Locates Product Catalog Service over gRPC. |
| `CART_SERVICE_ADDR` | Yes | — | Locates Cart Service over gRPC. |
| `CURRENCY_SERVICE_ADDR` | Yes | — | Locates Currency Service over gRPC. |
| `SHIPPING_SERVICE_ADDR` | Yes | — | Locates Shipping Service over gRPC. |
| `PAYMENT_SERVICE_ADDR` | Yes | — | Locates Payment Service over gRPC. |
| `EMAIL_SERVICE_ADDR` | Yes | — | Locates Email Service over gRPC. |
| `PORT` | No | `5050` | Selects the Checkout Service listening port. |
| `DOWNSTREAM_TIMEOUT` | No | `3s` | Limits each downstream gRPC call. |
| `CHECKOUT_TIMEOUT` | No | `20s` | Limits the complete checkout workflow. |
| `ENABLE_OTEL` | No | `true` | Enables OpenTelemetry trace export. |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | With collector | SDK default | Locates the AVOS OpenTelemetry Collector. |
| `OTEL_EXPORTER_OTLP_INSECURE` | In-mesh collector | — | Allows plaintext OTLP inside the Istio-protected cluster network. |

Application gRPC connections use plaintext because Istio supplies service-to-service mTLS at the mesh layer.

## Validate locally

From `src/checkoutservice`:

```bash
go mod tidy
go test ./...
go vet ./...
go build ./...
docker build -t avos/checkoutservice:phase-1 .
```

The service requires its six downstream addresses before it can start.
