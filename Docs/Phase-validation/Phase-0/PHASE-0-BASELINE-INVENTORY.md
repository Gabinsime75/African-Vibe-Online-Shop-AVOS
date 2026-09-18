# AVOS Phase 0 Baseline Inventory

## Purpose

This document records the repository evidence present before AVOS implementation begins. It describes source-controlled evidence only and does not claim that any AWS or Kubernetes resource is currently deployed.

## Baseline identity

| Item | Verified value | Role |
|---|---|---|
| Repository branch | `main` | Identifies the branch inspected for the imported baseline. |
| Baseline commit | `c303c10d5eeedb6f77d43326795804675afdf92c` | Preserves the initial AVOS source import. |
| Baseline tag | `avos-baseline-v1` | Provides a recoverable reference before restructuring. |
| Baseline commit message | `feat: add initial AVOS microservices source code` | Describes the imported source milestone. |
| Tracked files | 689 | Establishes the initial repository size. |
| AWS runtime evidence | Not collected | Prevents source code from being presented as deployed infrastructure. |

## Application inventory

AVOS contains 11 business microservices and one supporting load-testing workload.

| Component | Language | Container definition | Classification | Short role |
|---|---|---:|---|---|
| `frontend` | Go | Present | Business service | Serves the customer interface and coordinates backend requests. |
| `cartservice` | C# | Present | Business service | Manages customer cart contents. |
| `checkoutservice` | Go | Present | Business service | Orchestrates the checkout workflow. |
| `currencyservice` | Node.js | Present | Business service | Converts product prices between supported currencies. |
| `paymentservice` | Node.js | Present | Business service | Simulates payment processing and returns a transaction identifier. |
| `productcatalogservice` | Go | Present | Business service | Lists, searches, and retrieves product data. |
| `shippingservice` | Go | Present | Business service | Estimates shipping and simulates shipment creation. |
| `emailservice` | Python | Present | Business service | Simulates order-confirmation email delivery. |
| `recommendationservice` | Python | Present | Business service | Produces product recommendations. |
| `adservice` | Java | Present | Business service | Returns contextual advertisements. |
| `shoppingassistantservice` | Python | Present | Business service | Provides AI-assisted product discovery. |
| `loadgenerator` | Python/Locust | Present | Testing workload | Generates controlled customer traffic for validation. |

## CI coverage

| Component | Workflow status | Required action |
|---|---|---|
| frontend, cart, checkout, currency, payment, product catalog, shipping | Present | Modify inherited workflows to follow the approved supply-chain design. |
| email, recommendation, ad, shopping assistant | Missing | Add service CI by reusing the approved shared workflow. |
| load generator | Missing | Add validation-oriented CI without classifying it as a business service. |
| Reusable service workflow | Present | Modify it so CI publishes immutable images but never writes GitOps tags. |

## GitOps coverage

| Area | Baseline evidence | Required action |
|---|---|---|
| Seven application services | Base, development overlay, and Argo CD Application are present. | Modify and rebrand. |
| Email, recommendation, ad, shopping assistant | No base, overlay, or Argo CD Application. | Add complete GitOps coverage. |
| Load generator | No base, overlay, or Argo CD Application. | Add an on-demand testing deployment. |
| Cart datastore | In-cluster `redis-cart` manifests are present. | Replace with managed ElastiCache for staging and production. |
| Ingress routing | Istio `Gateway` and `VirtualService` are present. | Replace with Kubernetes Gateway API resources managed by Istio. |
| Argo CD project | Still uses inherited CloudHustler naming. | Rebrand and restrict permissions. |

## Terraform inventory

| Root or area | Baseline evidence | Short role | Status |
|---|---|---|---|
| `bootstrap/terraform-backend` | Backend code, lock file, and a tracked backup JSON file | Creates remote Terraform state foundations. | Modify and clean. |
| `organization` | Organizations, OUs, and SCP configuration | Establishes account governance boundaries. | Keep/modify. |
| `governance` | CloudTrail, Config, GuardDuty, Security Hub, KMS, and Access Analyzer code | Provides centralized audit and detection controls. | Keep/modify. |
| `identity` | Service-role foundations | Defines machine and platform identities. | Modify/expand. |
| `networking` | VPC and network foundations | Creates public, application, and database network tiers. | Keep/modify. |
| `security` | Security-control root | Applies shared security configuration. | Keep/modify. |
| `edge-security` | Route 53, ACM, CloudFront, WAF, and policies | Protects and delivers public traffic. | Keep/modify. |
| `container-platform` | EKS and ALB/Istio integration code | Runs Kubernetes workloads. | Keep/modify. |
| `platform-services` | Argo CD, Karpenter, observability, secrets, DNS, certificates, and Istio modules | Installs shared Kubernetes capabilities. | Keep/modify. |
| `ci` | GitHub OIDC and ECR access | Provides short-lived CI access to AWS. | Keep/modify. |
| `modules` | 40 module directories | Provides reusable Terraform building blocks. | Review individually. |
| Analytics/data platform | No complete root implementation | Supports business event processing and analytics. | Add. |
| AIOps | Some IAM-role foundations but no complete operational workflow | Supports evidence-based assisted operations. | Add. |

## Documentation inventory

| Artifact | Status | Short role |
|---|---|---|
| AVOS gRPC dependency map (HTML and PNG) | Present in the working tree | Documents service dependencies and interactive highlighting. |
| AVOS project architecture (PNG and SVG) | Present in the working tree | Defines the approved target platform architecture. |
| AVOS implementation roadmap | Present in the working tree | Orders implementation, validation, cleanup, and sign-off. |
| Root README | Missing | Must become the authoritative repository entry point in Phase 1. |
| ADRs | Added during Phase 0 | Record approved decisions and ownership boundaries. |
| Runbooks and troubleshooting index | Missing | Must be added as operational capabilities are implemented. |

## Baseline risks and hygiene findings

| Finding | Evidence | Risk | Planned treatment |
|---|---|---|---|
| Generated test binary tracked | `src/productcatalogservice/productcatalogservice.test` | Bloats Git history and may become stale. | Remove from tracking in Phase 1. |
| Terraform backup JSON tracked | `terraform/bootstrap/terraform-backend/terraform-backend-state-backup.json` | May expose state metadata or sensitive values. | Inspect, preserve only if required, then remove from tracking in Phase 1. |
| Inherited naming remains | 160 files match `CloudHustler` case-insensitively. | Creates inconsistent identity and configuration. | Rebrand carefully in Phase 1. |
| Other inherited references remain | Cymbal, Online Boutique, Hipster, Google, AlloyDB, and Gemini references were found. | Conflicts with the AWS-native AVOS design. | Classify legal attribution versus removable implementation references. |
| Partial delivery coverage | Five source components lack CI; five lack GitOps. | Prevents consistent release and reconciliation. | Complete coverage in Phases 7–9. |
| Deployment state unverified | No Phase 0 runtime evidence was collected. | Source code could be mistaken for an operating platform. | Label capabilities as baseline or planned until validated. |

## Inventory conclusion

The repository is a viable seed, not a completed AVOS platform. Application source and substantial AWS/Kubernetes foundations exist, but identity, coverage, managed data, analytics, AIOps, and validation require controlled implementation through later phases.
