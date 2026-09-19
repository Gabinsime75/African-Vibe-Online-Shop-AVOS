# AVOS Cart Service

The Cart Service manages each AVOS customer session's cart and persists production cart state in Amazon ElastiCache for Redis.

## Architecture role

| Component | Role |
| --- | --- |
| gRPC API | Receives cart reads, additions, and empty-cart requests from AVOS services. |
| Redis hash | Stores each cart by user ID and updates item quantities atomically. |
| Amazon ElastiCache | Provides the managed production Redis datastore shown in the AVOS architecture. |
| In-memory store | Supports isolated local development and automated tests only. |
| gRPC health service | Reports whether the configured cart store can serve requests. |
| OpenTelemetry | Exports service traces and runtime/application metrics to the AVOS observability pipeline. |

The protobuf package remains `hipstershop` temporarily so the updated Cart Service stays compatible with the shared contracts and existing AVOS clients. This is an internal compatibility identifier, not a customer-visible brand.

## Configuration

| Variable | Required | Default | Role |
| --- | --- | --- | --- |
| `CART_STORE` | Production | `redis` outside Development/Testing | Selects `redis` or the local-only `memory` store. |
| `REDIS_ADDR` | With Redis | — | Supplies the ElastiCache/Redis endpoint and port. |
| `REDIS_TLS` | No | `true` outside Development | Encrypts the Redis connection when the target supports in-transit encryption. |
| `REDIS_USERNAME` | No | — | Supplies an optional Redis ACL user. |
| `REDIS_PASSWORD` | No | — | Supplies an optional Redis authentication token through a secret at runtime. |
| `REDIS_KEY_PREFIX` | No | `avos:cart` | Namespaces AVOS cart keys in Redis. |
| `CART_TTL_HOURS` | No | `168` | Expires inactive carts after seven days. |
| `ENABLE_OTEL` | No | `true` | Enables OpenTelemetry metrics and traces. |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | With collector | SDK default | Points telemetry to the OpenTelemetry Collector. |

Do not commit Redis passwords. Kubernetes External Secrets will inject credentials from AWS Secrets Manager during the infrastructure phase.

## Local validation

From `src/cartservice`:

```bash
dotnet restore cartservice.sln
dotnet test tests/cartservice.tests.csproj --no-restore
dotnet build src/cartservice.csproj --configuration Release --no-restore
docker build -t avos/cartservice:phase-1 ./src
```

Run locally without Redis:

```bash
ASPNETCORE_ENVIRONMENT=Development \
CART_STORE=memory \
ENABLE_OTEL=false \
dotnet run --project src/cartservice.csproj
```

The service listens on gRPC port `7070`.
