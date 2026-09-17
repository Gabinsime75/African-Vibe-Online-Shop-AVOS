# African Vibe Online Shop (AVOS) Implementation Roadmap

## Document purpose

This roadmap converts the approved AVOS target architecture into an ordered, testable, cost-aware implementation program. It uses the existing CloudHustler-derived repository as a baseline while clearly separating what already exists from what must be kept, modified, replaced, added, or removed.

## Approved architecture decisions

| Decision | Role in AVOS |
|---|---|
| Amazon EKS | Runs the 11 AVOS business microservices as Kubernetes workloads. |
| Internal gRPC | Provides typed, efficient synchronous communication between business services. |
| HTTPS edge traffic | Carries customer requests through Route 53, CloudFront, WAF, ALB, and Istio Gateway API. |
| Terraform | Remains the authoritative system for provisioning AWS infrastructure. |
| GitHub Actions | Tests, scans, builds, signs, and publishes immutable container images to ECR. |
| Argo CD Image Updater | Detects approved ECR images and owns application image-tag changes in Git. |
| Argo CD | Reconciles approved Git state into EKS without CI directly applying manifests. |
| Istio and Gateway API | Control north-south ingress and east-west service-mesh behavior. |
| Aurora PostgreSQL | Stores durable relational application data in private Multi-AZ database subnets. |
| ElastiCache for Redis | Stores low-latency shopping-cart state outside the EKS workload lifecycle. |
| Prometheus, Loki, OpenTelemetry, Grafana, Kiali, and X-Ray | Provide metrics, logs, traces, dashboards, and service-mesh visibility. |
| Kinesis, Firehose, S3, Glue, Athena, and QuickSight | Form the AVOS streaming analytics and business-intelligence pipeline. |
| SageMaker AI, Bedrock, and OpenSearch | Provide anomaly signals, evidence retrieval, incident analysis, and recommendations. |
| EventBridge, Lambda, and SSM Automation | Route incidents, enrich evidence, and execute approved remediation runbooks. |
| Human approval | Prevents AI recommendations from directly changing production without authorization. |

## Mandatory implementation rules

1. **Architecture before implementation:** A phase may start only after its prerequisites and design decisions are approved.
2. **Terraform owns infrastructure:** AWS resources must be created through Terraform, not undocumented console actions.
3. **Git owns desired application state:** Kubernetes resources must be reconciled by Argo CD, not applied directly from CI.
4. **Image Updater owns image-tag changes:** GitHub Actions stops after publishing the immutable ECR image.
5. **Immutable artifacts:** Every image must use a commit SHA or digest; mutable production tags such as `latest` are prohibited.
6. **Environment isolation:** Development, staging, and production must use separate configuration, state, approvals, and blast-radius boundaries.
7. **No secrets in Git:** Secrets must be stored in AWS Secrets Manager and synchronized through External Secrets.
8. **Least privilege:** Humans use IAM Identity Center and EKS access entries; workloads use EKS Pod Identity where supported.
9. **Private workloads and data:** EKS nodes, Aurora, Redis, OpenSearch, and internal services remain private unless explicitly approved.
10. **Observability before automation:** Reliable telemetry, alert ownership, and runbooks must exist before AIOps remediation is enabled.
11. **Human-gated AIOps:** Bedrock provides evidence-based recommendations; only allow-listed and approved SSM actions may execute.
12. **Security in every phase:** Threat modeling, encryption, audit logging, policy checks, and vulnerability scanning are continuous controls.
13. **Cost-aware delivery:** Expensive resources must have budgets, tags, retention limits, schedules, and teardown procedures.
14. **Documentation as code:** Every phase must produce configuration, validation evidence, rollback instructions, and an architecture decision record.
15. **No unsupported claims:** Documentation must distinguish repository baseline, previously implemented, currently deployed, and AVOS-planned capabilities.

## Status and disposition legend

| Label | Meaning |
|---|---|
| Baseline present | Code or configuration currently exists in the AVOS repository. |
| Previously implemented | The capability was implemented in the predecessor project and may provide reusable evidence. |
| Partial | Some required services or environments are missing. |
| Keep | Retain the component with limited changes. |
| Modify | Rework the existing component to meet the approved AVOS design. |
| Replace | Remove the current implementation and introduce the approved alternative. |
| Add | Implement a capability that is absent from the repository. |
| Remove | Delete obsolete, generated, unsafe, duplicated, or conflicting material. |
| Planned | Approved for AVOS but not yet implemented or validated. |

## Current repository baseline and gap analysis

| Area | Current evidence | Disposition | Required AVOS outcome |
|---|---|---|---|
| Application source | 11 business-service directories plus `loadgenerator` are present. | Keep/Modify | Preserve all services, classify `loadgenerator` as a testing workload, and modernize selected services. |
| Internal communication | Existing application contracts are primarily gRPC. | Keep | Standardize protobuf ownership, deadlines, retries, health checks, and telemetry. |
| Shopping assistant | Uses Google-oriented AI, database, embedding, and secret dependencies. | Replace | Use Bedrock, OpenSearch, AWS Secrets Manager, and a gRPC service contract. |
| Product catalog | Reads catalog data from JSON. | Keep initially | Retain JSON for the first release and define a later migration path only if business requirements justify it. |
| Shopping cart | Redis is represented as an in-cluster deployment. | Replace | Use private Multi-AZ ElastiCache for Redis in staging and production. |
| Durable application data | Aurora is not fully integrated with application ownership and migrations. | Add | Provision Aurora PostgreSQL and define schemas, migrations, backups, and service ownership. |
| CI workflows | Reusable CI exists for seven services. | Modify/Expand | Cover all 11 services and the load generator; remove manifest-tag writes from CI. |
| GitOps manifests | Base and development overlays cover only part of the application. | Expand | Add every business service, external dependencies, policies, and environment overlays. |
| Image promotion | Prior workflow logic can update manifests while Image Updater is also planned. | Replace | Make Image Updater the only automated image-tag writer using Git write-back. |
| Istio routing | Legacy `Gateway` and `VirtualService` resources are present. | Replace | Adopt Kubernetes Gateway API resources managed through Istio. |
| Edge path | CloudFront, WAF, ALB, Route 53, and ACM Terraform exists. | Modify/Validate | Align it with the AVOS domain, certificates, origins, security policies, and Gateway API path. |
| Kubernetes platform | EKS, LBC, Karpenter, HPA, cert-manager, ExternalDNS, and External Secrets foundations exist. | Keep/Modify | Rebrand, harden, right-size, and validate across approved environments. |
| Observability | Prometheus, Loki, Fluent Bit, Grafana, Kiali, OpenTelemetry, alerting, and X-Ray foundations exist. | Keep/Expand | Standardize telemetry, SLOs, dashboards, ownership, and incident links for every service. |
| Governance | Organizations, SCP, CloudTrail, Config, GuardDuty, Security Hub, Access Analyzer, KMS, and Detective foundations exist. | Keep/Modify | Rebrand policies, validate aggregation, and align evidence retention with AVOS. |
| Customer identity | Cognito is shown in the approved architecture but is not fully implemented. | Add | Implement authentication, token validation, logout, callback URLs, and authorization boundaries. |
| Business analytics | Kinesis, Firehose, S3 lake, Glue, Athena, and QuickSight are architectural targets. | Add | Build raw/curated zones, schemas, transformations, queries, dashboards, and data governance. |
| AIOps | Bedrock, SageMaker, EventBridge, Lambda, OpenSearch, and SSM are architectural targets. | Add | Implement advisory analysis, RAG, approval, safe remediation, and audit feedback. |
| Legacy references | Hundreds of CloudHustler, Cymbal, Hipster, and Google-specific references remain. | Remove/Modify | Replace public identity while preserving attribution and required license notices. |
| Generated artifacts | Compiled test binaries and custom Terraform backup files are present or were previously identified. | Remove | Untrack generated files and strengthen `.gitignore` and secret scanning. |
| Root documentation | No authoritative AVOS root README currently exists. | Add | Create an architecture-led README with status, setup, diagrams, roadmap, and evidence links. |

## Eight-week delivery view

| Week | Primary phases | Exit condition |
|---|---|---|
| 0 | Phase 0 | Baseline evidence, gap register, and architecture decisions are approved. |
| 1 | Phases 1–2 | Repository is clean and Terraform bootstrap/governance foundations validate. |
| 2 | Phases 3–4 | Identity, networking, edge, and customer authentication designs validate. |
| 3 | Phases 5–6 | EKS, managed data, platform controllers, and Gateway API are operational. |
| 4 | Phases 7–8 | CI supply chain and GitOps delivery work for every service. |
| 5 | Phase 9 | Eleven business services deploy and communicate through gRPC. |
| 6 | Phases 10–11 | Observability, incident response, and business analytics validate end to end. |
| 7 | Phase 12 | AI-assisted incident analysis works with human approval and safe remediation. |
| 8 | Phases 13–14 | Reliability, security, cost, recovery, documentation, and final sign-off complete. |

The schedule is an aggressive portfolio delivery target. Security, documentation, testing, and cost controls run continuously rather than being deferred to the final week.

---

# Phase 0 — Baseline Preservation and Architecture Gap Analysis

**Role:** Freeze the inherited baseline, record evidence, and prevent the redesign from erasing useful history or misrepresenting implementation status.

**Dependencies:** Approved AVOS application and project architecture diagrams.

## Steps

