# AVOS Shipping Service

The Shipping Service calculates deterministic delivery estimates from cart quantities and simulates shipment creation by returning an AVOS tracking ID over gRPC.

## Role and connections

| Component | Role |
|---|---|
| Frontend | Requests a cart shipping estimate over gRPC. |
| Checkout Service | Requests the final quote and creates a simulated shipment over gRPC. |
| Shipping Service | Validates cart and address data, calculates USD shipping, and returns tracking IDs. |
| Currency Service | Converts the returned USD quote when the customer selects another currency. |
| OpenTelemetry Collector | Receives Shipping Service traces through OTLP. |

## Baseline quote model

For a non-empty cart, the Phase 1 simulation uses `$4.99 + ($1.25 × total quantity)`. Empty carts return `$0.00`, and a single shipment is limited to 1,000 items. This rule is centralized in `quote.go` so a future carrier integration can replace it cleanly.

## Configuration

| Variable | Default | Purpose |
|---|---|---|
| `PORT` | `50051` | Sets the gRPC listening port. |
| `ENABLE_OTEL` | `true` | Enables OTLP tracing unless set to `false`. |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | SDK default | Selects the OpenTelemetry Collector endpoint. |
| `OTEL_EXPORTER_OTLP_INSECURE` | unset | Enables an insecure local OTLP connection when configured by the SDK. |
| `ENABLE_GRPC_REFLECTION` | `false` | Enables gRPC reflection only when explicitly requested. |

## Local validation

```bash
go mod tidy
go test ./...
go build ./...
docker build -t avos/shippingservice:phase-1 .
```

## Security and reliability behavior

- Address and product data are validated before shipment creation.
- Customer addresses are never written to application logs.
- Tracking IDs use `crypto/rand` and contain no address-derived information.
- Money calculations use integer cents rather than floating-point arithmetic.
- Kubernetes health checks use the standard gRPC health service.
- OpenTelemetry provides gRPC tracing to the AVOS Collector.
- SIGTERM and SIGINT trigger graceful shutdown and telemetry flushing.
- The final container is a minimal non-root distroless image.

This service remains a fulfillment simulation. A production implementation would integrate authenticated carrier APIs and persist shipment state outside the service.
