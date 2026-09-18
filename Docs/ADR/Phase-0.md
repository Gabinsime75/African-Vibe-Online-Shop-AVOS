# AVOS Architecture Decision Records

| ADR | Decision | Status | Short role |
|---|---|---|---|
| [ADR-0001](ADR-0001-terraform-infrastructure-authority.md) | Terraform is the infrastructure authority. | Accepted | Prevents undocumented cloud drift. |
| [ADR-0002](ADR-0002-internal-grpc.md) | AVOS uses internal gRPC. | Accepted | Standardizes typed service communication. |
| [ADR-0003](ADR-0003-gitops-delivery-ownership.md) | CI, Image Updater, and Argo CD have separate owners. | Accepted | Prevents delivery races and unclear audit trails. |
| [ADR-0004](ADR-0004-istio-gateway-api.md) | Istio manages service mesh and Gateway API. | Accepted | Unifies ingress and east-west traffic policy. |
| [ADR-0005](ADR-0005-managed-application-data.md) | Aurora and ElastiCache provide managed application data. | Accepted | Separates durable state from pod lifecycles. |
| [ADR-0006](ADR-0006-observability-stack.md) | AVOS uses the approved multi-signal observability stack. | Accepted | Correlates metrics, logs, traces, and mesh behavior. |
| [ADR-0007](ADR-0007-analytics-pipeline.md) | AVOS uses a governed streaming analytics pipeline. | Accepted | Converts business events into queryable insights. |
| [ADR-0008](ADR-0008-human-gated-aiops.md) | AIOps remediation remains human-gated. | Accepted | Prevents probabilistic AI output from directly changing production. |

New decisions must be recorded as separate ADRs. Accepted ADRs are superseded rather than silently rewritten when the architecture changes.