| Step | Implementation | Short role | Output |
|---|---|---|---|
| 0.1 | Tag the imported baseline commit. | Creates a recoverable reference before restructuring begins. | `avos-baseline-v1` Git tag. |
| 0.2 | Produce a complete source, workflow, GitOps, Terraform, and documentation inventory. | Establishes exactly what exists before changes are planned. | Baseline inventory. |
| 0.3 | Classify every component as Keep, Modify, Replace, Add, or Remove. | Turns architecture differences into actionable work. | Gap register. |
| 0.4 | Record previously implemented, designed-not-implemented, currently deployed, and AVOS-planned status. | Prevents portfolio documentation from overstating delivery. | Capability-status matrix. |
| 0.5 | Create architecture decision records for the approved major choices. | Preserves the reasoning behind technologies and boundaries. | Initial ADR set. |
| 0.6 | Capture repository and optional runtime evidence without changing infrastructure. | Provides an audit trail for later validation and interviews. | Evidence archive. |

## Tools and resources

| Tool/resource | Short role |
|---|---|
| Git tags | Preserve the exact imported baseline. |
| `rg` and repository inventory scripts | Locate code, legacy references, generated files, and missing coverage. |
| ADRs | Record important architectural decisions and rejected alternatives. |
| Architecture diagrams | Define the target against which gaps are measured. |

## Validation gate

- The baseline tag resolves to the imported source commit.
- Every approved architecture component has a baseline status and disposition.
- No infrastructure or application behavior changes occur during this phase.
- The gap register is reviewed before Phase 1 begins.

## Deliverables

- Baseline inventory
- Keep/Modify/Replace/Add/Remove matrix
- Capability-status matrix
- Initial ADRs
- Baseline evidence index

## Cleanup and cost control

- Do not deploy AWS resources during discovery.
- Store evidence without secrets, Terraform state, tokens, or kubeconfig files.

## Five senior-level explanations

1. **Why preserve the baseline?** A redesign needs a verifiable starting point so regressions and improvements can be measured rather than assumed.
2. **Why classify components first?** Classification reduces unnecessary rewrites and focuses engineering effort on gaps that materially affect the target architecture.
3. **Why separate planned from implemented?** Architectural intent is not operational evidence; senior engineers make that distinction explicit.
4. **Why use ADRs?** ADRs retain context after people and requirements change, making future tradeoffs easier to evaluate.
5. **Why avoid deployment in Phase 0?** Discovery should not introduce cost, risk, or state drift before scope and ownership are understood.

---

# Phase 1 — Repository Rebrand, Hygiene, and Engineering Standards

**Role:** Establish a clean AVOS identity and enforce repository controls before new implementation begins.

**Dependencies:** Phase 0 baseline and gap register approved.

## Steps

| Step | Implementation | Short role | Output |
|---|---|---|---|
| 1.1 | Create the root AVOS README. | Provides the authoritative project entry point and status statement. | `README.md`. |
| 1.2 | Replace CloudHustler, Cymbal, Hipster, and obsolete public branding. | Aligns the repository with the AVOS product identity. | Rebranded source and documentation. |
| 1.3 | Preserve upstream copyright and license notices. | Maintains legal attribution while rebranding the product. | License audit. |
| 1.4 | Remove compiled binaries, state backups, temporary output, and obsolete generated material. | Prevents unsafe and noisy artifacts from remaining in Git. | Clean tracked-file set. |
| 1.5 | Consolidate `.gitignore` rules for Terraform, credentials, languages, IDEs, coverage, and build output. | Prevents local or sensitive artifacts from being recommitted. | Hardened `.gitignore`. |
| 1.6 | Add formatting, linting, secret scanning, and conventional commit guidance. | Creates consistent engineering quality gates. | Contribution standards. |
| 1.7 | Establish CODEOWNERS and branch-protection expectations. | Makes review and ownership explicit. | Ownership policy. |
| 1.8 | Create documentation indexes for architecture, roadmap, ADRs, runbooks, validation, and troubleshooting. | Makes project evidence discoverable. | Documentation navigation. |

## Tools and resources

| Tool/resource | Short role |
|---|---|
| GitHub branch protection | Requires review and successful checks before protected changes merge. |
| CODEOWNERS | Routes changes to accountable reviewers. |
| Pre-commit or equivalent hooks | Runs fast quality checks before code reaches CI. |
| Gitleaks or equivalent secret scanner | Detects accidentally committed credentials and tokens. |
| Markdown linting | Keeps documentation consistent and readable. |

## Validation gate

- No tracked Terraform state, secret, kubeconfig, compiled test binary, or temporary file remains.
- Required upstream licenses remain intact.
- Legacy-reference results are reviewed and accepted exceptions are documented.
- The root README links to the approved diagrams and roadmap.
- Pull-request checks enforce formatting and secret scanning.

## Deliverables

- Root README
- Rebranding report
- Clean `.gitignore`
- Contribution guide and CODEOWNERS
- Documentation index
- Repository hygiene validation record

## Cleanup and cost control

- This phase must not provision infrastructure.
- Remove stale artifacts through version-controlled commits so changes remain reviewable.

## Five senior-level explanations

1. **Why rebrand before feature work?** Identity changes touch source, infrastructure names, URLs, images, and documentation; doing them early avoids repeated churn.
2. **Why preserve license headers?** Product branding can change without removing the legal obligations attached to inherited source code.
3. **Why enforce branch protection?** Git becomes part of the production control plane, so unreviewed changes must not bypass policy.
4. **Why treat documentation as code?** Architecture and runbooks are operational dependencies and should receive the same review and history as application code.
5. **Why clean generated files now?** Clean inputs improve scanning accuracy, reduce repository size, and prevent accidental deployment of stale artifacts.

---

# Phase 2 — Terraform Bootstrap, Environment Model, and State Safety

**Role:** Create repeatable Terraform roots and protected state before provisioning AVOS environments.

**Dependencies:** Repository standards from Phase 1.

## Steps

| Step | Implementation | Short role | Output |
|---|---|---|---|
| 2.1 | Define environment/account strategy for dev, staging, and production. | Establishes isolation, promotion boundaries, and ownership. | Environment design ADR. |
| 2.2 | Rebrand and validate the bootstrap root. | Creates AVOS state resources independently of workload infrastructure. | Bootstrap Terraform root. |
| 2.3 | Configure encrypted S3 remote state with versioning and restrictive bucket policy. | Protects Terraform state and enables recovery. | Remote-state bucket. |
| 2.4 | Configure state locking using the approved backend mechanism. | Prevents concurrent Terraform writers from corrupting state. | State-lock configuration. |
| 2.5 | Create KMS keys and aliases for state and environment encryption. | Centralizes encryption-key control and auditability. | KMS resources. |
| 2.6 | Standardize provider constraints, naming, tagging, locals, and backend keys. | Keeps Terraform roots predictable and supportable. | Terraform conventions. |
| 2.7 | Add validation, formatting, linting, and plan checks. | Detects configuration defects before apply. | Terraform quality workflow. |
| 2.8 | Document bootstrap recovery and state-migration procedures. | Makes state restoration safe and repeatable. | Bootstrap runbook. |

## Tools and resources

| Tool/resource | Short role |
|---|---|
| Terraform | Provisions AVOS infrastructure through reviewed declarative code. |
| S3 remote state | Stores durable encrypted Terraform state. |
| KMS | Encrypts state and other sensitive AVOS data. |
| Native or approved state locking | Serializes Terraform state modifications. |
| `terraform fmt`, `validate`, and plan | Enforce syntax, consistency, and change review. |
| TFLint and Checkov/tfsec | Detect quality, security, and policy issues before deployment. |

## Validation gate

- A clean bootstrap plan succeeds for each intended environment boundary.
- State encryption, versioning, public-access blocking, and least-privilege policies validate.
- Simulated concurrent state access is rejected by locking.
- No backend credentials or state files exist in Git.
- Recovery steps are tested in a non-production sandbox.

## Deliverables

- Environment model ADR
- Bootstrap Terraform root
- State and KMS validation evidence
- Terraform standards document
- Bootstrap recovery runbook

## Cleanup and cost control

- Retain only required state versions according to lifecycle policy.
- Destroy temporary recovery-test resources after validation.

## Five senior-level explanations

1. **Why isolate bootstrap state?** The resources that protect Terraform state cannot safely depend on the same state they are protecting.
2. **Why version state objects?** Versioning provides a recovery path from accidental overwrite or a faulty migration.
3. **Why lock state?** Terraform assumes one writer; locking prevents concurrent runs from creating inconsistent infrastructure records.
4. **Why separate environments?** Isolation reduces blast radius and allows promotion controls to differ from development speed.
5. **Why pin provider constraints?** Controlled upgrades make infrastructure changes reproducible and prevent unexpected provider behavior.

---

# Phase 3 — Organizations, Governance, Human Access, and Audit

**Role:** Establish preventive, detective, identity, and audit controls before application infrastructure expands.

**Dependencies:** Phase 2 state and environment model.

## Steps

| Step | Implementation | Short role | Output |
|---|---|---|---|
| 3.1 | Review AWS Organizations and OU design. | Defines account-level governance and workload boundaries. | Organization hierarchy. |
| 3.2 | Rebrand, test, and attach SCP guardrails. | Prevents high-risk actions at the organization boundary. | Approved SCP set. |
| 3.3 | Configure IAM Identity Center permission sets. | Provides centralized workforce access without long-lived IAM users. | Platform, developer, security, and read-only roles. |
| 3.4 | Configure EKS access entries and Kubernetes RBAC mappings. | Converts AWS identity into controlled Kubernetes permissions. | Cluster access model. |
| 3.5 | Enable organization-aware CloudTrail and protected log storage. | Creates an immutable audit history of AWS API activity. | CloudTrail evidence trail. |
| 3.6 | Enable AWS Config rules and aggregation. | Detects configuration drift and noncompliant resources. | Config compliance baseline. |
| 3.7 | Enable GuardDuty, Security Hub, Access Analyzer, and Detective. | Detects threats, centralizes findings, exposes unintended access, and supports investigations. | Security detection baseline. |
| 3.8 | Define findings ownership, severity, response SLAs, and evidence retention. | Converts security services into an operating process. | Governance runbook. |

