# AVOS Currency Service

The Currency Service converts AVOS monetary values between supported currencies over gRPC. It is designed for high request volume: the exchange-rate snapshot is validated and cached once at startup, and each conversion uses exact integer nano-unit arithmetic.

## Role and connections

| Component | Role |
|---|---|
| Frontend | Requests display-price conversions over gRPC. |
| Checkout Service | Converts product and shipping totals during checkout over gRPC. |
| Currency Service | Validates money values and performs deterministic conversions. |
| OpenTelemetry Collector | Receives traces through OTLP when telemetry is enabled. |
| `data/currency_conversion.json` | Supplies a version-controlled rate snapshot for local and baseline environments. |

The rate file is intentionally not fetched during requests. A later platform phase can refresh a versioned rate snapshot using EventBridge and Lambda, then deploy it through the approved GitOps workflow.

## Configuration

| Variable | Default | Purpose |
|---|---|---|
| `PORT` | `7000` | Sets the gRPC listening port. |
| `CURRENCY_DATA_PATH` | `data/currency_conversion.json` | Selects the exchange-rate snapshot loaded at startup. |
| `ENABLE_OTEL` | `true` | Enables OpenTelemetry unless set to `false`. |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | SDK default | Selects the OTLP gRPC collector endpoint. |
| `OTEL_EXPORTER_OTLP_INSECURE` | unset | Uses an insecure local OTLP connection when set to `true`. |

## Local validation

```bash
npm ci
npm run check
npm test
docker build -t avos/currencyservice:phase-1 .
```

Run the service with `npm start`. Run the sample client with `npm run client`; override `CURRENCY_SERVICE_ADDR` when the server is not at `localhost:7000`.

## Reliability and security behavior

- Exact `BigInt` nano-unit arithmetic prevents binary floating-point money errors.
- Invalid codes, malformed amounts, incompatible signs, and overflow are rejected.
- The standard gRPC health service reports `SERVING`.
- The container uses a pinned Node 24 image and runs as the non-root `node` user.
- SIGTERM and SIGINT drain gRPC requests and flush telemetry before exit.
