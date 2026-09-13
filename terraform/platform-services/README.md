# Kubernetes Platform Services Root

## 🚀 Overview

This Terraform root deploys Kubernetes platform services into the existing CloudHustler Commerce Platform Amazon EKS cluster.

The root is separate from the EKS container-platform root so that Kubernetes controllers, Helm releases, IAM roles, and Pod Identity associations can evolve independently from the lifecycle of the EKS cluster.

The first platform service deployed by this root is the AWS Load Balancer Controller.

## 🎯 Purpose

The purpose of this root is to orchestrate reusable Kubernetes platform-service modules.

Each platform service is implemented as an independent reusable Terraform module and called from this root one service at a time.

The initial deployment includes:

- AWS Load Balancer Controller
- Least-privilege TargetGroupBinding IAM policy
- EKS Pod Identity IAM role
- EKS Pod Identity association
- Helm deployment into the existing EKS cluster

## 🏗 Architecture


```text
Networking Root
├── Route 53
├── AWS WAF
├── Existing Application Load Balancer
└── Existing Istio IP Target Group
                 │
                 │ TargetGroupBinding
                 ▼
Platform Services Root
├── AWS Load Balancer Controller
├── Pod Identity IAM Role
├── Pod Identity Association
└── Helm Release
                 │
                 ▼
Amazon EKS Cluster
```

## 🚀 Features

- Connects to an existing EKS cluster
- Authenticates using `aws eks get-token`
- Uses the AWS, Kubernetes, and Helm providers
- Installs the AWS Load Balancer Controller
- Uses EKS Pod Identity
- Restricts controller permissions to approved target groups
- Preserves the Terraform-managed ALB
- Does not create another public load balancer
- Supports incremental addition of platform-service modules
- Applies consistent enterprise tags

## 📦 Resources Created

Resources are currently created through the AWS Load Balancer Controller module:

- `aws_iam_policy`
- `aws_iam_role`
- `aws_iam_role_policy_attachment`
- `aws_eks_pod_identity_association`
- `helm_release`

## 📁 Root Structure

```text
platform-services/
├── versions.tf
├── providers.tf
├── locals.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── terraform.tfvars.example
└── README.md
```

## 📥 Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `project_name` | Project name | `string` | n/a |
| `environment` | Deployment environment | `string` | n/a |
| `aws_region` | AWS region containing the cluster | `string` | n/a |
| `cluster_name` | Existing EKS cluster name | `string` | n/a |
| `vpc_id` | Existing VPC ID | `string` | n/a |
| `istio_ingress_target_group_arn` | Existing Istio target-group ARN | `string` | n/a |
| `aws_load_balancer_controller_namespace` | Controller namespace | `string` | `kube-system` |
| `aws_load_balancer_controller_service_account_name` | Controller service account | `string` | `aws-load-balancer-controller` |
| `aws_load_balancer_controller_release_name` | Helm release name | `string` | `aws-load-balancer-controller` |
| `aws_load_balancer_controller_chart_version` | Helm chart version | `string` | `null` |
| `aws_load_balancer_controller_replica_count` | Controller replicas | `number` | `2` |
| `aws_load_balancer_controller_helm_timeout` | Helm timeout in seconds | `number` | `600` |
| `tags` | Additional AWS resource tags | `map(string)` | `{}` |

## 📤 Outputs

| Name | Description |
|---|---|
| `aws_load_balancer_controller_iam_policy_arn` | Controller IAM policy ARN |
| `aws_load_balancer_controller_pod_identity_role_arn` | Pod Identity role ARN |
| `aws_load_balancer_controller_pod_identity_association_id` | Pod Identity association ID |
| `aws_load_balancer_controller_release_name` | Helm release name |
| `aws_load_balancer_controller_release_namespace` | Helm release namespace |
| `aws_load_balancer_controller_release_status` | Helm release status |
| `aws_load_balancer_controller_service_account_name` | Controller service account |
| `managed_target_group_arns` | Target groups the controller may manage |

## 💻 Current Module Call

```hcl
module "aws_load_balancer_controller" {
  source = "../modules/aws-load-balancer-controller"

  cluster_name = var.cluster_name
  aws_region   = var.aws_region
  vpc_id       = var.vpc_id

  target_group_arns = [
    var.istio_ingress_target_group_arn
  ]

  iam_policy_name = "${local.name_prefix}-lbc-tgb-policy"
  iam_role_name   = "${local.name_prefix}-lbc-pod-identity-role"

  namespace            = "kube-system"
  service_account_name = "aws-load-balancer-controller"

  replica_count = 2

  enable_service_mutator_webhook = false

  tags = local.common_tags
}
```

## 🔒 Security Considerations

The AWS Load Balancer Controller receives only the permissions required to manage TargetGroupBinding registrations for approved target groups.

The controller is not permitted to create or delete:

- Application Load Balancers
- Listeners
- Listener rules
- Target groups
- Route 53 records
- ACM certificates
- WAF resources

EKS Pod Identity is used instead of assigning controller permissions to the worker-node IAM role.

The IAM principal running Terraform must already have EKS access sufficient to install Helm charts and Kubernetes resources.

## 💡 Design Decisions

The EKS cluster lifecycle remains owned by the `container-platform` root.

AWS networking resources remain owned by the `networking` root.

Platform services installed inside Kubernetes are owned by this root.

This separation prevents Helm and Kubernetes resources from becoming tightly coupled to EKS cluster creation or AWS networking changes.

The root is expanded incrementally. A new module is added only after the previous platform service has been deployed and verified successfully.

## 📖 Phase 6 Roadmap

```text
Phase 6 — Kubernetes Platform Services

├── 1. AWS Load Balancer Controller      In progress
├── 2. Metrics Server
├── 3. Istio Control Plane
├── 4. Istio Ingress Gateway
├── 5. TargetGroupBinding
├── 6. ExternalDNS
├── 7. External Secrets Operator
├── 8. Karpenter or Cluster Autoscaler
├── 9. Cert-Manager if needed
└── 10. Kiali, Jaeger, and OpenTelemetry
```

## 📖 Next Steps

1. Run `terraform init`.
2. Run `terraform fmt`.
3. Run `terraform validate`.
4. Run `terraform plan`.
5. Review IAM, Pod Identity, and Helm resources.
6. Run `terraform apply`.
7. Verify the controller deployment.
8. Verify the controller Pod Identity association.
9. Begin the Metrics Server module.