## Tools and resources

| Tool/resource | Short role |
|---|---|
| AWS Organizations | Groups accounts and applies centralized governance. |
| SCPs | Set maximum account permissions without granting access themselves. |
| IAM Identity Center | Provides SSO and permission-set-based workforce access. |
| EKS access entries | Manage authenticated human access to Kubernetes. |
| Kubernetes RBAC | Authorizes permitted actions inside the cluster. |
| CloudTrail | Records AWS API activity for audit and investigation. |
| AWS Config | Evaluates configuration compliance and drift. |
| GuardDuty | Detects suspicious AWS activity and threats. |
| Security Hub | Aggregates and prioritizes security findings. |
| Access Analyzer | Identifies external or unintended resource access. |
| Detective | Correlates evidence during security investigations. |

## Validation gate

- Permission sets and EKS RBAC pass positive and negative access tests.
- SCPs deny prohibited actions without blocking approved deployment workflows.
- CloudTrail logs are encrypted, retained, and protected from unauthorized deletion.
- Config aggregation and representative compliance rules report correctly.
- GuardDuty and Security Hub sample findings reach the assigned response path.

## Deliverables

- Organization and access diagrams
- Permission-set and RBAC matrix
- SCP test report
- Governance Terraform outputs
- Security findings and audit runbook

## Cleanup and cost control

- Set intentional log-retention periods instead of unlimited defaults.
- Remove temporary users, policies, sample findings, and test roles after validation.

## Five senior-level explanations

1. **Why combine Identity Center with EKS RBAC?** Authentication proves who the operator is; RBAC separately limits what that identity can do inside Kubernetes.
2. **Why do SCPs not replace IAM?** SCPs define permission ceilings, while IAM policies and roles grant the permissions workloads and people actually use.
3. **Why centralize audit logs?** Central storage reduces the chance that a compromised workload account can erase its own evidence.
4. **Why assign findings ownership?** Security tools without owners and response targets produce dashboards rather than risk reduction.
5. **Why validate denied behavior?** Least privilege is proven by confirming that unauthorized actions fail, not only that permitted actions succeed.

---

# Phase 4 — Networking, Edge Security, TLS, and Customer Identity

**Role:** Build the private Multi-AZ network and the approved customer request path from DNS to the EKS ingress boundary.

**Dependencies:** Phases 2–3; approved domain and environment names.

## Steps

| Step | Implementation | Short role | Output |
|---|---|---|---|
| 4.1 | Provision the AVOS VPC and address plan across at least two Availability Zones. | Creates the network isolation boundary for the platform. | Multi-AZ VPC. |
| 4.2 | Create public, private application, and private database subnets per AZ. | Separates internet-facing, compute, and data tiers. | Tagged subnet tiers. |
| 4.3 | Configure Internet Gateway, NAT gateway per AZ, route tables, and VPC endpoints. | Provides controlled ingress, resilient egress, and private AWS service access. | Network routing. |
| 4.4 | Implement security groups, network ACL decisions, and VPC Flow Logs. | Restricts traffic and preserves network evidence. | Network controls. |
| 4.5 | Configure Route 53 records and hosted-zone ownership. | Resolves AVOS domains to approved edge endpoints. | DNS records. |
| 4.6 | Provision separate ACM certificates where CloudFront and regional ALB requirements differ. | Provides correctly scoped TLS certificates. | Validated certificates. |
| 4.7 | Configure CloudFront cache, origin, compression, and response-header policies. | Improves edge performance and standardizes secure responses. | CloudFront distribution. |
| 4.8 | Configure WAF managed rules, rate limiting, IP reputation, logging, and alarms. | Filters malicious and abusive traffic before it reaches EKS. | WAF web ACL. |
| 4.9 | Provision the ALB through AWS Load Balancer Controller integration. | Terminates or forwards approved traffic toward the Istio gateway. | Internet-facing ALB. |
| 4.10 | Create Cognito user pool, app client, domain, callback URLs, and token policy. | Adds customer authentication and standards-based tokens. | Cognito configuration. |
| 4.11 | Define JWT validation and authorization placement at the frontend/Istio boundary. | Ensures protected requests are authenticated before business processing. | Authentication design. |
| 4.12 | Validate the request path without exposing private nodes or services. | Proves the edge design and network boundary. | End-to-end edge evidence. |

## Tools and resources

| Tool/resource | Short role |
|---|---|
| Amazon VPC | Provides isolated networking for AVOS resources. |
| Public subnets | Host internet-facing load-balancer and egress resources. |
| Private application subnets | Host EKS nodes and private application endpoints. |
| Private database subnets | Isolate Aurora and ElastiCache from public routing. |
| NAT gateways | Provide resilient outbound access from private subnets. |
| VPC endpoints | Keep supported AWS-service traffic off the public internet. |
| Route 53 | Provides authoritative DNS for AVOS. |
| ACM | Issues and manages TLS certificates. |
| CloudFront | Delivers cached content and provides the global edge entry point. |
| AWS WAF | Applies managed and custom web-traffic protections. |
| ALB | Routes HTTPS traffic to the Istio ingress gateway. |
| Amazon Cognito | Manages customer identities and OIDC/JWT authentication. |

## Validation gate

- Subnet routing and security-group reachability match the approved data flows.
- Each AZ has an independent approved egress path or a documented lower-cost deviation.
- VPC Flow Logs reach the approved destination.
- DNS and TLS validate for all required AVOS names.
- WAF test requests trigger expected allow, block, rate-limit, log, and alarm behavior.
- An authenticated customer reaches a protected route and an invalid token is denied.
- Direct public access to nodes, databases, and internal services fails.

## Deliverables

- Network and edge Terraform
- CIDR, subnet, route, and security-group matrix
- DNS/TLS/WAF evidence
- Cognito configuration and authentication flow
- Edge troubleshooting and rollback runbook

## Cleanup and cost control

- Use lifecycle and retention policies for WAF, CloudFront, and Flow Log storage.
- Remove test domains, certificates, WAF rules, and temporary endpoints.
- Document the high availability versus cost tradeoff of NAT gateways per AZ.

## Five senior-level explanations

1. **Why separate subnet tiers?** Tiered subnets reduce exposure and allow routing and security controls to match workload sensitivity.
2. **Why place CloudFront and WAF before ALB?** Edge filtering and caching reduce origin load while blocking malicious traffic earlier.
3. **Why can CloudFront and ALB require separate certificates?** CloudFront certificate placement differs from regional ALB certificate placement, so certificate scope must follow the service endpoint.
4. **Why use Cognito without changing internal gRPC?** Cognito authenticates external customers; internal service-to-service communication remains a separate trusted and authorized channel.
5. **Why use a NAT gateway per AZ?** Per-AZ egress avoids cross-AZ dependency and data charges during an Availability Zone failure, at higher fixed cost.

---

# Phase 5 — EKS Compute, Storage, and Managed Data Foundation

**Role:** Provide resilient Kubernetes capacity and private managed data services before deploying AVOS business workloads.

**Dependencies:** Phase 4 networking; Phase 3 identity and KMS controls.

## Steps

| Step | Implementation | Short role | Output |
|---|---|---|---|
| 5.1 | Rebrand and provision the EKS control plane in private application subnets. | Provides the managed Kubernetes API and scheduling control plane. | AVOS EKS cluster. |
| 5.2 | Configure private endpoint access with controlled administrative access. | Reduces control-plane exposure while preserving operations access. | Cluster endpoint policy. |
| 5.3 | Enable core EKS add-ons and EKS Pod Identity Agent. | Provides supported cluster networking, DNS, proxying, and workload identity. | Managed add-ons. |
| 5.4 | Create a small managed node group for baseline system capacity. | Ensures critical controllers have stable compute independent of dynamic scaling. | System node group. |
| 5.5 | Configure Karpenter NodeClasses and NodePools. | Adds workload-driven capacity using approved instance types and limits. | Dynamic compute pools. |
| 5.6 | Configure HPA prerequisites and resource-request standards. | Enables safe pod scaling based on measurable demand. | Scaling baseline. |
| 5.7 | Configure encrypted gp3 StorageClass and EBS CSI identity. | Provides dynamic persistent volumes for workloads that require them. | Storage baseline. |
| 5.8 | Provision private Multi-AZ Aurora PostgreSQL. | Provides durable relational storage with managed failover and backup. | Aurora cluster. |
| 5.9 | Provision private ElastiCache for Redis. | Moves cart state outside pod lifecycle and improves availability. | Redis replication group. |
| 5.10 | Configure Secrets Manager records, security groups, subnet groups, encryption, backups, and maintenance windows. | Secures and operationalizes database access. | Managed data controls. |
| 5.11 | Define database migration ownership and connectivity tests. | Makes schema changes repeatable and service ownership explicit. | Migration workflow. |

## Tools and resources

