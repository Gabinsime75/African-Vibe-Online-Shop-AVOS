# AVOS Container Platform

This Terraform root implements the Amazon EKS container-platform foundation for the African Vibe Online Shop (AVOS).

The platform combines stable system capacity with dynamically provisioned application capacity:

- an EKS managed node group hosts critical Kubernetes and platform components;
- Karpenter provisions application nodes when workload demand appears.

The configuration is independently managed through the remote Terraform state:

```text
container-platform/terraform.tfstate
```

## Platform Summary

| Component | Configuration |
|---|---|
| AWS Region | `us-east-2` |
| Environment | `dev` |
| EKS cluster | `avos-dev-eks` |
| Kubernetes version | `1.35` |
| Cluster authentication | EKS API access entries |
| Worker networking | Three private application subnets |
| System capacity | EKS managed node group |
| Application capacity | Karpenter |
| Workload identity | EKS Pod Identity |
| Secrets encryption | Customer-managed AWS KMS key |
| Persistent storage | Encrypted default `gp3` StorageClass |
| Control-plane logs | CloudWatch Logs with KMS encryption |
| Terraform backend | Amazon S3 with native state locking |

## Architecture

```text
IAM Identity Center administrator
                |
                v
Restricted EKS API endpoint
                |
                v
        Amazon EKS control plane
                |
        +-------+-------+
        |       |       |
        v       v       v
    us-east-2a  2b      2c
        |       |       |
        +-------+-------+
                |
        Private application subnets
                |
        +-------+----------------+
        |                        |
        v                        v
Managed system node group   Karpenter NodePool
        |                        |
        |                        +-- AVOS application workloads
        |
        +-- CoreDNS
        +-- Karpenter controller
        +-- VPC CNI
        +-- kube-proxy
        +-- Pod Identity Agent
        +-- EBS CSI components
```

## Design Decisions

The complete architecture decision is documented in:

```text
Docs/ADR/ADR-004-avos-container-platform.md
```

The corresponding validation evidence is documented in:

```text
Docs/Phase-validation/Phase-5/PHASE-5-VALIDATION-REPORT.md
```

### Hybrid capacity

The cluster separates system capacity from application capacity.

The managed node group provides predictable capacity for components required to keep the cluster operational.

Karpenter provides flexible application capacity and can leave the application NodePool at zero nodes when no pending workload requires compute.

This avoids making Karpenter dependent on capacity that Karpenter must provision itself.

### Private worker networking

The EKS cluster and worker nodes use the private application subnets exported by the networking Terraform state.

Worker nodes do not receive direct public placement.

Outbound traffic uses the network foundation’s NAT and VPC endpoint architecture.

### Restricted API access

The EKS Kubernetes API supports:

- private access from the VPC;
- restricted public access from explicitly approved administrator CIDRs.

The endpoint is not intentionally exposed to `0.0.0.0/0`.

The approved administrator CIDR must be updated when the trusted public IP changes.

### API-based authentication

The cluster uses:

```text
authentication_mode = "API"
```

Administrator access is managed through EKS access entries and access-policy associations.

The legacy `aws-auth` ConfigMap is not the primary access-management mechanism.

### Pod Identity

Supported AWS-integrated controllers use EKS Pod Identity.

Pod Identity is configured for:

- Karpenter;
- Amazon VPC CNI;
- Amazon EBS CSI Driver.

Each controller receives a dedicated IAM role.

### Encryption

A dedicated customer-managed KMS key encrypts:

- Kubernetes secrets;
- EKS control-plane CloudWatch logs.

The default `gp3` StorageClass also requests encrypted EBS volumes.

## Prerequisites

Before using this Terraform root, verify the following:

- AWS CLI is installed;
- Terraform is installed;
- `kubectl` is installed;
- Helm is installed;
- an AVOS IAM Identity Center profile is configured;
- the networking Terraform root has been applied;
- the networking remote state is accessible;
- the Terraform state bucket and KMS key exist;
- the approved EKS API CIDR is known.

## AWS Authentication

Authenticate with the AVOS administrator profile:

