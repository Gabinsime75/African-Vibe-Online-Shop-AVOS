# ADR-004: AVOS Container Platform Architecture

## Status

Accepted

## Date

October 4, 2026

## Context

The African Vibe Online Shop (AVOS) requires a secure, scalable, resilient, and operationally manageable container platform for its microservices.

The platform must support:

- deployment of AVOS application microservices;
- workload isolation from public network subnets;
- secure Kubernetes API access;
- encrypted Kubernetes secrets;
- resilient system services;
- dynamic application capacity;
- AWS-native workload identity;
- encrypted persistent storage;
- interruption handling for Spot Instances;
- centralized control-plane logging;
- infrastructure management through Terraform.

The AVOS network foundation provides three private application subnets across `us-east-2a`, `us-east-2b`, and `us-east-2c`. These subnets provide outbound connectivity through the development NAT Gateway while preventing direct inbound access from the internet.

AVOS requires stable compute capacity for essential Kubernetes components while allowing application capacity to scale independently according to workload demand.

## Decision

AVOS will use Amazon Elastic Kubernetes Service as its managed Kubernetes control plane.

The development cluster is named:

```text
avos-dev-eks
```

The initial Kubernetes version is:

```text
1.35
```

The platform uses a hybrid compute model:

1. an Amazon EKS managed node group provides fixed capacity for critical platform and system services;
2. Karpenter provides dynamically provisioned capacity for AVOS application workloads.

This separates predictable platform capacity from variable application capacity.

## Architecture

```text
AVOS administrator
        |
        | IAM Identity Center
        v
Restricted EKS public API endpoint
        |
        v
Amazon EKS control plane
        |
        +--- Private application subnet — us-east-2a
        |
        +--- Private application subnet — us-east-2b
        |
        +--- Private application subnet — us-east-2c
                |
                +--- Managed system node group
                |
                +--- Karpenter application nodes
```

## Regional Deployment

The container platform is deployed in:

```text
us-east-2
```

The EKS cluster uses resources across three Availability Zones:

- `us-east-2a`;
- `us-east-2b`;
- `us-east-2c`.

Using three Availability Zones reduces dependence on a single AWS data center and provides a foundation for highly available Kubernetes workloads.

Application-level availability still depends on workload configuration, including:

- replica counts;
- topology-spread constraints;
- Pod anti-affinity;
- Pod disruption budgets;
- health probes;
- resource requests;
- application retry behavior.

## Cluster Networking

The EKS cluster uses the three private application subnets exported by the networking Terraform state.

Worker nodes are not placed in public subnets.

The cluster API endpoint configuration is:

- private endpoint access enabled;
- public endpoint access enabled;
- public access restricted to approved administrator `/32` CIDRs.

The public endpoint is not open to:

```text
0.0.0.0/0
```

This design allows authorized administrators to manage the development cluster without requiring a VPN while preserving private communication between the EKS control plane and worker nodes.

The public endpoint restriction is an administrative boundary, not an application ingress design. AVOS application traffic will enter through the approved edge and load-balancing architecture rather than through the Kubernetes API endpoint.

## Networking State Integration

The container-platform Terraform root consumes required networking information through Terraform remote state.

The networking state provides:

- VPC ID;
- private application subnet IDs;
- public subnet IDs where required by later ingress components;
- AWS Region;
- network resource identifiers required by the EKS platform.

The container-platform root does not recreate or independently discover foundational networking resources.

This establishes an explicit contract between the networking and container-platform Terraform roots while preserving independent state and lifecycle management.

## Cluster Authentication

The EKS cluster uses the authentication mode:

```text
API
```

The legacy `aws-auth` ConfigMap is not used as the primary cluster access-management mechanism.

Administrative access is configured through:

- an EKS access entry;
- an EKS access policy association;
- the AWS-managed `AmazonEKSClusterAdminPolicy`;
- the permanent IAM role created by AVOS IAM Identity Center.

The administrator principal is the permanent IAM role ARN, not the temporary STS session ARN.

Bootstrap cluster-creator administrator permissions are disabled:

```text
bootstrap_cluster_creator_admin_permissions = false
```

This ensures that administrative access is explicitly declared, reviewable, and managed through Terraform rather than being implicitly granted to the identity that created the cluster.