| Tool/resource | Short role |
|---|---|
| Amazon EKS | Runs and orchestrates AVOS containers. |
| Managed node group | Provides stable capacity for essential platform controllers. |
| Karpenter | Provisions right-sized nodes in response to unschedulable workloads. |
| HPA | Scales application replicas using resource or custom metrics. |
| EKS Pod Identity | Supplies short-lived AWS permissions to Kubernetes service accounts. |
| EBS CSI driver | Creates and attaches encrypted EBS volumes for persistent workloads. |
| Aurora PostgreSQL | Stores durable relational AVOS data. |
| ElastiCache for Redis | Stores low-latency cart state. |
| AWS Secrets Manager | Stores database credentials and application secrets. |

## Validation gate

- Cluster nodes span approved Availability Zones and private subnets.
- System workloads remain schedulable when Karpenter capacity scales down.
- Karpenter provisions and consolidates an approved test workload within configured limits.
- HPA responds to a controlled metrics test.
- Encrypted PVC provisioning succeeds.
- Aurora failover, backup, restore, and TLS connectivity validate.
- Redis write/read, failover, encryption, and authentication validate.
- No database endpoint is publicly reachable.

## Deliverables

- EKS and managed-data Terraform
- Capacity and scaling policy
- Database connectivity and migration standards
- Backup/restore evidence
- EKS, Aurora, and Redis operational runbooks

## Cleanup and cost control

- Keep the managed node group at the smallest safe baseline and cap Karpenter NodePool resources.
- Use scheduled non-production scaling or hibernation procedures where technically safe.
- Select Aurora and Redis sizes from measured demand and enable cost alarms.
- Delete load-test databases, snapshots, and unused volumes after evidence is captured.

## Five senior-level explanations

1. **Why retain a managed node group with Karpenter?** Stable baseline nodes protect critical controllers while Karpenter handles elastic application capacity.
2. **Why replace the Redis pod?** A pod-scoped datastore couples cart durability to cluster events; managed Redis provides stronger availability, backup, and maintenance controls.
3. **Why require resource requests before HPA/Karpenter?** Schedulers and autoscalers need credible requests to make safe capacity decisions.
4. **Why isolate databases in private subnets?** Application access should traverse controlled security groups rather than public routing.
5. **Why test restore rather than only backup?** A backup has no demonstrated recovery value until restoration and application compatibility are verified.

---

# Phase 6 — Platform Controllers, Secrets, and Istio Gateway API

**Role:** Install the Kubernetes control services required for secure ingress, DNS, certificates, secrets, scaling, and service-mesh behavior.

**Dependencies:** Phase 5 EKS capacity; Phase 4 ALB, DNS, and certificates.

## Steps

| Step | Implementation | Short role | Output |
|---|---|---|---|
| 6.1 | Install AWS Load Balancer Controller with Pod Identity. | Reconciles Kubernetes load-balancing resources into AWS ALB resources. | LBC deployment. |
| 6.2 | Install ExternalDNS with scoped Route 53 permissions. | Synchronizes approved Kubernetes DNS records into Route 53. | DNS controller. |
| 6.3 | Install External Secrets Operator. | Synchronizes Secrets Manager values into namespaced Kubernetes Secrets. | Secret controller. |
| 6.4 | Install cert-manager and approved issuers. | Automates certificates needed inside the Kubernetes boundary. | Certificate controller. |
| 6.5 | Install Istio control plane and ingress gateway. | Provides service-mesh traffic management, mTLS, policy, and ingress. | Istio platform. |
| 6.6 | Replace legacy Istio `Gateway`/`VirtualService` objects with Gateway API resources. | Aligns ingress routing with the approved portable API model. | GatewayClass, Gateway, and HTTPRoute. |
| 6.7 | Connect ALB targets to the Istio gateway through the approved LBC integration. | Completes the edge-to-cluster request path. | Healthy ALB targets. |
| 6.8 | Define mesh-wide mTLS, authorization, retry, timeout, and outlier-detection defaults. | Standardizes service-to-service security and resilience. | Istio policies. |
| 6.9 | Apply PodDisruptionBudgets, topology spread, probes, and priority classes to critical controllers. | Protects the platform during upgrades and node disruption. | Controller resilience policies. |
| 6.10 | Validate controller ownership and remove duplicate or legacy ingress controllers. | Prevents resource conflicts and ambiguous traffic ownership. | Single ingress control model. |

## Tools and resources

| Tool/resource | Short role |
|---|---|
| AWS Load Balancer Controller | Provisions and manages AWS load-balancing resources from Kubernetes intent. |
| ExternalDNS | Manages Route 53 records from approved Kubernetes resources. |
| External Secrets | Delivers AWS-managed secrets to workloads without storing them in Git. |
| cert-manager | Automates internal Kubernetes certificate issuance and renewal. |
| Istio | Secures and observes service-to-service traffic. |
| Gateway API | Defines portable gateway and route resources. |
| HTTPRoute | Maps hostnames and paths to Kubernetes Services. |
| PodDisruptionBudget | Maintains minimum availability during voluntary disruptions. |

## Validation gate

- Every controller uses a dedicated service account and least-privilege AWS identity where required.
- Route 53, secret synchronization, and certificate renewal tests succeed.
- `Route 53 → CloudFront/WAF → ALB → Istio Gateway → Frontend` returns expected responses.
- Legacy NGINX Ingress and duplicate routing objects are absent from the primary path.
- Mesh mTLS and authorization tests allow intended traffic and deny unintended traffic.
- Controller disruption tests preserve the minimum required availability.

## Deliverables

- Platform-controller Terraform and values
- Gateway API manifests
- Istio security and resilience policies
- Controller identity matrix
- Edge-to-service validation evidence
- Platform-services troubleshooting runbook

## Cleanup and cost control

- Remove legacy ingress controllers, unused load balancers, duplicate target groups, and stale DNS records.
- Set controller replica counts appropriate to each environment.

## Five senior-level explanations

1. **Why use Gateway API with Istio?** Gateway API separates portable routing intent from the implementation while retaining Istio’s mesh capabilities.
2. **Why remove duplicate ingress controllers?** Multiple controllers can race to own the same resources, increase cost, and complicate incident diagnosis.
3. **Why use External Secrets?** Git references secret intent while Secrets Manager retains the sensitive value and rotation lifecycle.
4. **Why use Pod Identity?** It provides short-lived, workload-scoped AWS credentials without exposing node-role permissions to every pod.
5. **Why define mesh defaults centrally?** Consistent timeouts, retries, mTLS, and policy reduce service-by-service configuration drift.

---

# Phase 7 — CI, Software Supply Chain, and ECR Publication

**Role:** Build a secure, reusable CI system that publishes immutable artifacts without deploying or changing GitOps manifests.

**Dependencies:** Phase 1 repository controls; Phase 3 IAM/OIDC; ECR repositories available.

## Steps

| Step | Implementation | Short role | Output |
|---|---|---|---|
| 7.1 | Refactor the reusable workflow around service name, path, runtime, and ECR repository inputs. | Provides one governed CI pattern for polyglot services. | Reusable CI workflow. |
| 7.2 | Add CI callers for ad, email, recommendation, shopping assistant, and load generator. | Closes current workflow coverage gaps. | Complete workflow set. |
| 7.3 | Standardize language-specific dependency, lint, unit-test, and build commands. | Preserves runtime needs while enforcing common quality gates. | Service test matrix. |
| 7.4 | Add protobuf compatibility and generated-code drift checks. | Prevents breaking gRPC contract changes and stale generated clients. | Contract checks. |
| 7.5 | Scan source, dependencies, filesystem, IaC, and container images. | Detects vulnerabilities and misconfiguration before publication. | Security scan evidence. |
| 7.6 | Generate an SBOM and build provenance for each image. | Records what was built and where it came from. | Supply-chain metadata. |
| 7.7 | Authenticate to AWS through GitHub OIDC. | Removes long-lived AWS keys from CI. | Short-lived CI access. |
| 7.8 | Build each service image once and tag it with the full or approved shortened commit SHA. | Creates traceable immutable artifacts. | SHA-tagged images. |
| 7.9 | Push images to service-specific ECR repositories with immutability and lifecycle policies. | Publishes controlled deployable artifacts. | ECR image set. |
| 7.10 | Sign images and define verification policy where supported by the deployment design. | Adds artifact integrity and provenance assurance. | Signed image evidence. |
| 7.11 | Remove every CI step that edits GitOps image tags or runs `kubectl apply`. | Preserves Image Updater and Argo CD ownership boundaries. | Build-only CI. |
| 7.12 | Add protected environment approvals for sensitive CI operations. | Requires authorized review for production-scoped actions. | GitHub environment controls. |
| 7.13 | Publish logs, test reports, scan reports, SBOMs, and digests as workflow evidence. | Makes each artifact independently auditable. | CI evidence bundle. |

## Tools and resources

| Tool/resource | Short role |
|---|---|
| GitHub Actions | Automates tests, scans, builds, and publication. |
| GitHub OIDC | Exchanges GitHub identity for short-lived AWS credentials. |
| Amazon ECR | Stores immutable AVOS container images. |
| Trivy | Scans source, dependencies, IaC, and images for vulnerabilities and misconfiguration. |
| SBOM tooling | Lists packaged software components for audit and response. |
| Image signing | Verifies artifact integrity and build provenance. |
| Protobuf compatibility checks | Protect gRPC clients from breaking schema changes. |

## Validation gate

- All 11 business services and `loadgenerator` execute the reusable CI path.
- A pull request cannot publish an untested or critically vulnerable image under the approved policy.
- AWS authentication uses OIDC and no long-lived access keys.
- ECR rejects mutable overwrite behavior according to repository policy.
- Image digest, source commit, SBOM, scan, and provenance can be correlated.
- CI contains no GitOps write-back and no cluster deployment command.

## Deliverables

