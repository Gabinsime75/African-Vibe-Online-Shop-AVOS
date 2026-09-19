# AVOS Payment Service

The Payment Service simulates card authorization during AVOS checkout and returns a unique transaction ID over gRPC. It does not contact a bank, capture funds, or store payment-card data.

## Role and connections

| Component | Role |
|---|---|
| Checkout Service | Sends the order amount and temporary card information over internal gRPC. |
| Payment Service | Validates the request, simulates authorization, and returns a transaction ID. |
| OpenTelemetry Collector | Receives gRPC traces through OTLP when telemetry is enabled. |
| gRPC health service | Reports `SERVING` for Kubernetes health checks. |

## Configuration

| Variable | Default | Purpose |
|---|---|---|
| `PORT` | `50051` | Sets the gRPC listening port. |
| `ENABLE_OTEL` | `true` | Enables OpenTelemetry unless set to `false`. |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | SDK default | Selects the OTLP gRPC collector endpoint. |
| `OTEL_EXPORTER_OTLP_INSECURE` | unset | Uses an insecure local OTLP connection when set to `true`. |

## Local validation

```bash
npm ci
npm run check
npm test
docker build -t avos/paymentservice:phase-1 .
```

Run the service with `npm start`.

## Security and reliability behavior

- Full card numbers and CVVs are never included in application logs or responses.
- Pino redaction provides an additional safeguard for known payment-field names.
- Card numbers must pass format, accepted-network, and Luhn checksum validation.
- Expiration, CVV, currency, Money signs, positive amount, and charge limit are validated.
- Transaction IDs use Node.js `crypto.randomUUID()`.
- The container uses Node 24 and runs as the non-root `node` user.
- SIGTERM and SIGINT drain gRPC requests and flush telemetry before exit.

## Production boundary

This remains a portfolio-safe payment simulation. A production payment integration would use a PCI-compliant provider, tokenized payment methods, an idempotency key in the protobuf contract, durable transaction state, fraud controls, and provider webhooks. AVOS must never store raw card numbers or CVVs.