```bash
export AWS_PROFILE="avos-admin"
export AWS_REGION="us-east-2"
export AWS_DEFAULT_REGION="us-east-2"

aws sso login \
  --profile "$AWS_PROFILE"
```

Verify the active identity:

```bash
aws sts get-caller-identity \
  --profile "$AWS_PROFILE" \
  --query '{
    Account:Account,
    Arn:Arn,
    UserId:UserId
  }' \
  --output table
```

The expected account is:

```text
396913735153
```

## Backend Configuration

The Terraform backend block is declared in:

```text
backend.tf
```

Environment-specific backend values are provided through:

```text
backend.hcl
```

The repository includes the safe example:

```text
backend.hcl.example
```

Create the local backend configuration:

```bash
cd terraform/container-platform

cp backend.hcl.example backend.hcl
```

Replace the placeholders in `backend.hcl` with the AVOS state bucket and KMS key values.

The backend key must remain:

```text
container-platform/terraform.tfstate
```

Do not commit `backend.hcl`.

Initialize the backend:

```bash
terraform init \
  -reconfigure \
  -backend-config=backend.hcl
```

If the SSO session has expired, refresh it before initializing:

```bash
aws sso login \
  --profile avos-admin
```

## Terraform Variables

Environment-specific Terraform values are provided through:

```text
terraform.tfvars
```

The repository includes:

```text
terraform.tfvars.example
```

Create the local file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Do not commit `terraform.tfvars`.

The configuration includes values for areas such as:

- project name;
- environment;
- AWS Region;
- Kubernetes version;
- administrator role ARN;
- approved EKS API CIDRs;
- managed-node capacity;
- managed-node instance types;
- EKS add-on versions;
- Karpenter version;
- Karpenter capacity settings;
- resource tags.

## Approved Administrator CIDR

Determine the current public IPv4 address:

```bash
export AVOS_ADMIN_PUBLIC_IP="$(
  curl -4fsS https://checkip.amazonaws.com \
    | tr -d '\r\n'
)"

export AVOS_ADMIN_PUBLIC_CIDR="${AVOS_ADMIN_PUBLIC_IP}/32"

printf 'Approved EKS API CIDR: %s\n' \
  "$AVOS_ADMIN_PUBLIC_CIDR"
```

Update `terraform.tfvars` if the approved administrator CIDR has changed.

Always review the plan carefully because changing the approved CIDR modifies access to the Kubernetes API.

## Terraform Workflow

Run commands from the repository root.

### Format

```bash
terraform -chdir=terraform/container-platform fmt \
  -recursive
```

### Initialize

```bash
terraform -chdir=terraform/container-platform init \
  -reconfigure \
  -backend-config=backend.hcl
```

### Validate

```bash
terraform -chdir=terraform/container-platform validate
```

### Plan

```bash
terraform -chdir=terraform/container-platform plan \
  -out=container-platform.tfplan \
  -detailed-exitcode

PLAN_EXIT_CODE=$?
echo "Terraform plan exit code: $PLAN_EXIT_CODE"
```

Terraform detailed exit codes mean:

| Exit code | Meaning |
|---|---|
| `0` | Plan succeeded and no changes are required |
| `1` | Terraform encountered an error |
| `2` | Plan succeeded and proposes changes |

### Inspect the saved plan

```bash
terraform -chdir=terraform/container-platform show \
  -no-color \
  container-platform.tfplan
```

Review all proposed changes before applying.

Pay particular attention to:

- resource replacement;
- EKS cluster version changes;
- managed node-group replacement;
- API endpoint CIDR changes;
- IAM policy changes;
- KMS key changes;
- Karpenter configuration changes;
- resource destruction.

### Apply

```bash
terraform -chdir=terraform/container-platform apply \
  container-platform.tfplan
```

### Confirm convergence

```bash
terraform -chdir=terraform/container-platform plan \
  -detailed-exitcode

PLAN_EXIT_CODE=$?
echo "Terraform plan exit code: $PLAN_EXIT_CODE"
```

A converged root returns:

```text
No changes. Your infrastructure matches the configuration.
Terraform plan exit code: 0
```

## Connecting kubectl

Update the local kubeconfig:

```bash
aws eks update-kubeconfig \
  --name avos-dev-eks \
  --region us-east-2 \
  --profile avos-admin
```

Confirm the active context:

```bash
kubectl config current-context
```

Confirm cluster access:

```bash
kubectl get nodes \
  -o wide
```

## EKS Managed Add-ons

The cluster installs:

- Amazon VPC CNI;
- CoreDNS;
- kube-proxy;
- EKS Pod Identity Agent;
- Amazon EBS CSI Driver.

Inspect their status:

```bash
aws eks list-addons \
  --cluster-name avos-dev-eks \
  --region us-east-2 \
  --profile avos-admin \
  --output table
```

Inspect the installed versions:

```bash
for addon_name in \
  vpc-cni \
  coredns \
  kube-proxy \
  eks-pod-identity-agent \
  aws-ebs-csi-driver
do
  aws eks describe-addon \
    --cluster-name avos-dev-eks \
    --addon-name "$addon_name" \
    --region us-east-2 \
    --profile avos-admin \
    --query 'addon.{
      Name:addonName,
      Version:addonVersion,
      Status:status,
      Health:health.issues
    }' \
    --output table
done
```

## Managed System Node Group

Inspect the managed node group:

```bash
aws eks describe-nodegroup \
  --cluster-name avos-dev-eks \
  --nodegroup-name avos-dev-system \
  --region us-east-2 \
  --profile avos-admin \
  --query 'nodegroup.{
    Name:nodegroupName,
    Status:status,
    AMIType:amiType,
    CapacityType:capacityType,
    InstanceTypes:instanceTypes,
    Desired:scalingConfig.desiredSize,
    Minimum:scalingConfig.minSize,
    Maximum:scalingConfig.maxSize,
    Subnets:subnets
  }' \
  --output table
```

Inspect Kubernetes nodes:

```bash
kubectl get nodes \
  -o wide
```

Critical system services should remain schedulable on this managed capacity.

## StorageClass

Inspect available StorageClasses:

```bash
kubectl get storageclass
```

Inspect the default `gp3` StorageClass:

```bash
kubectl describe storageclass \
  gp3
```

Expected characteristics:

```text
Provisioner:           ebs.csi.aws.com
ReclaimPolicy:         Delete
VolumeBindingMode:     WaitForFirstConsumer
AllowVolumeExpansion:  True
encrypted:             true
type:                  gp3
```

## Karpenter

Karpenter is installed in:

```text
kube-system
```

Inspect its deployment:

```bash
kubectl get deployment \
  karpenter \
  -n kube-system
```

Check the rollout:

```bash
kubectl rollout status \
  deployment/karpenter \
  -n kube-system \
  --timeout=90s
```

Inspect controller Pods:

```bash
kubectl get pods \
  -n kube-system \
  -l app.kubernetes.io/name=karpenter \
  -o wide
```

Inspect controller logs:

```bash
kubectl logs \
  -n kube-system \
  -l app.kubernetes.io/name=karpenter \
  --all-containers=true \
  --since=15m \
  --prefix
```

## Karpenter Capacity Resources

Inspect the application `EC2NodeClass`:

```bash
kubectl get ec2nodeclass \
  avos-dev-application
```

Inspect its readiness conditions:

```bash
kubectl get ec2nodeclass \
  avos-dev-application \
  -o jsonpath='{range .status.conditions[*]}{.type}{"="}{.status}{" | "}{.reason}{" | "}{.message}{"\n"}{end}'
```

Inspect the application NodePool:

```bash
kubectl get nodepool \
  application
```

Inspect both resources:

```bash
kubectl get ec2nodeclass,nodepool
```

The healthy idle state is:

```text
EC2NodeClass READY=True
NodePool     READY=True
NodePool     NODES=0
```

`NODES=0` is expected when no application workload requires additional capacity.

## Karpenter Interruption Handling

Inspect the interruption queue:

```bash
aws sqs get-queue-attributes \
  --queue-url "$(
    aws sqs get-queue-url \
      --queue-name avos-dev-karpenter-interruption \
      --region us-east-2 \
      --profile avos-admin \
      --query QueueUrl \
      --output text
  )" \
  --attribute-names All \
  --region us-east-2 \
  --profile avos-admin \
  --output json
```

