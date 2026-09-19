# AVOS Load Generator

The Load Generator is a Locust workload that continuously exercises realistic AVOS customer journeys through the public Frontend HTTP interface. It is a testing workload, not one of the eleven business microservices.

## Traffic mix

| Journey | Role |
|---|---|
| Home and product browsing | Creates typical read traffic against the Frontend and Product Catalog Service. |
| Currency selection | Exercises Frontend-to-Currency Service gRPC calls. |
| Cart actions | Exercises Frontend-to-Cart Service calls and Redis-backed cart state. |
| Checkout | Exercises catalog, cart, currency, shipping, payment, and email workflows. |

## Configuration

| Variable | Default | Purpose |
|---|---|---|
| `FRONTEND_ADDR` | `frontend:80` | Selects the target Frontend; either `host:port` or a complete URL is accepted. |
| `USERS` | `10` | Sets the number of concurrent Locust users. |
| `RATE` | `1` | Sets users spawned per second. |
| `RUN_TIME` | unset | Optionally stops the test after a Locust duration such as `5m`. |
| `MIN_WAIT_SECONDS` | `1` | Sets the minimum delay between customer actions. |
| `MAX_WAIT_SECONDS` | `5` | Sets the maximum delay between customer actions. |
| `AVOS_PRODUCT_IDS` | AVOS baseline IDs | Overrides the comma-separated catalog IDs used by traffic. |
| `LOCUST_RANDOM_SEED` | unset | Makes locally generated traffic data repeatable. |
| `LOCUST_LOGLEVEL` | `INFO` | Controls Locust logging verbosity. |

## Local validation on Git Bash

```bash
python -m venv .venv
source .venv/Scripts/activate
python -m pip install -r requirements.txt
python -m compileall -q .
python -m unittest discover -s test -p "test_*.py" -v
docker build -t avos/loadgenerator:phase-1 .
```

Run a short local test against a Frontend at `localhost:8080`:

```bash
FRONTEND_ADDR=localhost:8080 USERS=10 RATE=2 RUN_TIME=30s ./run-load-test.sh
```

Only run load tests against environments you own or are explicitly authorized to test. Start with a small user count, observe error rate and latency, and increase traffic gradually.
