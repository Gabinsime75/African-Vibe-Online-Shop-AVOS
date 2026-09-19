# AVOS Recommendation Service

The AVOS Recommendation Service returns product candidates that are not already associated with the current shopping request. It is a stateless Python gRPC service and retrieves the available product IDs from Product Catalog Service.

## Role in AVOS

| Item | Role |
| --- | --- |
| Recommendation gRPC API | Returns up to five catalog products not included in the request. |
| Product Catalog client | Retrieves the current AVOS product inventory over gRPC. |
| gRPC health service | Reports Kubernetes and service-mesh readiness. |
| OpenTelemetry | Exports traces to the AVOS collector when enabled. |
| Structured logs | Writes JSON to standard output for Fluent Bit collection. |

AI-assisted conversational personalization remains the responsibility of `shoppingassistantservice`.

## Runtime configuration

| Variable | Default | Role |
| --- | --- | --- |
| `PRODUCT_CATALOG_SERVICE_ADDR` | Required | Sets the Product Catalog gRPC address. |
| `PORT` | `8080` | Sets the Recommendation Service gRPC port. |
| `MAX_WORKERS` | `10` | Controls the gRPC worker-thread pool. |
| `MAX_RECOMMENDATIONS` | `5` | Limits recommendations returned per request. |
| `CATALOG_TIMEOUT_SECONDS` | `3` | Limits each Product Catalog request. |
| `SHUTDOWN_GRACE_SECONDS` | `5` | Allows active requests to finish during shutdown. |
| `ENABLE_TRACING` | `0` | Enables OTLP tracing when set to `1`. |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | SDK default | Selects the OpenTelemetry Collector endpoint. |

## Validate locally

```bash
python -m venv .venv
source .venv/Scripts/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python -m unittest discover -p "test_*.py" -v
python -m compileall -q .
docker build -t avos/recommendationservice:phase-1 .
```

## Compatibility note

The generated protobuf modules retain the `hipstershop` namespace during Phase 1. AVOS will migrate the shared gRPC contract across every implementation language in one coordinated phase.