Inspect the EventBridge rules:

```bash
aws events list-rules \
  --name-prefix avos-dev-karpenter \
  --region us-east-2 \
  --profile avos-admin \
  --query 'Rules[].{
    Name:Name,
    State:State,
    Description:Description
  }' \
  --output table
```

## Pod Identity

Inspect all EKS Pod Identity associations:

```bash
aws eks list-pod-identity-associations \
  --cluster-name avos-dev-eks \
  --region us-east-2 \
  --profile avos-admin \
  --output table
```

Inspect a specific association by its association ID:

```bash
aws eks describe-pod-identity-association \
  --cluster-name avos-dev-eks \
  --association-id REPLACE_WITH_ASSOCIATION_ID \
  --region us-east-2 \
  --profile avos-admin \
  --output json
```

## Control-Plane Logs

Inspect the EKS log group:

```bash
MSYS_NO_PATHCONV=1 aws logs describe-log-groups \
  --log-group-name-prefix "/aws/eks/avos-dev-eks/cluster" \
  --region us-east-2 \
  --profile avos-admin \
  --query 'logGroups[].{
    Name:logGroupName,
    Arn:arn,
    RetentionDays:retentionInDays,
    KmsKeyId:kmsKeyId,
    Class:logGroupClass,
    StoredBytes:storedBytes
  }' \
  --output table
```

`MSYS_NO_PATHCONV=1` prevents Git Bash from converting the leading `/aws/...` value into a Windows filesystem path.

## Terraform Outputs

Display all exported values:

```bash
terraform -chdir=terraform/container-platform output
```

Important outputs include:

- `cluster_name`;
- `cluster_arn`;
- `cluster_endpoint`;
- `cluster_version`;
- `cluster_platform_version`;
- `cluster_status`;
- `cluster_security_group_id`;
- `cluster_private_subnet_ids`;
- `cluster_oidc_issuer`;
- `cluster_kms_key_arn`;
- `cluster_kms_alias`;
- `control_plane_log_group_name`;
- `cluster_iam_role_arn`;
- `system_node_group_name`;
- `system_node_group_status`;
- `system_node_role_arn`;
- `system_launch_template_id`;
- `managed_addon_versions`;
- `gp3_storage_class_name`;
- `karpenter_controller_role_arn`;
- `karpenter_node_role_arn`;
- `karpenter_instance_profile_name`;
- `karpenter_interruption_queue_name`;
- `karpenter_interruption_queue_arn`;
- `karpenter_helm_release`;
- `karpenter_ec2_node_class_name`;
- `karpenter_node_pool_name`;
- `administrator_access_entry_arn`.

## Repository Files

| File | Purpose |
|---|---|
| `.terraform.lock.hcl` | Locks Terraform provider versions |
| `access-entries.tf` | EKS administrator and node access entries |
| `addons-after-compute.tf` | Add-ons that require available worker capacity |
| `addons-before-compute.tf` | Add-ons required before dependent resources |
| `backend.hcl.example` | Safe backend configuration template |
| `backend.tf` | Declares the S3 backend |
| `checks.tf` | Terraform configuration assertions |
| `cloudwatch.tf` | EKS control-plane log group |
| `data.tf` | AWS and networking remote-state data sources |
| `eks-cluster.tf` | EKS control-plane resource |
| `iam-addons.tf` | IAM roles for EKS add-ons |
| `iam-cluster.tf` | EKS control-plane IAM role and policies |
| `iam-karpenter-controller.tf` | Karpenter controller IAM configuration |
| `iam-karpenter-nodes.tf` | Karpenter node role and instance profile |
| `iam-nodes.tf` | Managed system-node IAM configuration |
| `karpenter-capacity.tf` | Karpenter `EC2NodeClass` and `NodePool` |
| `karpenter-helm.tf` | Karpenter Helm release |
| `karpenter-interruption.tf` | SQS and EventBridge interruption handling |
| `kms.tf` | EKS customer-managed KMS key |
| `locals.tf` | Derived values, names, maps, and tags |
| `managed-node-group.tf` | Fixed EKS system node group |
| `outputs.tf` | Exported container-platform values |
| `providers.tf` | AWS, Kubernetes, and Helm providers |
| `storage-class.tf` | Default encrypted `gp3` StorageClass |
| `terraform.tfvars.example` | Safe variable-value template |
| `variables.tf` | Input-variable declarations and validation |
| `versions.tf` | Terraform and provider requirements |

