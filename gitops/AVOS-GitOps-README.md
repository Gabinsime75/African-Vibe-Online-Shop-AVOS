# AVOS GitOps

## Status

The inherited CloudHustler GitOps configuration was removed during AVOS Phase 1 because it covered only seven services, referenced obsolete namespaces and ECR repositories, used legacy Istio routing resources, and deployed Redis inside the cluster.

AVOS GitOps will be rebuilt during the approved delivery phase. Until that phase passes its validation gate, this directory does not represent a deployable environment.

## Required business-service coverage

Every AVOS business service must receive complete CI and GitOps coverage.

| # | Service | Kubernetes base | Environment overlays | Argo CD registration | Image Updater |
|---:|---|---|---|---|---|
| 1 | `frontend` | Required | Required | Required | Required |
| 2 | `productcatalogservice` | Required | Required | Required | Required |
| 3 | `cartservice` | Required | Required | Required | Required |
| 4 | `checkoutservice` | Required | Required | Required | Required |
| 5 | `currencyservice` | Required | Required | Required | Required |
| 6 | `paymentservice` | Required | Required | Required | Required |
| 7 | `shippingservice` | Required | Required | Required | Required |
| 8 | `emailservice` | Required | Required | Required | Required |
| 9 | `recommendationservice` | Required | Required | Required | Required |
| 10 | `adservice` | Required | Required | Required | Required |
| 11 | `shoppingassistantservice` | Required | Required | Required | Required |

`loadgenerator` is a supporting test workload. It will receive validation CI and an on-demand GitOps deployment, but it is not counted as a business service.

Production cart persistence will use Amazon ElastiCache for Redis. An in-cluster `redis-cart` workload must not be treated as a twelfth business service or as the production datastore.

## Delivery ownership

| Component | Short role |
|---|---|
| GitHub Actions | Tests, scans, builds, and publishes immutable images to Amazon ECR. |
| Argo CD Image Updater | Discovers approved images and writes image-reference changes to Git. |
| Argo CD | Reconciles the desired state stored in Git into Amazon EKS. |

GitHub Actions must not update GitOps image tags. Argo CD Image Updater is the single approved automated image-reference writer.

## Target structure

```text
gitops/
├── argocd/
│   ├── projects/
│   ├── applicationsets/
│   └── root/
├── base/
│   ├── frontend/
│   ├── productcatalogservice/
│   ├── cartservice/
│   ├── checkoutservice/
│   ├── currencyservice/
│   ├── paymentservice/
│   ├── shippingservice/
│   ├── emailservice/
│   ├── recommendationservice/
│   ├── adservice/
│   ├── shoppingassistantservice/
│   └── loadgenerator/
├── components/
│   ├── security/
│   ├── observability/
│   └── networking/
└── overlays/
    ├── dev/
    ├── staging/
    └── production/
```

## Minimum workload standard

Each applicable service deployment must define:

- Immutable image references
- Dedicated ServiceAccount
- Non-root security context
- CPU and memory requests and limits
- Startup, readiness, and liveness probes
- PodDisruptionBudget
- NetworkPolicy
- HorizontalPodAutoscaler where scaling behavior warrants it
- Topology-spread or anti-affinity policy where availability warrants it
- Prometheus and OpenTelemetry integration
- External Secrets integration when secrets are required
- Argo CD health and synchronization behavior
- Argo CD Image Updater policy

## Validation gate

The future GitOps phase cannot be approved until:

- All 11 business services are registered and healthy through Argo CD.
- The Load Generator can be enabled and disabled independently.
- Development, staging, and production overlays render successfully.
- No inherited CloudHustler names, repositories, namespaces, or domains remain.
- Gateway API replaces the legacy Istio `Gateway` and `VirtualService` ingress configuration.
- Image Updater writes immutable image references to Git and Argo CD reconciles them.
- Production cart workloads use the managed Redis endpoint rather than an in-cluster Redis deployment.
- Drift detection, rollback, and failed-sync behavior are validated.
