# AVOS GitOps

## Status

Development GitOps delivery is validated for ten business services and
the suspended load generator.
All twelve Applications, including the administrative root, passed fresh
Synced/Healthy reconciliation checks.

Full Phase 8 sign-off remains pending.
Shoppingassistantservice GitOps coverage, staging and production overlays
and delivery, and independent production approval enforcement are incomplete.

Only current AVOS resources are approved for use.

## Business-service coverage

| Service | Base and dev overlay | Argo CD and Image Updater |
|---|---|---|
| frontend | Present | Registered |
| productcatalogservice | Present | Registered |
| cartservice | Present | Registered |
| checkoutservice | Present | Registered |
| currencyservice | Present | Registered |
| paymentservice | Present | Registered |
| shippingservice | Present | Registered |
| emailservice | Present | Registered |
| recommendationservice | Present | Registered |
| adservice | Present | Registered |
| shoppingassistantservice | Pending | Pending |

The load generator is a supporting test workload, not a business service.
Its development CronJob is registered and remains suspended.
An in-cluster Redis workload is not the approved production cart datastore.

## Delivery ownership

| Component | Responsibility |
|---|---|
| GitHub Actions | Test, scan, build, publish, and sign images |
| Image Updater | Discover approved images and write references to Git |
| Argo CD | Reconcile merged desired state into Kubernetes |
| Terraform | Install controllers and configure bootstrap and permissions |

Image Updater is the sole automated image-reference writer.
Development changes use generated branches and PRs to protected main.
Mandatory reviewer approvals are currently zero.

Workloads automatically synchronize, prune, and self-heal.
The administrative root requires manual synchronization.
Future environments must preserve ADR-001 account isolation and promote
the same approved artifact digest.

## Operations and evidence

- [Promotion policy](ENVIRONMENT-PROMOTION.md)
- [Reconciliation policy](RECONCILIATION-POLICY.md)
- [Operations runbook](OPERATIONS-RUNBOOK.md)
- [Validation report](../Docs/Phase-validation/Phase-8/PHASE-8-VALIDATION-REPORT.md)
- [GitOps ADR](../Docs/ADR/ADR-005-avos-gitops-boundaries.md)
