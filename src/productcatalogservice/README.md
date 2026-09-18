# AVOS Product Catalog Service

The product catalog service owns the AVOS product collection and exposes product listing, lookup, and search operations through gRPC.

## Responsibilities

| Capability | Role |
|---|---|
| Product listing | Returns the complete AVOS product collection. |
| Product lookup | Retrieves one product by its stable product ID. |
| Product search | Searches product names and descriptions. |
| Local catalog | Loads `products.json` for development and initial deployment. |
| Aurora integration | Loads products from Aurora PostgreSQL when `DATABASE_URL` is configured. |
| OpenTelemetry | Exports distributed traces to the configured collector. |

The catalog is loaded during service startup. GitOps rolls the deployment when catalog configuration changes, avoiding platform-specific process signals and per-request file reloads.

## Catalog source

The service uses `products.json` by default. In EKS, configure Aurora using a connection string injected by External Secrets:

```text
DATABASE_URL=postgres://avos_user:password@avos-cluster.example:5432/avos?sslmode=require
PRODUCTS_TABLE=products
```

`DATABASE_URL` must come from an external Kubernetes Secret and must never be committed to Git.

The Aurora table must expose these columns:

```sql
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  picture TEXT NOT NULL,
  price_usd_currency_code TEXT NOT NULL,
  price_usd_units BIGINT NOT NULL,
  price_usd_nanos INTEGER NOT NULL,
  categories TEXT NOT NULL
);
```

Store categories as a comma-separated value such as `clothing,menswear`.

## Optional settings

```text
PORT=3550
ENABLE_TRACING=1
COLLECTOR_SERVICE_ADDR=otel-collector:4317
EXTRA_LATENCY=250ms
```

`EXTRA_LATENCY` is intended only for resilience and observability testing.

## Validate locally

```bash
go mod tidy
go test ./...
go build ./...
docker build -t avos/productcatalogservice:phase-1 .
```
