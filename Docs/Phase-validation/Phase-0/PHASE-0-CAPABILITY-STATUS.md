# AVOS Phase 0 Capability Status Matrix

## Status definitions

| Status | Meaning |
|---|---|
| Previously implemented | Evidence exists from the predecessor project, but AVOS validation has not occurred. |
| Designed, not implemented | The capability appears in approved architecture or roadmap documents only. |
| Baseline present | Source-controlled implementation exists in the AVOS repository. |
| Currently deployed | Runtime evidence confirms the capability is operating now. |
| AVOS planned | The capability is approved for implementation in a later phase. |

## Capability matrix

| Capability | Previously implemented | Baseline present | Currently deployed | AVOS planned | Evidence or note |
|---|:---:|:---:|:---:|:---:|---|
| 11 business-service source trees | Yes | Yes | Not verified | Yes | `src/` inventory. |
| Load generator | Yes | Yes | Not verified | Yes | Supporting workload under `src/loadgenerator`. |
| Internal gRPC communication | Yes | Partial | Not verified | Yes | Existing protobufs and service implementations; centralized contract ownership is absent. |
| Complete service CI | Partial | Partial | N/A | Yes | Seven service workflows plus one reusable workflow. |
| Immutable ECR publication | Partial | Partial | Not verified | Yes | Workflow and Terraform foundations require AVOS validation. |
| Image Updater sole Git writer | No/partial | Partial | Not verified | Yes | Approved ownership decision; complete configuration is pending. |
| Argo CD reconciliation | Partial | Partial | Not verified | Yes | Argo CD Terraform and application manifests exist. |
| Full GitOps service coverage | Partial | No | Not verified | Yes | Four business services and load generator are missing. |
| Kubernetes Gateway API through Istio | No | No | Not verified | Yes | Legacy Istio Gateway/VirtualService is present instead. |
| EKS platform | Yes | Yes | Not verified | Yes | Terraform roots and modules exist. |
| Karpenter and HPA | Yes | Partial | Not verified | Yes | Terraform and frontend HPA foundations exist. |
| Managed Aurora PostgreSQL | No/partial | No | Not verified | Yes | Target architecture capability. |
| Managed ElastiCache Redis | No | No | Not verified | Yes | Existing baseline uses in-cluster Redis. |
| Cognito customer identity | No/partial | No | Not verified | Yes | Target architecture capability. |
| Route 53, CloudFront, WAF, ACM, ALB edge | Yes | Yes | Not verified | Yes | Terraform configuration exists. |
| Prometheus/Grafana/Alertmanager | Yes | Yes | Not verified | Yes | Terraform module foundations exist. |
| Fluent Bit/Loki logging | Yes | Yes | Not verified | Yes | Terraform module foundations exist. |
| OpenTelemetry/X-Ray tracing | Partial | Partial | Not verified | Yes | Collector foundations exist; end-to-end propagation is pending. |
| Kiali service-mesh visibility | Yes | Yes | Not verified | Yes | Terraform module foundation exists. |
| Kinesis/Firehose/S3/Glue/Athena/QuickSight | No | No | Not verified | Yes | Approved analytics architecture. |
| OpenSearch operational search | No | No | Not verified | Yes | Approved target capability. |
| Bedrock shopping assistant | No | No | Not verified | Yes | Replaces inherited Google-oriented implementation. |
| SageMaker anomaly detection | No | No | Not verified | Yes | Approved AIOps capability. |
| Human-approved SSM remediation | No | No | Not verified | Yes | Approved safety boundary. |
| Organizations and governance services | Yes | Yes | Not verified | Yes | Terraform foundations exist. |
| Tested disaster recovery and teardown | Partial | Partial | Not verified | Yes | Scripts/evidence must be standardized and revalidated. |

## Phase 0 assertion

No AVOS capability is marked **Currently deployed** because Phase 0 gathered repository evidence only. Runtime status must be proven by dated commands, logs, health checks, or cloud-console/API evidence during the implementation phase that owns the capability.
