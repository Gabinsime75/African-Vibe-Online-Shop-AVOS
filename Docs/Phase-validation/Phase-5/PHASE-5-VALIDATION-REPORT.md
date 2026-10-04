# AVOS Phase 5 Validation Report

## Container Platform

**Project:** African Vibe Online Shop (AVOS)
**Phase:** 5 — Container Platform
**Validation date:** October 4, 2026
**AWS account:** `396913735153`
**AWS Region:** `us-east-2`
**Environment:** `dev`
**Branch:** `phase-5-container-platform`
**Status:** PASS — EKS container-platform foundation complete

## 1. Executive Summary

Phase 5 established the AVOS container-platform foundation on Amazon Elastic Kubernetes Service.

The implementation provides:

- an Amazon EKS 1.35 cluster;
- deployment across three private application subnets;
- restricted Kubernetes API access;
- API-based EKS authentication;
- IAM Identity Center administrator access;
- KMS encryption for Kubernetes secrets;
- encrypted EKS control-plane logs;
- a managed system node group;
- EKS managed add-ons;
- EKS Pod Identity;
- an encrypted default `gp3` StorageClass;
- Karpenter for elastic application capacity;
- Spot interruption handling;
- Terraform remote-state management;
- final Terraform convergence.

The final Terraform plan returned exit code `0`, confirming that the deployed infrastructure matches the Terraform configuration.

Karpenter’s `EC2NodeClass` and `NodePool` both report `READY=True`.

The application NodePool contains zero nodes because no application workload currently requires Karpenter-provisioned capacity. This is an expected steady state.

## 2. Validation Scope

This report validates the following Phase 5 components:

1. Terraform root configuration;
2. remote backend configuration;
3. networking remote-state integration;
4. EKS control-plane configuration;
5. EKS API endpoint security;
6. EKS access entries;
7. cluster KMS encryption;
8. control-plane logging;
9. managed system node group;
10. EKS managed add-ons;
11. EKS Pod Identity;
12. EBS persistent-storage configuration;
13. Karpenter controller deployment;
14. Karpenter IAM authorization;
15. Karpenter interruption handling;
16. Karpenter `EC2NodeClass`;
17. Karpenter `NodePool`;
18. final Terraform convergence.

## 3. Environment

| Attribute | Value |
|---|---|
| Project | African Vibe Online Shop |
| Environment | `dev` |
| AWS account | `396913735153` |
| AWS Region | `us-east-2` |
| EKS cluster | `avos-dev-eks` |
| Kubernetes version | `1.35` |
| Terraform root | `terraform/container-platform` |
| Terraform state key | `container-platform/terraform.tfstate` |
| Authentication mode | `API` |
| Application capacity manager | Karpenter |
| Karpenter version | `1.14.1` |
| Default StorageClass | `gp3` |

## 4. Approved Architecture

AVOS uses a hybrid EKS compute architecture.

| Capacity layer | Implementation | Purpose |
|---|---|---|
| System capacity | EKS managed node group | Stable capacity for Kubernetes and platform controllers |
| Application capacity | Karpenter | Elastic capacity for AVOS application workloads |

The fixed system node group removes the circular dependency that would exist if Karpenter had to provision the nodes required to run the Karpenter controller.

Karpenter can scale application capacity independently and may maintain zero nodes while no eligible application workload is pending.

## 5. Network Integration

The container platform consumes networking information from the networking Terraform remote state.

The EKS cluster uses the private application subnets:

| Availability Zone | Subnet ID |
|---|---|
| `us-east-2a` | `subnet-039fe2e502028b200` |
| `us-east-2b` | `subnet-0432726ba86d968ae` |
| `us-east-2c` | `subnet-06bdc81c24a78cada` |

The associated VPC is:

```text
vpc-03d5b15ed57a8815f
```

### Result

PASS

The EKS control plane and worker-node capacity use private application subnets across three Availability Zones.

## 6. Kubernetes API Endpoint

The EKS API endpoint configuration includes:

- private endpoint access enabled;
- public endpoint access enabled;
- public endpoint restricted to an approved administrator `/32` CIDR;
- no unrestricted `0.0.0.0/0` access.

The approved CIDR recorded during implementation was:

```text
23.118.78.242/32
```

This value is environment-specific and must be updated if the trusted administrator public IP changes.

### Result

PASS

The Kubernetes API is reachable privately and through a restricted public administrative path.

## 7. EKS Authentication

The cluster uses:

```text
authentication_mode = "API"
```

Cluster-creator bootstrap administrator access is disabled:

```text
bootstrap_cluster_creator_admin_permissions = false
```

The AVOS IAM Identity Center administrator role is registered through:

- an EKS access entry;
- an EKS access policy association;
- `AmazonEKSClusterAdminPolicy`;
- cluster-wide access scope.

The administrator principal uses the permanent IAM role ARN rather than a temporary STS assumed-role session ARN.

### Result

PASS

Administrative access is explicit, auditable, and Terraform-managed.

## 8. EKS Cluster

The EKS cluster is:

```text
avos-dev-eks
```

The cluster uses Kubernetes:

```text
1.35
```

The configured EKS support policy is:

```text
STANDARD
```

Deletion protection is enabled.

The cluster is configured without automatically bootstrapping self-managed add-ons.

### Result

PASS

The EKS control plane is active and managed through Terraform.

## 9. Kubernetes Secrets Encryption

A dedicated customer-managed KMS key encrypts Kubernetes secrets.

The key ID is:

```text
dd01d6d1-d88c-47b1-958b-3a58d2b179a4
```

The key alias is:

```text
alias/avos-dev-eks
```

The key configuration includes:

- symmetric encryption;
- `ENCRYPT_DECRYPT` key usage;
- automatic key rotation;
- 365-day rotation period;
- 30-day deletion window;
- single-Region deployment.

The EKS encryption configuration applies the key to:

```text
secrets
```

### Result

PASS

Kubernetes secrets receive KMS envelope encryption with a dedicated AVOS key.

## 10. Control-Plane Logging

The following EKS control-plane log types are enabled:

- `api`;
- `audit`;
- `authenticator`;
- `controllerManager`;
- `scheduler`.

The CloudWatch Logs group is:

```text
/aws/eks/avos-dev-eks/cluster
```

The log group configuration includes:

- Standard log class;
- KMS encryption;
- 30-day retention;
- Terraform management;
- AVOS ownership tags.

### Result

PASS

All principal EKS control-plane log categories are enabled and encrypted.

## 11. Cluster IAM Role

The EKS cluster uses the dedicated role:

```text
avos-dev-eks-cluster-role
```

The role includes:

- `AmazonEKSClusterPolicy`;
- permissions required to use the EKS KMS key.

The role is separate from node, controller, and workload roles.

### Result

PASS

The EKS control plane has a dedicated IAM boundary.

## 12. Managed System Node Group

The platform includes a managed system node group for critical cluster services.

The system node group provides stable capacity for components including:

- CoreDNS;
- Karpenter;
- Amazon VPC CNI;
- kube-proxy;
- EKS Pod Identity Agent;
- Amazon EBS CSI components;
- future platform controllers.

The node group uses:

- Amazon Linux 2023;
- private application subnets;
- a dedicated IAM role;
- an EC2 launch template;
- encrypted storage;
- multi-AZ placement;
- EKS-managed lifecycle operations.

The observed cluster contained two system nodes during validation.

### Result

PASS

The platform has stable capacity that does not depend on Karpenter.

## 13. System Node IAM Role

The managed node group uses:

```text
avos-dev-eks-node-role
```

The role includes permissions for:

- EKS worker-node operation;
- Amazon ECR image pulls;
- AWS Systems Manager management.

Applications should not use this role for workload-specific AWS permissions.

### Result

PASS

System-node permissions are separated from the cluster and controller roles.

## 14. EKS Managed Add-ons

The following managed add-ons are installed:

| Add-on | Selected compatible version |
|---|---|
| `vpc-cni` | `v1.22.4-eksbuild.3` |
| `coredns` | `v1.13.2-eksbuild.31` |
| `kube-proxy` | `v1.35.3-eksbuild.29` |
| `eks-pod-identity-agent` | `v1.3.10-eksbuild.3` |
| `aws-ebs-csi-driver` | `v1.66.0-eksbuild.1` |

These versions were selected from the AWS-reported default compatible versions for Kubernetes 1.35 during implementation.

### Result

PASS

The required EKS managed add-ons are installed and compatible with the cluster version.

## 15. EKS Pod Identity

EKS Pod Identity is used for supported AWS-integrated controllers.

Dedicated associations exist for:

- Karpenter;
- Amazon VPC CNI;
- Amazon EBS CSI Driver.

Each controller uses a dedicated IAM role.

The trust policy uses:

```text
pods.eks.amazonaws.com
```

with:

- `sts:AssumeRole`;
- `sts:TagSession`.

### Result

PASS

AWS credentials are delivered to supported controllers without static access keys.

## 16. Persistent Storage

The cluster defines the StorageClass:

```text
gp3
```

The observed StorageClass configuration was:

```text
Name:                  gp3
IsDefaultClass:        Yes
Provisioner:           ebs.csi.aws.com
ReclaimPolicy:         Delete
VolumeBindingMode:     WaitForFirstConsumer
AllowVolumeExpansion:  True
```

Storage parameters include:

```text
encrypted=true
fsType=ext4
type=gp3
```

### Result

PASS

The cluster has an encrypted, expandable, default `gp3` StorageClass.

## 17. Karpenter Controller

Karpenter is deployed with Helm into:

```text
kube-system
```

The release uses:

```text
karpenter
```

The controller configuration includes:

- cluster name `avos-dev-eks`;
- interruption queue integration;
- service account `karpenter`;
- two controller replicas;
- explicit CPU and memory requests;
- explicit CPU and memory limits;
- Pod Identity.

The controller runs on the stable system node group.

A final controller rollout completed successfully.

Observed result:

```text
deployment "karpenter" successfully rolled out
```

### Result

PASS

The Karpenter controller is deployed and operational.

## 18. Karpenter Controller IAM Role

The Karpenter controller uses:

```text
avos-dev-karpenter-controller-role
```

The controller policy includes permissions for:

- `ec2:CreateFleet`;
- `ec2:CreateLaunchTemplate`;
- `ec2:RunInstances`;
- `ec2:CreateTags`;
- `ec2:TerminateInstances`;
- `ec2:DeleteLaunchTemplate`;
- required EC2 discovery actions;
- Systems Manager parameter access;
- pricing discovery;
- interruption-queue consumption;
- passing the Karpenter node role;
- instance-profile discovery;
- EKS cluster discovery.

The policy distinguishes between:

- request-tag authorization for newly created resources;
- resource-tag authorization for existing resources;
- read-only regional discovery;
- IAM instance-profile discovery.

### Result

PASS

The Karpenter controller has the permissions required to validate and manage AVOS application capacity.

## 19. Karpenter IAM Troubleshooting

Initial `EC2NodeClass` validation exposed incomplete IAM permissions.

The first failures included:

- missing `ec2:CreateTags` authorization during resource creation;
- missing `iam:ListInstanceProfiles`.

Those permissions were added through:

```text
AllowScopedResourceCreationTagging
AllowInstanceProfileListing
```

After those corrections, validation exposed a separate authorization failure:

```text
RunInstancesAuthCheckFailed
```

The controller was denied `ec2:RunInstances` against a Karpenter-created launch template.

The policy was corrected by separating:

- access to supporting EC2 resources;
- access to existing Karpenter-owned launch templates;
- creation operations governed by request tags;
- existing-resource operations governed by resource tags.

The corrected policy includes:

```text
AllowScopedEC2InstanceAccessActions
AllowScopedEC2LaunchTemplateAccessActions
```

After the corrected policy was applied and the Karpenter controller restarted, the `EC2NodeClass` and `NodePool` became ready.

### Result

PASS

The Karpenter IAM authorization issue was resolved using lifecycle-appropriate IAM conditions.

## 20. Karpenter Node Role

Karpenter-provisioned nodes use:

```text
avos-dev-karpenter-node-role
```

The role includes:

- `AmazonEKSWorkerNodePolicy`;
- `AmazonEC2ContainerRegistryPullOnly`;
- `AmazonSSMManagedInstanceCore`.

The controller can pass only this role to:

```text
ec2.amazonaws.com
```

The node role is registered with the EKS cluster through an EKS access entry.

### Result

PASS

Karpenter application nodes have a dedicated node identity.

## 21. Karpenter Instance Profile

The Karpenter node instance profile is:

```text
avos-dev-karpenter-node
```

The instance profile is created by Terraform and referenced by the `EC2NodeClass`.

Karpenter is not responsible for creating arbitrary IAM roles or instance profiles.

### Result

PASS

IAM identity creation remains under Terraform management.

## 22. Karpenter EC2NodeClass

The `EC2NodeClass` is:

```text
avos-dev-application
```

The class uses:

- Amazon Linux 2023;
- EKS-optimized AMI discovery;
- private application subnets;
- the EKS cluster security group;
- the Terraform-managed instance profile;
- encrypted `gp3` storage;
- IMDSv2;
- AVOS resource tags.