- Reusable workflow and service callers
- CI coverage matrix
- OIDC and ECR Terraform
- Security and supply-chain evidence
- CI troubleshooting runbook

## Cleanup and cost control

- Apply ECR lifecycle policies to unreferenced development images while preserving promoted releases.
- Use dependency and build caching with bounded retention.
- Delete failed experimental repositories after migration evidence is captured.

## Five senior-level explanations

1. **Why build once?** Promoting the same digest across environments avoids rebuilding different artifacts from nominally identical source.
2. **Why stop CI at ECR?** CI proves and publishes the artifact, while GitOps independently controls when desired state changes reach a cluster.
3. **Why use OIDC?** Short-lived credentials eliminate stored cloud keys and bind access to repository, workflow, branch, and environment claims.
4. **Why generate SBOM and provenance?** Vulnerability response requires knowing which components exist and which trusted process produced the artifact.
5. **Why test protobuf compatibility?** A syntactically valid schema change can still break independently deployed gRPC clients.

---

# Phase 8 — GitOps, Image Updater, Environment Promotion, and Rollback

**Role:** Make Git the auditable desired-state authority and automate image promotion without giving CI deployment privileges.

**Dependencies:** Phases 6–7; complete service manifests; protected Git branches.

## Steps

| Step | Implementation | Short role | Output |
|---|---|---|---|
| 8.1 | Rebrand Argo CD projects, applications, destinations, and repository references. | Removes inherited identity and defines AVOS GitOps boundaries. | AVOS Argo CD model. |
| 8.2 | Complete base manifests for all 11 business services and the load generator. | Gives every deployable component a declared Kubernetes state. | Complete Kustomize bases. |
| 8.3 | Build dev, staging, and production overlays. | Separates environment-specific replicas, resources, endpoints, and policies. | Environment overlays. |
| 8.4 | Add App-of-Apps or ApplicationSet orchestration. | Manages the complete platform consistently at scale. | Root application model. |
| 8.5 | Configure Argo CD Image Updater with ECR discovery and Git write-back. | Makes Image Updater the sole automated image-tag owner. | ImageUpdater resources. |
| 8.6 | Use Kustomize `newTag`/digest or the approved write-back target. | Stores the deployable image decision in Git. | Versioned image update. |
| 8.7 | Configure GitHub App or tightly scoped credentials for write-back. | Allows controlled commits without broad personal credentials. | Git write-back identity. |
| 8.8 | Use direct write-back for approved development automation and PR mode for protected staging/production promotion. | Balances delivery speed with review and approval. | Promotion workflow. |
| 8.9 | Configure automated sync, prune, self-heal, sync waves, health checks, and retry policy by environment. | Defines safe reconciliation behavior. | Argo CD sync policy. |
| 8.10 | Implement drift detection and notification. | Exposes changes made outside Git. | Drift alerts. |
| 8.11 | Test rollback by reverting the Git image change to a known-good digest. | Proves recovery without bypassing GitOps. | Rollback evidence. |
| 8.12 | Restrict Argo CD and Image Updater permissions to required namespaces, repositories, and registries. | Limits GitOps control-plane blast radius. | Least-privilege GitOps. |

## Tools and resources

| Tool/resource | Short role |
|---|---|
| Argo CD | Reconciles Kubernetes desired state from Git. |
| Argo CD Image Updater | Detects approved images and commits image changes to Git. |
| Kustomize | Composes reusable bases with environment-specific overlays. |
| ApplicationSet | Generates and manages repeated Argo CD Applications. |
| GitHub App | Provides scoped, auditable Git write-back credentials. |
| Sync waves | Order dependent Kubernetes resources during reconciliation. |

## Validation gate

- ECR image publication alone does not change the cluster until Git desired state changes.
- Image Updater creates the expected development commit or protected-environment PR.
- Argo CD detects the commit and reaches Synced/Healthy state.
- Manual cluster drift is detected and handled according to policy.
- A Git revert returns the application to the known-good image digest.
- CI has no Kubernetes credentials and Argo CD does not build images.

## Deliverables

- Complete GitOps bases and overlays
- Argo CD project/application model
- Image Updater configuration
- Promotion and rollback evidence
- GitOps operations runbook

## Cleanup and cost control

- Remove obsolete Argo CD applications, Redis pod manifests, and legacy Istio routing after replacement validation.
- Avoid duplicate controllers across namespaces or Terraform states.

## Five senior-level explanations

1. **Why make Image Updater the only tag writer?** A single owner prevents competing commits, nondeterministic promotion, and unclear audit trails.
2. **Why use Git write-back?** The selected image remains durable, reviewable, and reproducible from Git rather than existing only as cluster state.
3. **Why use PR promotion for production?** Production changes need separation of duties, review evidence, and explicit approval even when image discovery is automated.
4. **Why rollback through Git?** Reverting desired state preserves auditability and allows Argo CD to perform the same controlled reconciliation path.
5. **Why separate CI and CD credentials?** Compromising a build workflow should not automatically grant the ability to modify a running cluster.

---

# Phase 9 — AVOS Microservices Modernization and gRPC Integration

**Role:** Deploy the complete AVOS application, standardize internal contracts, and replace inherited dependencies that conflict with the target architecture.

**Dependencies:** Phases 5–8; Aurora, Redis, secrets, CI, and GitOps operational.

## Service implementation matrix

| Service | Language | Disposition | Short role |
|---|---|---|---|
| `frontend` | Go | Modify | Serves the AVOS website, manages sessions, and coordinates backend calls. |
| `cartservice` | C# | Modify | Manages customer carts using ElastiCache Redis. |
| `productcatalogservice` | Go | Keep/Modify | Lists, searches, and retrieves products from the initial JSON catalog. |
| `currencyservice` | Node.js | Modify | Converts prices and receives the highest expected request rate. |
| `paymentservice` | Node.js | Modify | Simulates payment processing and returns transaction identifiers. |
| `shippingservice` | Go | Modify | Estimates shipping cost and simulates shipment creation. |
| `emailservice` | Python | Modify | Sends simulated or sandboxed order-confirmation messages. |
| `checkoutservice` | Go | Modify | Orchestrates cart retrieval, pricing, payment, shipping, and confirmation. |
| `recommendationservice` | Python | Modify | Produces product recommendations from customer shopping context. |
| `adservice` | Java | Modify | Returns contextual promotional advertisements. |
| `shoppingassistantservice` | Python | Replace | Provides AWS-native AI-assisted product discovery through gRPC. |
| `loadgenerator` | Python/Locust | Keep/Modify | Generates realistic test traffic and is not counted as a business microservice. |

## Steps

| Step | Implementation | Short role | Output |
|---|---|---|---|
| 9.1 | Establish central protobuf ownership and generation conventions. | Creates one authoritative contract source for all languages. | Versioned protobuf API. |
| 9.2 | Define request deadlines, cancellation, retry eligibility, and idempotency per RPC. | Prevents cascading failures and unsafe duplicate operations. | gRPC policy matrix. |
| 9.3 | Add standard gRPC health, readiness, and graceful-shutdown behavior. | Supports safe Kubernetes lifecycle management. | Health-capable services. |
| 9.4 | Add OpenTelemetry context propagation to every service. | Connects traces across polyglot gRPC calls. | Distributed tracing. |
| 9.5 | Rebrand the frontend, product data, sessions, URLs, assets, and public text. | Delivers the African Vibe Online Shop customer identity. | AVOS user experience. |
| 9.6 | Connect cartservice to ElastiCache using TLS and Secrets Manager credentials. | Moves cart persistence to the approved managed datastore. | Managed cart state. |
| 9.7 | Define Aurora schema owners, migrations, and connection pooling for services that need relational data. | Prevents shared-database ambiguity and uncontrolled schema change. | Managed relational persistence. |
| 9.8 | Retain the JSON catalog for the first release and document its operational limits. | Avoids premature database migration without a demonstrated need. | Stable initial catalog. |
| 9.9 | Replace shopping assistant Google dependencies with Bedrock, OpenSearch, and Secrets Manager. | Aligns the AI service with the AWS architecture. | AWS-native assistant. |
| 9.10 | Expose the shopping assistant through a protobuf-defined gRPC API. | Makes the assistant consistent with internal communication standards. | Assistant gRPC contract. |
| 9.11 | Add resource requests/limits, HPA policy, PDBs, probes, and topology spread for each service. | Makes application reliability and scaling explicit. | Production workload policies. |
| 9.12 | Add NetworkPolicies and Istio AuthorizationPolicies. | Restricts service communication to approved dependencies. | Service access controls. |
| 9.13 | Run unit, contract, integration, checkout, failure-injection, and load tests. | Proves service behavior and dependency handling. | Application validation evidence. |

## Tools and resources

| Tool/resource | Short role |
|---|---|
| Protocol Buffers | Defines language-neutral AVOS service contracts. |
| gRPC | Carries typed internal service requests. |
| Istio mTLS | Encrypts and authenticates service-to-service traffic. |
| OpenTelemetry SDKs | Propagate traces and application telemetry. |
| Aurora PostgreSQL | Persists durable relational business data. |
| ElastiCache Redis | Persists low-latency cart data. |
| Bedrock and OpenSearch | Power the AWS-native shopping assistant. |
| Locust | Generates realistic customer behavior for validation. |

## Validation gate

- All 11 business services are Synced, Healthy, ready, and reachable only through intended paths.
- The complete browse, cart, checkout, payment, shipping, recommendation, ad, email, and assistant journeys succeed.
- Protobuf compatibility checks pass across all client languages.
- Redis and Aurora failures degrade safely and recover according to policy.
- A complete customer request produces a correlated distributed trace.
- Network and authorization policy negative tests deny unauthorized service calls.
- Load generation causes expected HPA/Karpenter behavior without unacceptable errors.