## Security Controls

The root implements the following security controls:

- worker nodes in private subnets;
- public EKS API access restricted by CIDR;
- private EKS API access enabled;
- explicit API-based access entries;
- cluster-creator bootstrap access disabled;
- KMS encryption for Kubernetes secrets;
- KMS encryption for control-plane logs;
- encrypted EBS persistent volumes;
- dedicated IAM roles by responsibility;
- Pod Identity for supported controllers;
- IMDSv2 for Karpenter nodes;
- tag-scoped Karpenter permissions;
- dedicated Terraform remote state;
- no committed backend credentials;
- no committed Terraform variable secrets.

## Operational Notes

### Changing the administrator IP

If the trusted public IP changes:

1. determine the new `/32` CIDR;
2. update `terraform.tfvars`;
3. create and inspect a saved Terraform plan;
4. apply the plan;
5. confirm `kubectl` access;
6. confirm final Terraform convergence.

Do not remove the currently working CIDR until access through the replacement CIDR has been considered.

### Upgrading Kubernetes

Before upgrading:

1. confirm the target EKS version is supported;
2. verify managed add-on compatibility;
3. verify Karpenter compatibility;
4. review deprecated Kubernetes APIs;
5. review system-node AMI support;
6. update the control plane first;
7. update add-ons;
8. update managed nodes;
9. validate Karpenter;
10. validate applications.

Kubernetes version upgrades should be handled as controlled lifecycle changes, not routine unattended updates.

### Karpenter readiness

A ready NodePool with zero nodes is healthy when no eligible workload is pending.

Investigate when either resource reports `READY=False`.

Useful commands:

```bash
kubectl get ec2nodeclass,nodepool

kubectl describe ec2nodeclass \
  avos-dev-application

kubectl describe nodepool \
  application
```

### Do not manually modify managed resources

Avoid manually changing:

- EKS endpoint settings;
- access entries;
- add-on versions;
- IAM policies;
- managed node-group scaling;
- KMS policies;
- Karpenter manifests;
- the default StorageClass.

Make persistent changes through Terraform.

## Validation

Run the final validation sequence:

```bash
terraform -chdir=terraform/container-platform fmt \
  -check \
  -recursive

terraform -chdir=terraform/container-platform validate

terraform -chdir=terraform/container-platform plan \
  -detailed-exitcode

PLAN_EXIT_CODE=$?
echo "Terraform plan exit code: $PLAN_EXIT_CODE"

kubectl rollout status \
  deployment/karpenter \
  -n kube-system \
  --timeout=90s

kubectl wait \
  --for=condition=Ready \
  ec2nodeclass/avos-dev-application \
  --timeout=120s

kubectl wait \
  --for=condition=Ready \
  nodepool/application \
  --timeout=120s

kubectl get ec2nodeclass,nodepool
```

The final Terraform result should be:

```text
No changes. Your infrastructure matches the configuration.
Terraform plan exit code: 0
```

The Karpenter resources should report:

```text
READY=True
```

## Current Validation Status

Phase 5 was validated on October 4, 2026.

Final results:

- Terraform formatting: PASS;
- Terraform validation: PASS;
- Terraform convergence: PASS;
- EKS cluster: PASS;
- system node group: PASS;
- managed add-ons: PASS;
- Pod Identity: PASS;
- encrypted `gp3` StorageClass: PASS;
- Karpenter controller rollout: PASS;
- Karpenter `EC2NodeClass`: PASS;
- Karpenter `NodePool`: PASS.

The live application-node provisioning test was deferred until real AVOS workloads are deployed.

## Related Documentation

- `Docs/ADR/ADR-004-avos-container-platform.md`
- `Docs/Phase-validation/Phase-5/PHASE-5-VALIDATION-REPORT.md`
- `terraform/networking/README.md`