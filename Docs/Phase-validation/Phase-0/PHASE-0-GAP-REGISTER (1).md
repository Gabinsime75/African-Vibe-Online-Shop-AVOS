# AVOS Phase 0 Gap Register

## Purpose

This register maps the imported repository to the approved AVOS architecture using Keep, Modify, Replace, Add, and Remove dispositions.

| ID | Domain | Component or capability | Evidence status | Disposition | Required outcome | Target phase |
|---|---|---|---|---|---|---:|
| GAP-001 | Product identity | AVOS branding | Partial | Modify | Replace inherited product naming while preserving required attribution. | 1 |
| GAP-002 | Documentation | Root README | Missing | Add | Create the authoritative AVOS entry point, architecture summary, status, and links. | 1 |
| GAP-003 | Repository hygiene | Compiled binaries | Present | Remove | Untrack generated executables and prevent recommit. | 1 |
| GAP-004 | State safety | Terraform backup JSON | Present | Remove | Remove custom state exports after confirming no recovery dependency. | 1 |
| GAP-005 | Application | Eleven business service source trees | Present | Keep/Modify | Preserve service responsibilities while applying AVOS naming, policies, and telemetry. | 9 |
| GAP-006 | Testing | Load generator | Present | Keep/Modify | Retain as an on-demand test workload, not a business microservice. | 9 |
| GAP-007 | API contracts | Distributed protobuf definitions | Partial | Modify | Establish central ownership, generation, compatibility, deadlines, and retry rules. | 9 |
| GAP-008 | Shopping assistant | Google/Gemini/AlloyDB implementation | Present | Replace | Use Bedrock, OpenSearch, Secrets Manager, and an internal gRPC contract. | 9 |
| GAP-009 | Customer identity | Cognito integration | Missing/partial | Add | Add sign-in, JWT validation, logout, callback, and authorization boundaries. | 4 |
| GAP-010 | Cart persistence | In-cluster Redis | Present | Replace | Use private Multi-AZ ElastiCache in staging and production. | 5/9 |
| GAP-011 | Durable data | Aurora PostgreSQL | Incomplete | Add | Add schemas, ownership, migrations, pooling, backup, and failover validation. | 5/9 |
| GAP-012 | EKS | Cluster and add-on foundations | Present as code | Modify | Rebrand, harden, right-size, and validate the approved environments. | 5 |
| GAP-013 | Autoscaling | HPA and Karpenter foundations | Partial | Keep/Modify | Define workload and node scaling policies from measured demand. | 5/9 |
| GAP-014 | Platform routing | Istio legacy Gateway/VirtualService | Present | Replace | Adopt Istio-managed Kubernetes Gateway API resources. | 6 |
| GAP-015 | Edge | Route 53, CloudFront, WAF, ACM, and ALB | Present as code | Modify | Align domain, origin security, policies, logging, and health checks with AVOS. | 4 |
| GAP-016 | Network controls | Security groups and flow logs | Present as code | Modify | Enforce private workloads, controlled egress, flow visibility, and least privilege. | 4 |
| GAP-017 | CI | Seven service workflows | Partial | Modify | Standardize tests, scans, SBOM, signing, and immutable ECR publication. | 7 |
| GAP-018 | CI | Five missing component workflows | Missing | Add | Cover email, recommendation, ad, shopping assistant, and load generator. | 7 |
| GAP-019 | Delivery ownership | CI manifest writes/deployment behavior | Conflicting inherited design | Remove | Stop CI after image publication. | 7 |
| GAP-020 | GitOps | Argo CD foundations | Present as code | Modify | Use restricted projects, AppSets/root app, health checks, and environment promotion. | 8 |
| GAP-021 | Image promotion | Argo CD Image Updater | Planned/partial | Add/Modify | Make Image Updater the sole automated Git image-tag writer. | 8 |
| GAP-022 | GitOps coverage | Four business services and load generator | Missing | Add | Add bases, overlays, policies, and Argo CD applications. | 8/9 |
| GAP-023 | Secrets | External Secrets foundation | Present as code | Modify | Synchronize approved Secrets Manager values using workload identity. | 6 |
| GAP-024 | Observability | Metrics, logs, traces, dashboards | Present as code/partial | Modify/Expand | Add consistent telemetry, SLOs, ownership, correlation, and retention. | 10 |
| GAP-025 | Incident response | Alert routing and runbooks | Partial | Add/Modify | Route actionable alerts through Alertmanager/SNS and connect them to runbooks. | 10 |
| GAP-026 | Business analytics | Kinesis-to-QuickSight pipeline | Missing | Add | Build governed streaming ingestion, lake zones, catalog, queries, and dashboards. | 11 |
| GAP-027 | Operational search | OpenSearch | Missing | Add | Provide purpose-specific operational and vector search collections. | 11/12 |
| GAP-028 | AIOps | Detection, enrichment, analysis, and approval | Missing | Add | Use EventBridge, Lambda, SageMaker, Bedrock, human approval, and SSM. | 12 |
| GAP-029 | Governance | Organizations, audit, and detection foundations | Present as code | Keep/Modify | Validate centralized governance, retention, aggregation, and least privilege. | 3 |
| GAP-030 | Resilience | Failure, load, recovery, and rollback evidence | Missing | Add | Test dependencies, scaling, AZ failures, promotion, and restoration. | 13/14 |
| GAP-031 | Cost | Budgets, ownership, retention, and teardown | Partial | Add/Modify | Attach cost controls and cleanup procedures to every cost-producing capability. | All phases |

## Priority rules

1. Security or state-exposure risks are addressed before feature expansion.
2. Shared foundations are validated before application dependencies use them.
3. Observability and runbooks precede AIOps automation.
4. AIOps remains advisory until human approval and allow-listed SSM execution are validated.
5. No capability is marked deployed solely because Terraform or Kubernetes code exists.