## Deliverables

- AVOS-branded application
- Authoritative protobuf contracts
- Complete service CI/GitOps coverage
- Managed data integration
- AWS-native shopping assistant
- Application dependency and failure matrix
- End-to-end test evidence

## Cleanup and cost control

- Remove Google SDKs, credentials, AlloyDB references, obsolete embeddings, and unused packages.
- Run load generation only during controlled test windows.
- Right-size requests, limits, HPA targets, and Karpenter capacity from measured results.

## Five senior-level explanations

1. **Why keep gRPC internal and HTTPS external?** Each protocol serves a different trust boundary and client type without forcing browsers to communicate like internal services.
2. **Why centralize protobuf ownership?** Shared contracts prevent independent generated copies from drifting across languages.
3. **Why retain JSON initially?** Architecture should solve demonstrated scale and operational needs rather than add database complexity prematurely.
4. **Why make checkout orchestration observable?** Checkout crosses many dependencies, so trace context is essential for isolating latency and partial failure.
5. **Why treat loadgenerator separately?** It validates capacity and resilience but does not own customer-facing business capability.

---

# Phase 10 — Observability, SLOs, Alerting, and Incident Response

**Role:** Turn metrics, logs, traces, deployment state, and AWS health into actionable operational signals and response procedures.

**Dependencies:** Phase 9 service instrumentation; Phase 6 platform services.

## Steps

| Step | Implementation | Short role | Output |
|---|---|---|---|
| 10.1 | Define service-level indicators and objectives for customer journeys and critical services. | Connects platform health to measurable user outcomes. | SLI/SLO catalog. |
| 10.2 | Standardize Prometheus service metrics, kube-state metrics, node metrics, and Istio metrics. | Provides consistent workload and infrastructure measurements. | Metrics baseline. |
| 10.3 | Configure Fluent Bit to ship application and platform logs to Loki. | Centralizes searchable Kubernetes logs. | Logging pipeline. |
| 10.4 | Configure OpenTelemetry Collector pipelines and AWS X-Ray export. | Aggregates distributed traces and sends them to the approved backend. | Tracing pipeline. |
| 10.5 | Build Grafana dashboards for golden signals, checkout, capacity, databases, ingress, and business health. | Gives operators role-specific operational views. | Dashboard catalog. |
| 10.6 | Configure Kiali for service-mesh topology and traffic diagnosis. | Visualizes service dependencies, policies, and request health. | Mesh dashboard. |
| 10.7 | Create PrometheusRule alerts tied to SLOs and service ownership. | Detects actionable application and Kubernetes failures. | Workload alerts. |
| 10.8 | Create CloudWatch alarms for AWS services and edge dependencies. | Detects managed-service and infrastructure failures. | AWS alarms. |
| 10.9 | Route Prometheus through Alertmanager and AWS alarms through SNS/EventBridge as designed. | Preserves native alert paths while converging notification and automation. | Alert routing. |
| 10.10 | Configure severity-based SNS delivery to Slack, email, and on-call targets. | Delivers incidents to the appropriate responders. | Notification channels. |
| 10.11 | Attach owner, severity, dashboard, trace, and runbook metadata to alerts. | Makes notifications actionable instead of merely informative. | Enriched alerts. |
| 10.12 | Conduct incident exercises and blameless postmortems. | Validates detection, response, learning, and corrective-action tracking. | Incident evidence. |

## Tools and resources

| Tool/resource | Short role |
|---|---|
| Prometheus | Collects and evaluates Kubernetes, application, and mesh metrics. |
| Alertmanager | Groups, deduplicates, inhibits, and routes Prometheus alerts. |
| Fluent Bit | Collects and forwards Kubernetes logs. |
| Loki | Stores and queries Kubernetes logs cost-effectively. |
| OpenTelemetry Collector | Receives, processes, and exports telemetry. |
| AWS X-Ray | Stores and visualizes distributed traces. |
| Grafana | Presents correlated metrics, logs, and operational dashboards. |
| Kiali | Visualizes Istio service-mesh topology and traffic health. |
| CloudWatch | Monitors AWS services and infrastructure signals. |
| Amazon SNS | Fans out severity-based incident notifications. |

## Validation gate

- Each critical customer journey has defined SLI, SLO, dashboard, owner, and alert.
- A request can be correlated across metrics, logs, and traces using shared context.
- Synthetic failures trigger the correct alert path without excessive duplicates.
- Critical alerts reach on-call; warnings follow the nonpaging route.
- Runbook, dashboard, and trace links in alerts resolve successfully.
- The incident exercise produces a postmortem and tracked corrective actions.

## Deliverables

- SLI/SLO catalog
- Dashboard and alert catalog
- Telemetry architecture and retention policy
- Incident response runbook
- Exercise and postmortem evidence

## Cleanup and cost control

- Set log, metric, and trace retention based on operational value.
- Use sampling, filtering, cardinality controls, and bounded dashboard queries.
- Remove noisy alerts rather than teaching responders to ignore them.

## Five senior-level explanations

1. **Why define SLOs before alerts?** Alerts should indicate threatened user outcomes, not merely that a metric changed.
2. **Why keep Loki and add OpenSearch?** Loki remains the Kubernetes logging platform, while OpenSearch serves operational search and vector retrieval use cases.
3. **Why enrich alerts?** Responders lose critical time when they must manually discover ownership, evidence, and recovery instructions.
4. **Why separate Prometheus and CloudWatch paths?** Each system detects different domains and should use its native evaluation model before notifications converge.
5. **Why run incident exercises?** Monitoring configuration is only a hypothesis until detection, escalation, diagnosis, and recovery are practiced end to end.

---

# Phase 11 — Streaming Data Lake, Business Analytics, and Visualization

**Role:** Convert AVOS business events into governed historical data, SQL analysis, dashboards, and machine-learning inputs.

**Dependencies:** Phase 9 event definitions; Phase 3 governance; Phase 10 telemetry boundaries.

## Steps

| Step | Implementation | Short role | Output |
|---|---|---|---|
| 11.1 | Define approved business-event schemas and ownership. | Prevents analytics events from becoming unversioned application side effects. | Event catalog. |
| 11.2 | Instrument selected services to publish noncritical business events. | Produces analytics data without coupling checkout success to analytics availability. | Event producers. |
| 11.3 | Provision Kinesis Data Streams with encryption, retention, and scaling policy. | Buffers live AVOS events for multiple consumers. | Event stream. |
| 11.4 | Configure separate Firehose delivery streams where S3 and OpenSearch both consume events. | Delivers the same source stream to purpose-specific destinations. | Delivery streams. |
| 11.5 | Configure Firehose transformation, compression, partitioning, and failure backup. | Produces query-efficient data and preserves failed records. | Delivery policy. |
| 11.6 | Create encrypted S3 raw, curated, query-result, and failure zones. | Separates immutable source data from processed analytical data. | Data lake zones. |
| 11.7 | Configure Glue Crawlers and Data Catalog databases. | Discovers and stores table metadata for analytical engines. | Cataloged datasets. |
| 11.8 | Build Glue ETL jobs that validate, clean, partition, and convert data to Parquet. | Produces efficient, governed curated datasets. | Curated data. |
| 11.9 | Configure Athena workgroups, result locations, limits, and saved queries. | Enables governed serverless SQL over S3. | Athena analytics. |
| 11.10 | Build QuickSight datasets and dashboards for sales, products, customer behavior, and operations. | Presents governed business insight to authorized users. | BI dashboards. |
| 11.11 | Define data retention, access, masking, quality, and deletion rules. | Protects customer data and controls analytical cost. | Data governance policy. |
| 11.12 | Export approved features or datasets for SageMaker use. | Supplies reproducible inputs for anomaly and predictive models. | ML-ready datasets. |

## Tools and resources

| Tool/resource | Short role |
|---|---|
| Kinesis Data Streams | Ingests and buffers high-volume AVOS events. |
| Amazon Data Firehose | Batches, transforms, and delivers streaming data. |
| Amazon S3 | Stores raw, curated, failed, and query-result data. |
| AWS Glue Crawler | Discovers schemas and partitions. |
| Glue Data Catalog | Stores analytical table metadata. |
| AWS Glue ETL | Cleans and transforms raw data into curated datasets. |
| Amazon Athena | Runs SQL directly against cataloged S3 data. |
| Amazon QuickSight | Visualizes authorized analytical results. |
| OpenSearch operational collection | Supports near-real-time event and operational search. |

## Validation gate

- Event publication failure cannot block customer checkout.
- Kinesis retains and replays test events according to policy.
- Firehose delivers valid events to S3 and selected events to the operational OpenSearch collection.
- Invalid records reach the failure zone with diagnostic metadata.
- Glue catalogs raw data and produces partitioned Parquet in the curated zone.
- Athena queries return reconciled totals within scan-cost limits.
- QuickSight access and dashboards match authorized user roles.

## Deliverables

- Event schema catalog
- Streaming and data-lake Terraform
- Glue catalog and ETL jobs
- Athena workgroups and queries
- QuickSight dashboard definitions
- Data governance and cost runbook

## Cleanup and cost control

- Partition and compress data to reduce Athena scan volume.
- Apply S3 lifecycle transitions and deletion rules by data class.
- Set Kinesis retention and shard/on-demand choices from measured traffic.
- Shut down test delivery streams, crawlers, and dashboards after validation where appropriate.

## Five senior-level explanations