## Kubernetes API Access

The EKS API supports both private and restricted public access.

Private access enables:

- worker-node communication with the control plane;
- in-VPC administrative access;
- future private deployment runners;
- future VPN or Direct Connect administration.

Restricted public access enables authorized development administration from approved external addresses.

The approved public CIDR must be updated when the trusted administrator public IP address changes.

A private-only endpoint should be considered when AVOS introduces one or more of the following:

- AWS Client VPN;
- site-to-site VPN;
- Direct Connect;
- a hardened administrative bastion;
- private CI/CD runners;
- centralized enterprise network connectivity.

## Cluster IAM Role

The EKS control plane uses a dedicated IAM role.

The role trust policy permits the EKS service to assume the role.

The role includes:

- `AmazonEKSClusterPolicy`;
- the permissions required to use the dedicated EKS KMS key.

The cluster role is not reused by worker nodes, Kubernetes controllers, or application workloads.

This separation reduces the impact of an IAM configuration error and maintains distinct trust boundaries.

## Kubernetes Secrets Encryption

Kubernetes secrets are encrypted with a dedicated customer-managed AWS KMS key.

The key configuration includes:

- symmetric encryption;
- `ENCRYPT_DECRYPT` usage;
- automatic key rotation;
- a 365-day rotation period;
- a 30-day deletion window;
- a single-Region key;
- an AVOS-specific alias.

The alias is:

```text
alias/avos-dev-eks
```

The EKS cluster encryption configuration applies the KMS key to:

```text
secrets
```

This adds envelope encryption for Kubernetes secrets stored in the EKS control-plane data store.

KMS encryption does not replace Kubernetes RBAC, application-level authorization, secret rotation, or secure secret-delivery practices.

## Control-Plane Logging

The following EKS control-plane log categories are enabled:

- API server;
- audit;
- authenticator;
- controller manager;
- scheduler.

Logs are delivered to:

```text
/aws/eks/avos-dev-eks/cluster
```

The CloudWatch Logs group:

- is created before the EKS cluster;
- uses the dedicated EKS KMS key;
- uses the Standard log class;
- retains logs for 30 days;
- is tagged as an AVOS EKS control-plane logging resource.

These logs provide evidence for:

- Kubernetes API requests;
- authentication attempts;
- authorization decisions;
- Kubernetes audit events;
- scheduler activity;
- controller-manager activity;
- cluster troubleshooting.

## Compute Architecture

AVOS separates compute capacity into two categories:

| Capacity category | Provisioning mechanism | Primary purpose |
|---|---|---|
| System capacity | EKS managed node group | Stable platform and system services |
| Application capacity | Karpenter | Elastic AVOS application workloads |

This prevents critical controllers from depending entirely on dynamically provisioned application nodes.

## Managed System Node Group

An EKS managed node group provides stable baseline capacity.

The system node group hosts components such as:

- CoreDNS;
- Karpenter;
- EKS Pod Identity Agent;
- Amazon VPC CNI;
- kube-proxy;
- Amazon EBS CSI components;
- future platform controllers;
- other critical `kube-system` services.

The system node group uses:

- Amazon Linux 2023;
- private application subnets;
- encrypted root storage;
- multiple Availability Zones;
- a dedicated IAM role;
- an EC2 launch template;
- explicit minimum, desired, and maximum capacity;
- EKS-managed lifecycle operations.

The fixed system capacity ensures that Karpenter does not depend on nodes that Karpenter itself must provision.

## System Node IAM Role

The managed node group uses a dedicated IAM role.

The role includes the permissions required for:

- EKS worker-node operation;
- pulling container images from Amazon ECR;
- AWS Systems Manager node management.

The role is separate from:

- the EKS control-plane role;
- the Karpenter controller role;
- the Karpenter node role;
- add-on roles;
- application workload roles.

Application Pods must not inherit the node IAM role for application-level AWS access.

Application AWS permissions should be granted through workload-specific identity associations.

## Karpenter

Karpenter provides elastic application compute capacity.

The implementation includes:

- the Karpenter controller;
- a Helm release;
- an EKS Pod Identity association;
- a dedicated controller IAM role;
- a dedicated Karpenter node IAM role;
- a dedicated EC2 instance profile;
- an interruption SQS queue;
- EventBridge interruption rules and targets;
- an `EC2NodeClass`;
- an application `NodePool`.

