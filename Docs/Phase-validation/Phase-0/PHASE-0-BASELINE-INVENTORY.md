# AVOS Phase 0 Baseline Inventory

## Purpose

This document records the imported repository baseline and the changes made during Phase 0. It describes source-controlled evidence only and does not claim that any AWS or Kubernetes resource is currently deployed.

## Baseline identity

| Item | Verified value | Role |
|---|---|---|
| Repository branch | `main` | Identifies the branch used for the imported baseline. |
| Baseline commit | `c303c10d5eeedb6f77d43326795804675afdf92c` | Preserves the initial AVOS source import before restructuring. |
| Baseline tag | `avos-baseline-v1` | Provides a recoverable reference to the initial import. |
| Baseline commit message | `feat: add initial AVOS microservices source code` | Describes the imported-source milestone. |
| Initial tracked files | 689 | Establishes the repository size at the imported baseline. |
| AWS runtime evidence | Not collected | Prevents source code from being presented as deployed infrastructure. |

The commit, tag, and file count above describe the immutable imported baseline. Later sections distinguish that historical evidence from the current Phase 0 working tree.

## Application inventory

AVOS contains 11 business microservices and one supporting load-testing workload. The source code has been adapted to the AVOS identity; consolidated validation evidence is recorded separately before Phase 0 approval.

| Component | Language | Container definition | Classification | Short role |
|---|---|---:|---|---|
| `frontend` | Go | Present | Business service | Serves the AVOS customer interface and coordinates backend requests. |
| `cartservice` | C# | Present | Business service | Manages customer cart contents. |
| `checkoutservice` | Go | Present | Business service | Orchestrates the checkout workflow. |
| `currencyservice` | Node.js | Present | Business service | Converts product prices between supported currencies. |
| `paymentservice` | Node.js | Present | Business service | Simulates payment processing and returns a transaction identifier. |
| `productcatalogservice` | Go | Present | Business service | Lists, searches, and retrieves AVOS product data. |
| `shippingservice` | Go | Present | Business service | Estimates shipping costs and simulates shipment creation. |
| `emailservice` | Python | Present | Business service | Simulates order-confirmation email delivery. |
| `recommendationservice` | Python | Present | Business service | Produces product recommendations. |
| `adservice` | Java | Present | Business service | Returns AVOS contextual advertisements. |
| `shoppingassistantservice` | Python | Present | Business service | Provides AI-assisted product discovery. |
| `loadgenerator` | Python/Locust | Present | Testing workload | Generates controlled customer traffic for validation. |

## Phase 0 application changes

| Area | Current Phase 0 state | Decision |
|---|---|---|
| Customer-facing identity | AVOS branding, logo, favicon, palette, product presentation, and advertisements have been introduced. | Keep and validate. |
| Service source code | All 11 business services have been reviewed and adapted for the AVOS baseline. | Keep and validate. |
| Load generator | The workload models AVOS browsing, cart, and checkout traffic. | Keep as a testing component. |
| Product catalog | AVOS product data and product identifiers are present. | Keep synchronized with frontend assets and load tests. |
| Shopping assistant | The service has an AVOS-oriented contract and implementation baseline. | Continue AWS-native integration in its implementation phase. |
| Shared technical namespaces | Some inherited Protobuf and Java package names may remain for cross-language API compatibility. | Change only through a coordinated contract migration. |
| Legal attribution | Required copyright and license notices remain. | Preserve. |

## CI baseline and decision

| Area | Imported evidence | Phase 0 treatment | Future implementation |
|---|---|---|---|
| Seven service workflows | Inherited per-service workflows referenced predecessor ECR repositories and IAM roles. | Removed from the active AVOS tree. | Rebuild using AVOS repositories, GitHub OIDC, testing, scanning, and immutable image publication. |
| Email, recommendation, ad, and shopping assistant | No complete inherited CI coverage. | Recorded as a coverage gap. | Add through the approved reusable workflow. |
| Load generator | No inherited validation-oriented CI. | Recorded as a coverage gap. | Add workload linting, testing, image scanning, and publication. |
| Image-tag ownership | The inherited design allowed CI to update GitOps tags. | Rejected. | Argo CD Image Updater will be the only automation that writes image tags to Git. |

CI is intentionally not considered implemented during Phase 0.

## GitOps baseline and decision

| Area | Imported evidence | Phase 0 treatment | Future implementation |
|---|---|---|---|
| Application delivery | Partial Argo CD coverage existed for seven services. | Remove inherited Argo CD resources that reference predecessor repositories, projects, or namespaces. | Rebuild coverage for all 11 business services. |
| Load generator | No inherited Argo CD Application existed. | Keep outside the business-service count. | Add an on-demand testing deployment. |
| Cart datastore | In-cluster `redis-cart` manifests were present. | Retain only as local-development reference. | Use managed ElastiCache for shared AWS environments. |
| Ingress routing | Inherited Istio `Gateway` and `VirtualService` resources were present. | Treat as reference only. | Implement Kubernetes Gateway API resources managed by Istio. |
| Image automation | No approved single-writer model was established. | Ownership decision recorded. | Argo CD Image Updater discovers immutable ECR images and writes approved tag changes to Git. |