1. **Why decouple analytics from checkout?** Customer transactions must succeed even if the analytical pipeline is degraded.
2. **Why use S3 as the system of record?** Durable raw data allows new transformations and models without requiring producers to replay historical behavior.
3. **Why separate raw and curated zones?** Immutable source evidence and optimized consumer datasets have different governance and lifecycle needs.
4. **Why use Glue with Athena?** Glue provides shared schema metadata while Athena supplies serverless SQL compute over S3.
5. **Why use separate Firehose streams?** Firehose has destination-specific delivery behavior, so distinct streams make S3 and OpenSearch delivery explicit and independently operable.

---

# Phase 12 — AI-Assisted Operations and Human-Approved Remediation

**Role:** Use reliable telemetry and runbooks to generate evidence-based incident recommendations and execute only approved, allow-listed actions.

**Dependencies:** Phases 3, 10, and 11; mature runbooks and incident ownership.

## Steps

| Step | Implementation | Short role | Output |
|---|---|---|---|
| 12.1 | Define supported incident types, evidence sources, exclusions, and success criteria. | Limits AIOps to bounded, testable operational problems. | AIOps use-case register. |
| 12.2 | Provision separate OpenSearch operational-search and vector-search collections. | Prevents logs/events and Bedrock embeddings from sharing unclear lifecycle and access controls. | Purpose-specific collections. |
| 12.3 | Store approved runbooks, architecture documents, service ownership, and incident knowledge in S3. | Creates the governed source corpus for retrieval. | Knowledge source bucket. |
| 12.4 | Create Bedrock Knowledge Base ingestion into the vector collection. | Enables retrieval-augmented generation from approved AVOS evidence. | RAG knowledge base. |
| 12.5 | Build SageMaker anomaly training, evaluation, and inference workflow. | Produces optional quantitative anomaly scores from historical data. | Anomaly model. |
| 12.6 | Route CloudWatch, Prometheus, and Argo CD incident events into EventBridge. | Normalizes selected operational triggers for automation. | Incident event bus. |
| 12.7 | Build Lambda enrichment to collect metrics, logs, traces, deployments, Athena history, and anomaly scores. | Creates a complete incident context package. | Enrichment function. |
| 12.8 | Invoke Bedrock with retrieved evidence, explicit prompts, citations, and guardrails. | Produces constrained summaries, probable causes, and recommended runbooks. | Incident recommendation. |
| 12.9 | Add an incident-management record and human approval step. | Ensures an accountable operator reviews evidence and impact. | Approval workflow. |
| 12.10 | Build allow-listed SSM Automation documents for safe actions. | Encodes controlled remediation instead of arbitrary AI-generated commands. | SSM runbook catalog. |
| 12.11 | Route approved actions through EventBridge/Lambda to SSM Automation. | Executes only the selected approved runbook with bounded parameters. | Remediation workflow. |
| 12.12 | Record prompts, evidence references, recommendations, approval, execution, and outcomes in CloudTrail/CloudWatch/S3. | Creates an auditable decision and execution history. | AIOps audit trail. |
| 12.13 | Test false positives, missing evidence, model failure, denied approval, failed remediation, and rollback. | Proves the system fails safely. | Safety validation. |

## Tools and resources

| Tool/resource | Short role |
|---|---|
| EventBridge | Routes incident and approval events to automation targets. |
| Lambda | Enriches incidents and coordinates bounded integrations. |
| SageMaker AI | Produces trained anomaly or predictive scores. |
| Amazon Bedrock | Summarizes evidence and recommends approved operational responses. |
| Bedrock Knowledge Bases | Retrieves AVOS-specific evidence for grounded responses. |
| OpenSearch vector collection | Stores embeddings for semantic runbook retrieval. |
| OpenSearch operational collection | Searches selected logs and operational events. |
| Bedrock Guardrails | Constrains model inputs and outputs according to policy. |
| Human approval | Prevents autonomous production action. |
| SSM Automation | Executes predefined, auditable remediation steps. |
| CloudTrail, CloudWatch, and S3 | Preserve execution, telemetry, and decision evidence. |

## Validation gate

- Bedrock responses cite retrieved AVOS evidence rather than unsupported general statements.
- SageMaker anomaly evaluation meets the approved quality threshold before operational use.
- Missing or conflicting evidence causes escalation, not automatic action.
- No remediation can execute without authenticated human approval.
- SSM rejects non-allow-listed documents and parameters.
- Failed remediation stops safely, alerts responders, and preserves evidence.
- All recommendation and execution events are auditable end to end.

## Deliverables

- AIOps use-case and threat model
- OpenSearch collection design
- Bedrock knowledge base and guardrails
- SageMaker anomaly workflow
- Lambda enrichment code
- Human approval workflow
- SSM Automation catalog
- Safety and audit evidence

## Cleanup and cost control

- Use the smallest appropriate OpenSearch capacity and retention for each collection.
- Invoke Bedrock and SageMaker only for qualified incidents or scheduled analysis.
- Delete obsolete model endpoints, test indexes, duplicate embeddings, and temporary datasets.
- Set budgets and anomaly alerts for AI, search, and analytics services.

## Five senior-level explanations

1. **Why implement AIOps after observability?** AI cannot compensate for missing or unreliable telemetry and runbooks.
2. **Why separate SageMaker from Bedrock?** SageMaker supplies quantitative predictive signals; Bedrock synthesizes evidence into a human-readable operational recommendation.
3. **Why use RAG with OpenSearch?** Retrieval grounds Bedrock in AVOS-specific runbooks and evidence instead of relying only on general model knowledge.
4. **Why require human approval?** Production remediation carries business risk and requires accountable judgment, especially when model output is probabilistic.
5. **Why use SSM instead of model-generated commands?** SSM executes versioned, reviewed, parameter-bounded procedures with stronger audit and rollback controls.

---

# Phase 13 — Reliability, Performance, Security, and Failure Validation

**Role:** Demonstrate that AVOS meets measurable reliability, scalability, security, and recovery objectives under normal and degraded conditions.

**Dependencies:** Phases 9–12 operational in the target test environment.

## Steps

| Step | Implementation | Short role | Output |
|---|---|---|---|
| 13.1 | Define test scenarios, acceptance thresholds, RTO, RPO, and SLO error budgets. | Creates measurable release criteria. | Validation plan. |
| 13.2 | Run baseline and peak Locust tests across realistic customer journeys. | Measures latency, throughput, errors, and scaling behavior. | Performance report. |
| 13.3 | Validate HPA and Karpenter scale-up, consolidation, and capacity ceilings. | Proves demand-driven application and node scaling. | Scaling evidence. |
| 13.4 | Test pod, node, AZ, dependency, network, and database failure scenarios. | Demonstrates graceful degradation and recovery. | Resilience report. |
| 13.5 | Test gRPC deadline, retry, circuit-breaking, and idempotency behavior. | Prevents transient failure from becoming a cascading outage. | Failure-policy evidence. |
| 13.6 | Test WAF, JWT, RBAC, service authorization, secret rotation, and network segmentation. | Proves security controls at each trust boundary. | Security test report. |
| 13.7 | Run container, IaC, dependency, secret, and Kubernetes posture scans. | Finds release-blocking vulnerabilities and misconfiguration. | Security scan package. |
| 13.8 | Restore Aurora, Redis, Terraform state, and GitOps state in controlled tests. | Proves recoverability of critical platform state. | Recovery evidence. |
| 13.9 | Conduct a complete incident exercise from alert through approved SSM remediation. | Validates the operational and AIOps response chain. | Game-day report. |
| 13.10 | Resolve critical findings and record accepted residual risks. | Prevents unresolved material risk from being hidden at sign-off. | Risk register. |

## Tools and resources

| Tool/resource | Short role |
|---|---|
| Locust | Generates realistic AVOS customer traffic. |
| HPA and Karpenter | Demonstrate pod and node elasticity under load. |
| Istio fault injection | Simulates controlled latency and service failures. |
| Trivy and IaC scanners | Detect application, image, and infrastructure risks. |
| AWS backup and restore mechanisms | Recover managed data and configuration state. |
| SLO/error-budget reporting | Determines whether reliability is acceptable for release. |

## Validation gate

- Performance thresholds are met at defined normal and peak load.
- Scaling remains within cost and safety ceilings.
- Single-pod, node, and dependency failures do not cause unacceptable customer impact.
- Recovery tests meet approved RTO and RPO targets.
- No unresolved critical vulnerability or public exposure remains.
- The end-to-end incident exercise completes with an auditable timeline.

## Deliverables

- Performance and scalability report
- Resilience and recovery report
- Security validation report
- Game-day and postmortem evidence
- Residual-risk register
- Release recommendation

## Cleanup and cost control

- Run high-cost tests in scheduled windows and tear down temporary capacity immediately afterward.
- Delete unused snapshots, load-test data, temporary dashboards, and diagnostic indexes after retention requirements are met.

## Five senior-level explanations

1. **Why test failure instead of only success?** Production reliability depends on controlled degradation and recovery, not the happy path alone.
2. **Why evaluate HPA and Karpenter together?** Pod scaling creates compute demand and node scaling satisfies it; testing one alone misses their interaction.
3. **Why define RTO and RPO first?** Recovery design cannot be judged without business-approved time and data-loss targets.
4. **Why use realistic journeys?** Endpoint-only tests miss the dependency fan-out and state transitions created by actual checkout behavior.
5. **Why record residual risk?** Senior engineering decisions make remaining tradeoffs visible rather than implying that risk has been eliminated.

---

# Phase 14 — Promotion, Cost Controls, Teardown, Recovery, and Final Sign-Off