The Karpenter controller runs on the fixed system node group.

The controller is configured with two replicas to reduce dependence on a single controller Pod.

## Karpenter Pod Identity

The Karpenter Kubernetes service account is:

```text
kube-system/karpenter
```

The service account is associated with the dedicated Karpenter controller IAM role through EKS Pod Identity.

The IAM role trust policy permits:

```text
pods.eks.amazonaws.com
```

to perform:

- `sts:AssumeRole`;
- `sts:TagSession`.

This avoids static AWS credentials and avoids assigning the controller’s permissions to the underlying system-node IAM role.

## Karpenter Controller Permissions

The Karpenter controller policy separates permissions by API behavior and resource lifecycle.

The policy provides permissions for:

- EC2 instance and fleet creation;
- launch-template creation;
- access to existing Karpenter-owned launch templates;
- EC2 resource tagging;
- instance termination;
- launch-template deletion;
- EC2 regional discovery;
- EC2 Spot pricing discovery;
- EKS-optimized AMI discovery through Systems Manager;
- interruption-queue consumption;
- passing the Karpenter node role to EC2;
- instance-profile discovery;
- EKS cluster discovery.

New-resource operations are controlled with request-tag conditions.

Existing-resource operations are controlled with resource-tag conditions.

Permissions are scoped using tags such as:

```text
eks:eks-cluster-name
kubernetes.io/cluster/avos-dev-eks
karpenter.sh/nodepool
```

where supported by the applicable AWS API.

The controller is authorized to launch capacity only for the AVOS EKS environment and to manage resources associated with Karpenter NodePools.

## Karpenter Node Role

Nodes launched by Karpenter use a dedicated IAM role.

The role includes the permissions required for:

- EKS worker-node operation;
- pulling images from Amazon ECR;
- AWS Systems Manager management.

The node role is registered with the EKS cluster through an EKS access entry using the node access-entry type appropriate for Karpenter-provisioned EC2 capacity.

The controller receives `iam:PassRole` permission only for the dedicated Karpenter node role and only when the role is passed to:

```text
ec2.amazonaws.com
```

## Karpenter Instance Profile

AVOS creates the Karpenter node EC2 instance profile through Terraform.

The instance profile is referenced by the `EC2NodeClass`.

Karpenter is not granted broad permissions to create and manage arbitrary IAM roles or instance profiles.

This design keeps IAM object creation within Terraform and allows Karpenter to focus on EC2 capacity management.

## EC2NodeClass

The application `EC2NodeClass` is named:

```text
avos-dev-application
```

It defines the AWS infrastructure characteristics for application nodes.

The configuration uses:

- Amazon Linux 2023 EKS-optimized AMIs;
- the current supported EKS AMI family;
- private application subnets;
- the EKS cluster security group;
- the Terraform-managed instance profile;
- encrypted `gp3` root volumes;
- IMDSv2;
- AVOS ownership and workload tags.

The root block device uses:

- `gp3`;
- encryption enabled;
- delete-on-termination enabled;
- an explicitly defined size.

The metadata service requires IMDSv2 tokens to reduce exposure to metadata credential attacks.

Karpenter-managed restricted tags are not manually configured in `spec.tags`. Karpenter applies its required ownership tags automatically.

## Application NodePool

The application `NodePool` is named:

```text
application
```

It references:

```text
avos-dev-application
```

The NodePool supports:

- Linux;
- `amd64`;
- Spot capacity;
- On-Demand capacity;
- compute-optimized instance families;
- general-purpose instance families;
- memory-optimized instance families;
- approved current EC2 generations.

The NodePool applies application-specific Kubernetes labels so workloads can target Karpenter-provisioned capacity.

The NodePool defines aggregate CPU and memory limits to prevent uncontrolled infrastructure growth.

## Karpenter Scaling Behavior

Karpenter evaluates pending Pods and selects appropriate EC2 capacity based on:

- resource requests;
- scheduling constraints;
- NodePool requirements;
- Availability Zone compatibility;
- instance-type availability;
- capacity type;
- daemon overhead;
- topology requirements.

When there are no pending application workloads, the NodePool may correctly remain at:

```text
NODES=0
```

A zero-node application NodePool is not an error when:

- the `NodePool` is ready;
- the `EC2NodeClass` is ready;
- no eligible application workload is pending.

## Karpenter Disruption and Consolidation

Karpenter is configured to consolidate underutilized or unnecessary application nodes.

Disruption controls are used to reduce simultaneous node replacement.

The design balances:

- infrastructure cost;
- workload availability;
- scheduling flexibility;
- controlled node turnover.

Production environments should use application-specific Pod disruption budgets and topology constraints before using aggressive consolidation settings.

## Spot and On-Demand Capacity

The application NodePool permits both Spot and On-Demand capacity.

This provides:

- lower compute cost when Spot capacity is available;
- access to On-Demand capacity when Spot capacity is unavailable or unsuitable;
- greater instance-selection flexibility.

Applications running on Spot capacity must tolerate interruption through:

- multiple replicas;
- readiness probes;
- graceful termination handling;
- Pod disruption budgets;
- retry-safe application behavior;
- multi-AZ scheduling.

Critical system components remain on the managed system node group rather than depending entirely on Spot capacity.

## Karpenter Interruption Handling

Karpenter receives interruption events through an encrypted Amazon SQS queue.

Amazon EventBridge rules deliver:

- EC2 Spot interruption warnings;
- EC2 rebalance recommendations;
- EC2 instance state-change notifications;
- AWS Health scheduled-change events.

Karpenter uses these events to prepare affected nodes for interruption.

Depending on the event and available notice, Karpenter can:

- cordon the node;
- drain eligible workloads;
- provision replacement capacity;
- terminate obsolete capacity.

Interruption handling improves workload resilience but does not replace application-level availability controls.

## Managed EKS Add-ons

The platform installs the following EKS managed add-ons:

- Amazon VPC CNI;
- CoreDNS;
- kube-proxy;
- EKS Pod Identity Agent;
- Amazon EBS CSI Driver.

Add-on versions are selected for compatibility with Kubernetes 1.35.

Versions are declared through Terraform rather than relying indefinitely on unspecified defaults.

Conflict-resolution behavior is configured so Terraform can manage installation and supported upgrades consistently.

## Amazon VPC CNI

The Amazon VPC CNI integrates Kubernetes networking with the AVOS VPC.

It assigns VPC-routable IP addresses to Pods and enables Pod communication through the underlying VPC network.

The VPC CNI uses a dedicated IAM role through EKS Pod Identity.

This keeps CNI permissions separate from the system-node IAM role.

## CoreDNS

CoreDNS provides Kubernetes service discovery.

CoreDNS runs on the stable system capacity because cluster DNS is required by:

- application services;
- controllers;
- admission webhooks;
- Kubernetes components.

CoreDNS becomes operational after suitable worker-node capacity is available.

## kube-proxy

`kube-proxy` manages Kubernetes service-networking rules on worker nodes.

It is installed as an EKS managed add-on and maintained at a version compatible with the EKS cluster version.

## EKS Pod Identity Agent

The EKS Pod Identity Agent runs on the cluster nodes and provides credentials to Pods associated with IAM roles.

It supports AWS-native workload identity without storing long-lived AWS access keys in Kubernetes Secrets.

The agent is required before Pod Identity associations can function correctly.

## Amazon EBS CSI Driver

The Amazon EBS CSI Driver provides persistent block storage for Kubernetes workloads.

It uses a dedicated IAM role through EKS Pod Identity.

The driver has the permissions required to manage EBS volumes for Kubernetes persistent-volume claims.

The EBS CSI role is not shared with Karpenter, the VPC CNI, the cluster, or application workloads.

## Persistent Storage

AVOS defines an encrypted `gp3` Kubernetes StorageClass.

The StorageClass uses:

```text
ebs.csi.aws.com
```

The configuration includes:

- EBS `gp3` volumes;
- encryption enabled;
- `ext4` filesystem;
- volume expansion enabled;
- `WaitForFirstConsumer`;
- `Delete` reclaim policy.

The StorageClass is marked as the default class.

## WaitForFirstConsumer

The volume-binding mode is:

```text
WaitForFirstConsumer
```

This delays EBS volume creation until Kubernetes schedules the consuming Pod.

The scheduler can therefore ensure that:

- the Pod is assigned to an Availability Zone;
- the EBS volume is created in the same Availability Zone;
- the volume can be attached to the selected node.

This prevents premature volume creation in an incompatible Availability Zone.

## Default gp2 StorageClass

EKS may initially create a legacy `gp2` StorageClass.

The AVOS `gp3` StorageClass is explicitly marked as the default.

Only one StorageClass should retain the default annotation.

New persistent-volume claims that omit `storageClassName` should therefore use:

```text
gp3
```

## Resource Tagging

Container-platform resources use common tags including:

- `Project`;
- `Environment`;
- `ManagedBy`;
- `Owner`;
- `TerraformRoot`;
- `Workload`;
- `Name`;
- resource-specific purpose tags.

Tags support:

- ownership identification;
- cost allocation;
- operational search;
- compliance review;
- automation;
- incident investigation.

Karpenter-owned resources also use Karpenter and EKS ownership tags required for controller authorization and lifecycle management.

## Terraform State

The container-platform Terraform root uses a dedicated remote-state object:

```text
container-platform/terraform.tfstate
```

The state is stored in the AVOS Terraform state S3 bucket with:

- AWS KMS encryption;
- bucket versioning;
- public-access blocking;
- S3 native state locking.

The local `backend.hcl` file contains environment-specific backend values and is not committed.

The repository contains:

```text
backend.hcl.example
```

as a safe configuration template.

## Terraform Configuration Separation

The container-platform root separates responsibilities across focused Terraform files.

The design includes dedicated configuration for areas such as:

- backend configuration;
- providers;
- variables;
- local values;
- data sources;
- EKS KMS encryption;
- EKS IAM;
- EKS control-plane logging;
- EKS cluster configuration;
- EKS access entries;
- managed node groups;
- EKS add-ons;
- Pod Identity;
- persistent storage;
- Karpenter IAM;
- Karpenter Helm installation;
- interruption handling;
- Karpenter capacity resources;
- outputs.

This structure improves reviewability and limits the size and responsibility of individual Terraform files.

## Alternatives Considered

### Self-managed Kubernetes

Rejected because AVOS would be responsible for control-plane provisioning, availability, upgrades, backups, patching, and lifecycle management.

Amazon EKS reduces control-plane operational overhead while preserving Kubernetes compatibility.

### Application workloads on the managed system node group

Rejected as the primary application-capacity model because it would combine stable platform services with variable workload demand.

It would also reduce scheduling flexibility and require node-group scaling around predefined instance groups.

### Karpenter for all cluster capacity

Rejected because Karpenter and other critical controllers require reliable bootstrap capacity.

Using a fixed managed system node group avoids the circular dependency in which Karpenter would need to provision the nodes required to run itself.

### Cluster Autoscaler

Rejected in favor of Karpenter.

Cluster Autoscaler primarily adjusts existing Auto Scaling Groups, whereas Karpenter can directly select and provision suitable EC2 instance types based on pending Pod requirements.

### Public worker nodes

Rejected because AVOS worker nodes do not require direct internet exposure.

Private subnets reduce the external attack surface and keep node ingress under controlled network paths.

### Public Kubernetes API open to all addresses

Rejected because unrestricted API access would expose the Kubernetes control plane unnecessarily.

Public access is restricted to approved administrator CIDRs.

### Private-only Kubernetes API

Deferred for the development environment because AVOS does not yet have dedicated private administrative connectivity.

This option should be reconsidered when AVOS introduces VPN access, private runners, or centralized enterprise networking.

### IAM Roles for Service Accounts

Not selected as the default identity model.

EKS Pod Identity provides AWS-managed credential delivery without requiring each controller integration to depend on the cluster IAM OIDC provider.

IRSA may still be used if a future workload or controller does not support EKS Pod Identity.

### A single shared IAM role for all controllers

Rejected because it would violate least privilege and increase the impact of credential misuse.

Each supported AWS-integrated controller receives a dedicated IAM role.

### Unencrypted Kubernetes secrets

Rejected because Kubernetes secrets can contain credentials and sensitive configuration.

AVOS uses KMS envelope encryption.

### Unencrypted persistent volumes

Rejected because application data must be encrypted at rest.

The default `gp3` StorageClass requests encrypted EBS volumes.

### Static application node capacity

