# AVOS Email Service

The Email Service validates an order-confirmation request, renders an AVOS-branded HTML message, and simulates successful delivery over gRPC. It does not contact an external email provider during Phase 1.

## Role and connections

| Component | Role |
|---|---|
| Checkout Service | Sends the customer email and completed order over internal gRPC. |
| Email Service | Validates the request and renders the order-confirmation template. |
| OpenTelemetry Collector | Receives gRPC traces through OTLP when telemetry is enabled. |
| gRPC health service | Reports readiness and serving state to Kubernetes. |

## Configuration

| Variable | Default | Purpose |
|---|---|---|
| `PORT` | `8080` | Sets the gRPC listening port. |
| `ENABLE_OTEL` | `true` | Enables OpenTelemetry unless set to `false`. |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | SDK default | Selects the OpenTelemetry Collector endpoint. |
| `OTEL_EXPORTER_OTLP_INSECURE` | unset | Configures an insecure local OTLP connection when required. |
| `EMAIL_SERVICE_ADDR` | `localhost:8080` | Selects the server used by `email_client.py`. |

## Local validation on Git Bash

```bash
python -m venv .venv
source .venv/Scripts/activate
python -m pip install -r requirements.txt
python -m compileall -q .
python -m unittest discover -s test -p "test_*.py" -v
docker build -t avos/emailservice:phase-1 .
```

## Security and reliability behavior

- Customer email and postal addresses are never written to logs.
- The email address and required order fields are validated before rendering.
- Jinja autoescaping and strict undefined values reduce unsafe or incomplete output.
- The HTML template uses inline AVOS styling and makes no third-party font requests.
- The standard gRPC health service reports serving state.
- OpenTelemetry instruments inbound gRPC requests.
- SIGTERM and SIGINT initiate graceful shutdown and telemetry flushing.
- The final container runs as the non-root `avos` user.

## Production boundary

This remains a delivery simulation. A production implementation should send through Amazon SES using EKS Pod Identity, verify sender identities, handle bounces and complaints through SNS, apply rate limits, and store only delivery metadata—not rendered customer messages.
