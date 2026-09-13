# AWS Load Balancer Controller Module

## 🚀 Overview

This module installs the AWS Load Balancer Controller into an existing Amazon EKS cluster.

The module is specifically designed for the CloudHustler Commerce Platform architecture, where the public Application Load Balancer and its target groups are provisioned and managed by the networking Terraform root.

The controller is used only to manage Kubernetes `TargetGroupBinding` resources and register or deregister pod IP addresses in approved existing target groups.

It does not create or manage the public Application Load Balancer.

## 🎯 Purpose

The purpose of this module is to connect Kubernetes workloads to externally managed AWS target groups.

For CloudHustler, the controller will eventually connect the Istio ingress gateway Service to the dedicated Istio IP target group:

```text
Route 53
   ↓
AWS WAF
   ↓
Existing Terraform-managed ALB
   ↓
Existing Istio IP target group
   ↓
TargetGroupBinding
   ↓
Istio ingress gateway pods
```

## 🏗 Architecture

```text
Networking Terraform
├── Application Load Balancer
├── HTTPS listener
├── WAF association
└── Istio ingress IP target group
              │
              │ TargetGroupBinding
              ▼
Amazon EKS Cluster
├── AWS Load Balancer Controller
├── EKS Pod Identity Agent
├── Istio ingress gateway Service
└── Istio ingress gateway pods
```

## 🚀 Features

- Installs AWS Load Balancer Controller with Helm
- Uses EKS Pod Identity
- Creates a least-privilege IAM policy
- Restricts target registration permissions to approved target-group ARNs
- Supports externally managed ALBs and target groups
- Supports Kubernetes `TargetGroupBinding`
- Does not create Kubernetes Ingress resources
- Does not create a second Application Load Balancer
- Configures explicit AWS region and VPC ID
- Supports highly available controller replicas
- Supports configurable Helm values
- Supports enterprise resource tagging

## 📦 Resources Created

- `aws_iam_policy`
- `aws_iam_role`
- `aws_iam_role_policy_attachment`
- `aws_eks_pod_identity_association`
- `helm_release`

## 📁 Module Structure

```text
modules/aws-load-balancer-controller/
├── iam.tf
├── pod_identity.tf
├── helm.tf
├── variables.tf
├── outputs.tf
└── README.md
```

## 📥 Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `cluster_name` | Name of the EKS cluster | `string` | n/a |
| `aws_region` | AWS region containing the EKS cluster | `string` | n/a |
| `vpc_id` | VPC containing the cluster and target groups | `string` | n/a |
| `target_group_arns` | Target groups the controller may manage | `list(string)` | n/a |
| `create_iam_policy` | Create the controller IAM policy | `bool` | `true` |
| `iam_policy_name` | IAM policy name | `string` | `AWSLoadBalancerControllerTargetGroupBindingPolicy` |
| `existing_iam_policy_arn` | Existing policy ARN when policy creation is disabled | `string` | `null` |
| `create_pod_identity_role` | Create the Pod Identity IAM role | `bool` | `true` |
| `iam_role_name` | Pod Identity IAM role name | `string` | n/a |
| `existing_pod_identity_role_arn` | Existing role ARN when role creation is disabled | `string` | `null` |
| `create_pod_identity_association` | Create the Pod Identity association | `bool` | `true` |
| `namespace` | Controller namespace | `string` | `kube-system` |
| `service_account_name` | Controller service account name | `string` | `aws-load-balancer-controller` |
| `release_name` | Helm release name | `string` | `aws-load-balancer-controller` |
| `chart_version` | Optional pinned Helm chart version | `string` | `null` |
| `replica_count` | Number of controller replicas | `number` | `2` |
| `enable_service_mutator_webhook` | Enable LoadBalancer Service mutation | `bool` | `false` |
| `helm_timeout` | Helm timeout in seconds | `number` | `600` |
| `additional_set_values` | Additional Helm set values | `map(string)` | `{}` |
| `values` | Additional raw YAML chart values | `list(string)` | `[]` |
| `tags` | Tags applied to AWS resources | `map(string)` | `{}` |

## 📤 Outputs

| Name | Description |
|---|---|
| `iam_policy_arn` | IAM policy ARN |
| `pod_identity_role_arn` | Pod Identity role ARN |
| `pod_identity_association_id` | Pod Identity association ID |
| `release_name` | Helm release name |
| `release_namespace` | Helm release namespace |
| `release_status` | Helm release status |
| `service_account_name` | Controller service account |
| `managed_target_group_arns` | Target groups the controller may manage |

## 💻 Example Usage

```hcl
module "aws_load_balancer_controller" {
  source = "../modules/aws-load-balancer-controller"

  cluster_name = "cloudhusller-commerce-platform-dev-eks"
  aws_region   = "us-east-2"
  vpc_id       = "vpc-0ce54763ce1eb47dd"

  target_group_arns = [
    "arn:aws:elasticloadbalancing:us-east-2:396913735153:targetgroup/cloudhusller-dev-istio-ingress/9006c6af2bc4dbd0"
  ]

  iam_policy_name = "cloudhusller-dev-lbc-target-group-binding-policy"
  iam_role_name   = "cloudhusller-dev-aws-load-balancer-controller"

  namespace            = "kube-system"
  service_account_name = "aws-load-balancer-controller"

  replica_count = 2

  enable_service_mutator_webhook = false

  tags = {
    Project     = "cloudhusller-commerce-platform"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Layer       = "PlatformServices"
  }
}
```

## 🔒 Security Considerations

The controller receives only the permissions required for `TargetGroupBinding` operations.

The policy permits the controller to:

- Discover the VPC, security groups, instances, and target groups
- Read target health
- Register pod IP addresses
- Deregister pod IP addresses
- Update approved target-group settings

Target-group modification permissions are restricted to the ARNs supplied through `target_group_arns`.

The module does not grant permissions to:

- Create an ALB
- Delete an ALB
- Create listeners
- Modify listeners
- Create target groups
- Delete target groups
- Modify WAF
- Modify Route 53
- Modify ACM certificates

Kubernetes RBAC should restrict who can create `TargetGroupBinding` resources because an authorized user could otherwise connect workloads to target groups available to the controller.

## 💡 Design Decisions

The CloudHustler ALB remains managed by the networking Terraform state.

This module installs the AWS Load Balancer Controller only for pod registration through `TargetGroupBinding`.

The controller receives the AWS region and VPC ID explicitly rather than relying on EC2 Instance Metadata Service discovery.

EKS Pod Identity is used instead of attaching permissions to worker node roles. This preserves least privilege and prevents all workloads on a node from inheriting load-balancer permissions.

The Service Mutator Webhook is disabled because CloudHustler is not using the controller to convert Kubernetes `LoadBalancer` Services into AWS load balancers.

## 📖 Next Steps

After deploying this module:

1. Verify the controller deployment.
2. Verify the Pod Identity association.
3. Install Metrics Server.
4. Install the Istio control plane.
5. Install the Istio ingress gateway.
6. Create a `TargetGroupBinding` for the Istio ingress gateway Service.
7. Verify that Istio pod IP addresses become healthy ALB targets.
8. Update the existing HTTPS listener to forward traffic to the Istio target group.