Rejected as the long-term application-capacity model because it would require continuous capacity forecasting and could leave AVOS either overprovisioned or unable to respond quickly to demand.

## Consequences

### Positive consequences

- AWS manages the EKS control plane.
- Worker nodes remain in private subnets.
- Administrator access is explicit and auditable.
- Kubernetes secrets are encrypted with a customer-managed key.
- Control-plane logs provide security and operational evidence.
- System components have stable baseline capacity.
- Application compute can scale dynamically.
- Idle application capacity can remain at zero.
- Spot and On-Demand capacity can be combined.
- Pod Identity removes static AWS credentials from controllers.
- EBS volumes are encrypted by default.
- Interruption events can be processed proactively.
- Terraform maintains the desired infrastructure state.
- Networking and container-platform lifecycles remain separated.

### Tradeoffs

- The managed system node group introduces continuous EC2 cost.
- Karpenter adds CRDs, IAM permissions, Helm management, and operational complexity.
- Spot capacity can be interrupted.
- The public EKS endpoint must be updated when the approved administrator IP changes.
- The development network’s single NAT Gateway introduces an Availability Zone dependency for outbound traffic.
- Kubernetes and EKS add-on versions require continuing lifecycle management.
- The dedicated KMS key, CloudWatch logs, NAT traffic, EKS control plane, and worker nodes generate AWS cost.
- Remote-state dependencies require compatible outputs between Terraform roots.

## Security Considerations

The design applies several security controls:

- worker nodes use private subnets;
- public Kubernetes API access is CIDR restricted;
- administrator access uses IAM Identity Center;
- EKS access is managed through API access entries;
- bootstrap creator access is disabled;
- Kubernetes secrets use KMS envelope encryption;
- control-plane logs are encrypted;
- persistent volumes are encrypted;
- controllers use dedicated Pod Identity roles;
- IAM policies use request and resource tag conditions;
- EC2 instance metadata requires IMDSv2;
- application nodes use a dedicated IAM role;
- no long-lived AWS credentials are embedded in Terraform or Kubernetes manifests.

Security posture must be reviewed as new controllers and workloads are introduced.

## Operational Requirements

Operators must:

- authenticate with the AVOS IAM Identity Center profile;
- keep approved EKS API CIDRs current;
- monitor EKS and Kubernetes version support;
- review managed add-on compatibility before upgrades;
- monitor system-node capacity;
- monitor Karpenter controller health;
- monitor Karpenter NodePool and EC2NodeClass conditions;
- monitor failed node launches;
- monitor unschedulable Pods;
- monitor the Karpenter interruption queue;
- review control-plane audit logs;
- review KMS and IAM activity;
- validate Terraform plans before applying them;
- preserve the networking remote-state contract;
- avoid manually editing Terraform-managed resources.

## Validation

The implementation was validated with:

- `terraform fmt -recursive`;
- `terraform validate`;
- `terraform plan -detailed-exitcode`;
- EKS cluster inspection;
- EKS access-entry inspection;
- managed add-on inspection;
- managed node-group inspection;
- Kubernetes node inspection;
- Pod Identity association inspection;
- StorageClass inspection;
- Karpenter controller rollout inspection;
- Karpenter `EC2NodeClass` condition inspection;
- Karpenter `NodePool` condition inspection.

The final Terraform convergence result was:

```text
No changes. Your infrastructure matches the configuration.
Terraform plan exit code: 0
```

The final Karpenter readiness result was:

```text
ec2nodeclass.karpenter.k8s.aws/avos-dev-application   True
nodepool.karpenter.sh/application                    True
```

The application NodePool reported zero nodes because no pending application workload required additional capacity.

The zero-node state is expected and does not indicate an unhealthy NodePool.

## Outcome

The AVOS development environment now has a secure, encrypted, multi-AZ Amazon EKS container foundation.

The platform provides:

- stable system capacity;
- elastic application capacity;
- private worker-node networking;
- controlled administrative access;
- KMS-encrypted Kubernetes secrets;
- encrypted persistent storage;
- centralized control-plane logging;
- Pod Identity for AWS-integrated controllers;
- Spot interruption handling;
- declarative Terraform lifecycle management.

This architecture establishes the container foundation required for later AVOS platform services, GitOps, observability, ingress, application deployment, and production-readiness phases.