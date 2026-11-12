# AVOS Relational Data Ownership and Migration Policy

## Status

Phase 9.7 design baseline. Aurora infrastructure, application integration,
migrations, and database failure tests have not been deployed or validated.

## Current storage decisions

| Service or capability | Storage decision | Ownership |
|---|---|---|
| Cartservice | ElastiCache Redis | Cartservice owns cart keys and serialization |
| Product catalog | Retain products.json for the first release | Productcatalogservice owns the catalog |
| Durable order history | Proposed Aurora consumer; not implemented | Checkoutservice is the proposed owner |
| Payment and shipping simulators | No relational datastore currently required | Each service owns its simulated behavior |

The optional Aurora catalog loader does not authorize a production catalog
migration. Enabling DATABASE_URL requires a separate reviewed change.

## Schema ownership

- Every relational schema must have one named service owner.
- Other services access owned data through that service's API.
- Application credentials must not allow access to another service's schema.
- Runtime roles receive only required data privileges.
- A separate migration role owns schema changes.
- Database administrator credentials must never be supplied to application Pods.
- Order persistence requires a reviewed data model and failure-handling design.
- Never persist raw payment-card numbers or security codes.

## Versioned migrations

- Keep migrations with the owning service under migrations/.
- Use sequential, immutable migration files reviewed through pull requests.
- Record applied versions and checksums in the database.
- Run one controlled migration Job using a migration lock.
- Do not run schema changes independently from every application replica.
- Use expand-and-contract changes compatible with rolling deployments.
- Separate large backfills from schema changes and bound their execution.
- Validate migrations against both an empty database and the previous release.
- An application rollback must remain compatible with the expanded schema.
- Destructive changes require a recovery plan and verified backup evidence.

## Connection pooling and request limits

- Reuse a bounded pool per application process.
- Set maximum connections explicitly; do not rely on driver defaults.
- Budget the sum of pools across maximum replicas and rolling-update surge.
- Reserve database capacity for migrations, administration, and recovery.
- Bound connection establishment, pool acquisition, and query execution.
- Respect the remaining parent request deadline and propagate cancellation.
- Close transactions and release connections on every success and error path.
- Close pools during graceful shutdown.
- Do not automatically retry mutations with an uncertain commit outcome.

The existing optional catalog loader creates and closes a pool for a catalog
load. It does not establish a long-lived application pool or enforce this
policy's explicit connection budget.

## Connectivity and credentials

- Use private data subnets and restricted security-group access.
- Allow database egress only from approved workloads.
- Require TLS with certificate and hostname verification.
- Deliver application credentials through Secrets Manager and External Secrets.
- Validate credential rotation and application reconnection.
- Never commit credentials or print connection strings containing passwords.

## Aurora integration acceptance gate

Before claiming managed relational persistence is complete, verify:

- A reviewed business requirement, owning service, and schema.
- Private encrypted infrastructure and least-privilege credentials.
- Repeatable migrations and enforced connection limits.
- Application writes and reads that survive Pod replacement.
- Safe behavior during database unavailability and uncertain outcomes.
- Backup restoration and failover recovery.
- Logs and metrics that exclude credentials and sensitive customer data.