GitOps is intentionally not considered implemented during Phase 0.

## Terraform inventory

All Terraform entries below are source-code evidence. Their presence does not prove that the corresponding AWS resources exist.

| Root or area | Imported evidence | Short role | Phase 0 decision |
|---|---|---|---|
| `bootstrap/terraform-backend` | Backend configuration and provider lock file | Creates remote Terraform state foundations. | Review and rebuild safely. |
| `organization` | Organizations, OUs, and SCP configuration | Establishes account-governance boundaries. | Keep as reference; validate before reuse. |
| `governance` | CloudTrail, Config, GuardDuty, Security Hub, KMS, and Access Analyzer code | Provides centralized audit and detection controls. | Keep as reference; validate before reuse. |
| `identity` | Service-role foundations | Defines machine and platform identities. | Modify and expand. |
| `networking` | VPC and network foundations | Creates public, application, and database network tiers. | Rebuild from the approved AVOS design. |
| `security` | Security-control root | Applies shared security configuration. | Rebuild and validate. |
| `edge-security` | Route 53, ACM, CloudFront, WAF, and policy code | Protects and delivers public traffic. | Rebuild and validate. |
| `container-platform` | EKS and ingress-controller foundations | Runs Kubernetes workloads. | Rebuild from the approved AVOS design. |
| `platform-services` | Argo CD, Karpenter, observability, secrets, DNS, certificates, and Istio modules | Installs shared Kubernetes capabilities. | Rebuild and validate in ordered phases. |
| `ci` | GitHub OIDC and ECR access foundations | Provides short-lived CI access to AWS. | Rebuild for AVOS. |
| `modules` | Reusable Terraform module directories | Provides shared infrastructure building blocks. | Review individually before adoption. |
| Analytics and data platform | No complete root implementation | Supports business-event processing and analytics. | Add. |
| AIOps | Partial identity foundations but no complete operational workflow | Supports evidence-based assisted operations. | Add with human approval for remediation. |

## Documentation inventory

| Artifact | Current status | Short role |
|---|---|---|
| AVOS gRPC dependency map | Present | Documents service dependencies and interactive highlighting. |
| AVOS microservices architecture | Present | Defines service boundaries and communication flows. |
| AVOS project architecture | Present | Defines the approved target platform architecture. |
| AVOS implementation roadmap | Present | Orders implementation, validation, cleanup, and sign-off. |
| Phase 0 ADRs | Present | Record approved decisions and ownership boundaries. |
| Root README | Not yet confirmed as complete | Provides the authoritative repository entry point. |
| Runbooks and troubleshooting index | Not yet implemented | Will document operational procedures as capabilities are built. |

## Baseline risks and Phase 0 treatment

| Initial finding | Risk | Phase 0 treatment or decision |
|---|---|---|
| Generated Product Catalog test binary was tracked. | Bloats Git history and may become stale. | Removed from tracking and covered by ignore rules. |
| Terraform backup JSON was tracked. | May expose state metadata or sensitive values. | Removed from tracking after review and covered by ignore rules. |
| Customer-facing predecessor branding remained. | Creates an inconsistent product identity. | Replaced with AVOS branding across the application source. |
| Inherited CI referenced predecessor AWS resources. | Could publish to or authenticate against incorrect targets. | Removed; AVOS CI will be rebuilt later. |
| Inherited Argo CD resources referenced predecessor Git repositories and namespaces. | Could reconcile from or deploy to incorrect targets. | Removed from the active tree; AVOS GitOps will be rebuilt later. |
| Draw.io backup and temporary files were tracked. | Adds noise and may expose stale diagram content. | Removed and excluded through `.gitignore`. |
| Required third-party names and legal notices remain. | Blind replacement could break dependencies or violate attribution requirements. | Retained intentionally. |
| Runtime state is unverified. | Source code could be mistaken for an operating platform. | All capabilities remain labelled baseline or planned until runtime evidence is collected. |

## Phase 0 completion gates

Phase 0 is complete only when all of the following evidence is recorded:

- All 11 business microservices and the Load Generator have an explicit validation result.
- Intended container images build successfully, or a documented environment blocker is recorded.
- Customer-facing predecessor branding scans return no actionable matches.
- Legacy CI and GitOps configurations cannot target predecessor resources.
- Generated binaries, temporary files, local virtual environments, dependency directories, secrets, and Terraform state are not tracked.
- `git diff --check` reports no whitespace errors.
- The Phase 0 validation report records passed checks, exceptions, and deferred work.
- The approved Phase 0 commit is tagged with a new post-rebranding baseline tag.

## Inventory conclusion

The imported repository provided useful application and infrastructure references, but it was not a completed AVOS platform. Phase 0 establishes an AVOS-specific source baseline, removes active predecessor delivery configuration, preserves required compatibility and attribution, and records the boundary between source evidence and deployed runtime state. Infrastructure, CI, GitOps, security, observability, analytics, and AIOps will be implemented and validated through their approved phases.