Karpenter-reserved ownership tags are not manually configured in `spec.tags`.

Final readiness:

```text
NAME                                                  READY
ec2nodeclass.karpenter.k8s.aws/avos-dev-application   True
```

Final conditions included successful validation of:

- AMIs;
- capacity reservations;
- placement groups;
- subnets;
- security groups;
- instance profile;
- launch authorization.

### Result

PASS

The Karpenter AWS node-class configuration is valid and ready.

## 23. Karpenter NodePool

The application NodePool is:

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
- approved instance families;
- approved EC2 generations;
- application labels;
- CPU and memory limits;
- consolidation;
- controlled disruption.

Final readiness:

```text
NAME                                NODECLASS              NODES   READY
nodepool.karpenter.sh/application   avos-dev-application   0       True
```

### Result

PASS

The NodePool is healthy and ready to provision application capacity.

## 24. Karpenter Capacity Validation Decision

A temporary workload provisioning test was not executed.

The accepted validation boundary for this phase was:

- Karpenter controller rollout successful;
- Pod Identity functional;
- IAM validation successful;
- `EC2NodeClass` ready;
- `NodePool` ready;
- Terraform configuration converged.

The NodePool contained zero nodes because no pending application workload required capacity.

A future application-deployment phase will provide an end-to-end capacity test when real AVOS workloads are scheduled.

### Result

ACCEPTED

The ready Karpenter resources are sufficient for completion of the Phase 5 foundation.

## 25. Karpenter Interruption Handling

The platform includes an SQS interruption queue and EventBridge integrations.

The configured events include:

- Spot interruption warnings;
- instance rebalance recommendations;
- instance state changes;
- AWS Health scheduled changes.

The Karpenter controller has permissions to:

- receive messages;
- retrieve queue attributes;
- retrieve the queue URL;
- delete processed messages.

### Result

PASS

Karpenter can receive infrastructure interruption notifications.

## 26. Terraform Remote Backend

The container-platform root uses the S3 backend.

The environment-specific backend configuration is provided through:

```text
backend.hcl
```

The safe repository template is:

```text
backend.hcl.example
```

The remote state key is:

```text
container-platform/terraform.tfstate
```

Sensitive backend values are not embedded in `backend.tf`.

### Result

PASS

The container platform has an independent remote Terraform state.

## 27. Terraform Formatting

Command:

```bash
terraform -chdir=terraform/container-platform fmt \
  -recursive
```

The command completed successfully.

`terraform.tfvars` was formatted during the final run.

### Result

PASS

The Terraform source follows canonical formatting.

## 28. Terraform Validation

Command:

```bash
terraform -chdir=terraform/container-platform validate
```

Observed result:

```text
Success! The configuration is valid.
```

### Result

PASS

Terraform accepted the final container-platform configuration.

## 29. Terraform Convergence

Command:

```bash
terraform -chdir=terraform/container-platform plan \
  -detailed-exitcode
```

Observed result:

```text
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.

Terraform plan exit code: 0
```

Exit code `0` means:

- planning completed successfully;
- Terraform detected no proposed infrastructure changes;
- the deployed infrastructure matches the declared configuration.

### Result

PASS

The container-platform Terraform root is fully converged.

## 30. Final Resource Summary

The completed platform includes:

- one EKS control plane;
- one dedicated EKS KMS key and alias;
- one encrypted EKS control-plane log group;
- one EKS cluster IAM role;
- one administrator EKS access entry;
- one administrator access-policy association;
- one managed system node group;
- one system-node IAM role;
- one system-node launch template;
- five EKS managed add-ons;
- dedicated Pod Identity roles and associations;
- one default encrypted `gp3` StorageClass;
- one Karpenter Helm release;
- one Karpenter controller IAM role and policy;
- one Karpenter node IAM role;
- one Karpenter node instance profile;
- one Karpenter node access entry;
- one interruption SQS queue;
- four EventBridge interruption rules and targets;
- one Karpenter `EC2NodeClass`;
- one Karpenter application `NodePool`.

## 31. Validation Matrix

| Control | Result |
|---|---|
| Terraform formatting | PASS |
| Terraform validation | PASS |
| Terraform convergence | PASS |
| Remote-state integration | PASS |
| Private subnet placement | PASS |
| Multi-AZ networking | PASS |
| Restricted EKS API access | PASS |
| API authentication mode | PASS |
| Explicit administrator access | PASS |
| Bootstrap creator access disabled