**Role:** Make AVOS repeatable, supportable, cost-controlled, recoverable, and defensible as a production-grade portfolio project.

**Dependencies:** Phase 13 release recommendation and resolved blockers.

## Steps

| Step | Implementation | Short role | Output |
|---|---|---|---|
| 14.1 | Promote the same approved image digests from dev to staging and production through Git PRs. | Preserves artifact identity and approval evidence across environments. | Promotion record. |
| 14.2 | Apply production change windows, approvals, sync policy, and rollback criteria. | Governs high-impact releases. | Production release policy. |
| 14.3 | Configure budgets, cost allocation tags, Cost Anomaly Detection, and owner notifications. | Exposes unexpected spend and assigns accountability. | FinOps controls. |
| 14.4 | Produce a resource-cost inventory and environment run schedule. | Makes fixed and variable cost drivers visible. | Cost baseline. |
| 14.5 | Create an ordered scale-down and teardown procedure. | Reduces portfolio cost without destroying recovery knowledge. | Teardown runbook. |
| 14.6 | Create an ordered restoration procedure. | Rebuilds dependencies in a safe sequence. | Restoration runbook. |
| 14.7 | Complete troubleshooting indexes organized by implementation phase. | Makes known failures and fixes easy to locate. | Troubleshooting catalog. |
| 14.8 | Capture final architecture, CI, GitOps, security, observability, analytics, and AIOps evidence. | Supports operational sign-off and interview demonstrations. | Evidence package. |
| 14.9 | Create demo script, interview narrative, and five major tradeoff stories. | Converts implementation experience into concise senior-level communication. | Portfolio presentation material. |
| 14.10 | Conduct formal architecture, security, operations, cost, and documentation sign-off. | Establishes the approved final project state. | AVOS release record. |

## Tools and resources

| Tool/resource | Short role |
|---|---|
| GitHub environments and PRs | Enforce promotion approvals and preserve release history. |
| AWS Budgets | Alerts when planned spending thresholds are approached or exceeded. |
| Cost Anomaly Detection | Identifies unusual AWS spending patterns. |
| Cost allocation tags | Attribute spend to AVOS environments, services, and owners. |
| Teardown/restoration runbooks | Control cost while preserving a safe resumption path. |
| Evidence index | Links claims to commands, screenshots, logs, and validation records. |

## Validation gate

- Staging and production reference the same approved image digest.
- Rollback criteria and a known-good release are documented.
- Budgets, anomaly detection, ownership tags, and notification paths validate.
- Teardown and restoration are tested in a non-production environment.
- Documentation accurately distinguishes implemented, deployed, validated, and planned capabilities.
- Architecture, security, operations, cost, and documentation owners approve release.

## Deliverables

- Environment promotion record
- Production release and rollback policy
- Cost inventory and FinOps controls
- Teardown and restoration runbooks
- Troubleshooting index
- Final validation and sign-off document
- Demo and interview package

## Cleanup and cost control

Recommended teardown order:

1. Stop load generation and optional AI/analytics workloads.
2. Disable automated GitOps sync and Image Updater write-back.
3. Scale application workloads to zero where supported.
4. Delete Karpenter NodeClaims and reduce managed node capacity safely.
5. Remove high-cost temporary analytics, model endpoints, and OpenSearch test capacity.
6. Preserve required state, snapshots, evidence, Git history, and recovery metadata.
7. Destroy environment roots only in reverse dependency order after explicit approval.

Recommended restoration order:

1. Bootstrap state, KMS, identity, and governance.
2. Networking, DNS prerequisites, certificates, and security controls.
3. EKS control plane, baseline node capacity, and managed data services.
4. Platform controllers, Istio, Gateway API, secrets, and observability.
5. Argo CD, Image Updater, and GitOps applications.
6. AVOS microservices and customer edge path.
7. Analytics, SageMaker, Bedrock, OpenSearch, and remediation automation.
8. Load tests, final health checks, and customer-flow validation.

## Five senior-level explanations

1. **Why promote digests rather than rebuild?** Digest promotion proves that the tested artifact is exactly the artifact deployed to the next environment.
2. **Why treat teardown as an engineered workflow?** Unordered destruction can strand dependencies, lose evidence, and make restoration more expensive than leaving resources running.
3. **Why restore foundations first?** Workloads depend on identity, networking, encryption, capacity, and controllers; reversing that order creates misleading failures.
4. **Why include cost in architecture sign-off?** A technically sound platform that cannot be afforded or attributed is not operationally sustainable.
5. **Why preserve evidence?** Screenshots and claims are most valuable when they link to reproducible configuration, logs, tests, and commit history.

---

# Target Repository Structure

```text
African-Vibe-Online-Shop-AVOS/
├── .github/
│   ├── CODEOWNERS
│   ├── dependabot.yml
│   ├── pull_request_template.md
│   └── workflows/
│       ├── reusable-service-ci.yml
│       ├── reusable-terraform.yml
│       ├── service-*-ci.yml
│       ├── protobuf-compatibility.yml
│       ├── security-scan.yml
│       └── documentation.yml
├── api/
│   └── proto/
│       ├── avos/
│       ├── buf.yaml
│       └── buf.gen.yaml
├── src/
│   ├── frontend/
│   ├── adservice/
│   ├── cartservice/
│   ├── checkoutservice/
│   ├── currencyservice/
│   ├── emailservice/
│   ├── paymentservice/
│   ├── productcatalogservice/
│   ├── recommendationservice/
│   ├── shippingservice/
│   ├── shoppingassistantservice/
│   └── loadgenerator/
├── gitops/
│   ├── argocd/
│   │   ├── projects/
│   │   ├── applicationsets/
│   │   ├── image-updater/
│   │   └── root-app.yaml
│   ├── base/
│   │   ├── services/
│   │   ├── gateway-api/
│   │   ├── policies/
│   │   └── observability/
│   └── overlays/
│       ├── dev/
│       ├── staging/
│       └── prod/
├── infrastructure/
│   └── terraform/
│       ├── bootstrap/
│       ├── organization/
│       ├── governance/
│       ├── identity/
│       ├── networking/
│       ├── edge-security/
│       ├── container-platform/
│       ├── data-platform/
│       ├── platform-services/
│       ├── observability/
│       ├── analytics/
│       ├── aiops/
│       ├── ci/
│       ├── modules/
│       └── tests/
├── analytics/
│   ├── schemas/
│   ├── glue-jobs/
│   ├── athena/
│   └── quicksight/
├── aiops/
│   ├── lambda/
│   ├── sagemaker/
│   ├── bedrock/
│   ├── guardrails/
│   ├── knowledge-base/
│   └── ssm-runbooks/
├── tests/
│   ├── contract/
│   ├── integration/
│   ├── end-to-end/
│   ├── performance/
│   ├── resilience/
│   └── security/
├── scripts/
│   ├── bootstrap/
│   ├── validation/
│   ├── teardown/
│   └── restoration/
├── docs/
│   ├── architecture/
│   ├── roadmap/
│   ├── adr/
│   ├── runbooks/
│   ├── validation/
│   ├── troubleshooting/
│   ├── security/
│   ├── cost/
│   └── interviews/
├── .gitignore
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Repository structure rules

- `src/` owns executable application components.
- `api/proto/` owns shared gRPC contracts and generated-code policy.
- `gitops/` owns Kubernetes desired state and environment promotion.
- `infrastructure/terraform/` owns AWS infrastructure and shared modules.
- `analytics/` owns schemas, transformations, queries, and dashboard definitions.
- `aiops/` owns enrichment, models, knowledge sources, guardrails, and approved remediation documents.
- `tests/` owns cross-service and platform validation that does not belong to a single service.
- `docs/` owns architecture, decisions, runbooks, evidence, and interview material.
- Generated binaries, Terraform state, credentials, build output, and local kubeconfigs must never be committed.

# Global Definition of Done

AVOS is complete only when all of the following are true:

- The approved architecture matches the implemented and documented platform.
- All 11 business microservices pass CI and deploy through GitOps.
- Internal business-service traffic uses documented gRPC contracts.
- GitHub Actions publishes immutable images but does not deploy or update GitOps tags.
- Image Updater performs the only automated image-tag Git write-back.
- Argo CD is the only application desired-state reconciler.
- Edge, identity, network, mesh, data, and service authorization controls pass negative tests.
- Aurora and Redis backup, failover, and recovery behavior are validated.
- Every critical service has metrics, logs, traces, dashboards, SLOs, alerts, and a runbook.
- Business analytics flows from Kinesis through QuickSight with governed S3 data.
- AIOps recommendations are grounded, audited, human-approved, and executed only through allow-listed SSM documents.
- Load, resilience, security, promotion, rollback, teardown, and restoration tests pass.
- Cost ownership, budgets, retention, and shutdown procedures are documented.
- Final documentation distinguishes present, validated, deployed, and planned capabilities without unsupported claims.

# Phase Sign-Off Template

Use this checklist at the end of every phase:

```markdown
## Phase <N> Sign-Off

- [ ] Prerequisites were satisfied.
- [ ] Planned steps were implemented through reviewed code.
- [ ] Security and least-privilege checks passed.
- [ ] Validation gate passed with evidence links.
- [ ] Rollback or recovery procedure was tested.
- [ ] Cost-producing resources were tagged and reviewed.
- [ ] Temporary resources and artifacts were cleaned up.
- [ ] Documentation and diagrams were updated.
- [ ] Implemented/deployed/planned status was recorded accurately.
- [ ] Five senior-level explanations were reviewed.

Decision: Approved / Approved with conditions / Rejected
Reviewer:
Date:
Evidence:
Follow-up actions:
```
