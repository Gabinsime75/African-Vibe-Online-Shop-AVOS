# EKS Module

## 🚀 Overview

This module provisions a production-grade Amazon EKS cluster for the CloudHustler Commerce Platform.

It creates the Kubernetes control plane, managed node groups, KMS encryption for Kubernetes secrets, CloudWatch logging, AWS-managed EKS add-ons, IAM OIDC provider, and modern EKS Access Entries.

The module is intentionally limited to core EKS infrastructure. Platform services such as the AWS Load Balancer Controller, ExternalDNS, Metrics Server, External Secrets Operator, Karpenter, and Istio are deployed separately after the cluster is operational.

---

## 🎯 Purpose

The purpose of this module is to provide a reusable, enterprise-grade Kubernetes foundation that can be deployed into multiple AWS accounts and environments.

The module is designed for:

- Development
- Staging
- Production
- Multi-account AWS Organizations

---

## 🏗 Architecture

```text
                    AWS Account
                         │
                         ▼
                Amazon EKS Cluster
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
   Managed Nodes     Control Plane     CloudWatch Logs
        │
        ▼
 AWS Managed Add-ons
        │
        ├── VPC CNI
        ├── CoreDNS
        ├── kube-proxy
        ├── EBS CSI Driver
        └── Pod Identity Agent
```

---

## 🚀 Features

- Production-ready Amazon EKS cluster
- Managed Node Groups
- Kubernetes Secrets Encryption using AWS KMS
- CloudWatch Control Plane Logging
- IAM OIDC Provider
- Modern EKS Access Entries
- AWS Managed Add-ons
- Enterprise tagging
- Multi-AZ support
- Private worker nodes
- Configurable API endpoint access
- Fully reusable across environments

---

## 📦 Resources Created

### Cluster

- aws_eks_cluster

### IAM

- aws_iam_role
- aws_iam_role_policy_attachment

### KMS

- aws_kms_key
- aws_kms_alias

### Managed Node Groups

- aws_eks_node_group

### AWS Managed Add-ons

- aws_eks_addon

### Access Management

- aws_eks_access_entry
- aws_eks_access_policy_association

### Identity

- aws_iam_openid_connect_provider

### Logging

- aws_cloudwatch_log_group

---

## 📁 Module Structure

```text
modules/
└── eks/
    ├── data.tf
    ├── locals.tf
    ├── cluster.tf
    ├── encryption.tf
    ├── node_groups.tf
    ├── addons.tf
    ├── access_entries.tf
    ├── oidc.tf
    ├── cloudwatch.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

---

## 📥 Inputs

Major input categories include:

- Cluster configuration
- VPC configuration
- Managed Node Groups
- Kubernetes version
- CloudWatch logging
- KMS encryption
- AWS managed add-ons
- Access entries
- OIDC provider
- Resource tags

---

## 📤 Outputs

Major outputs include:

- Cluster ARN
- Cluster Endpoint
- Certificate Authority Data
- Cluster Security Group
- Node Group ARNs
- IAM Role ARNs
- OIDC Provider ARN
- KMS Key ARN
- CloudWatch Log Group
- Installed AWS Add-ons

---

## 💻 Example Usage

```hcl
module "eks" {
  source = "../modules/eks"

  cluster_name       = "cloudhustler-dev"
  kubernetes_version = "1.33"

  subnet_ids = [
    module.vpc.private_app_subnet_ids[0],
    module.vpc.private_app_subnet_ids[1]
  ]

  node_groups = {
    system = {
      subnet_ids     = module.vpc.private_app_subnet_ids
      instance_types = ["t3.medium"]

      desired_size = 2
      min_size     = 2
      max_size     = 4
    }
  }

  tags = local.common_tags
}
```

---

## 🔒 Security Considerations

This module follows AWS production best practices.

- Kubernetes Secrets encrypted using AWS KMS
- Private worker nodes
- IAM Roles for EKS Control Plane
- IAM Roles for Managed Node Groups
- OIDC Provider for workload identity
- EKS Access Entries instead of the legacy aws-auth ConfigMap
- CloudWatch logging enabled
- Enterprise tagging

---

## 💡 Design Decisions

This module intentionally deploys only the Kubernetes platform.

The following platform components are deployed separately:

- AWS Load Balancer Controller
- ExternalDNS
- Metrics Server
- External Secrets Operator
- Karpenter / Cluster Autoscaler
- Istio Service Mesh
- Prometheus
- Grafana
- Kiali

Separating the Kubernetes infrastructure from platform services makes the module easier to upgrade, test, and reuse across environments.

---

## 📖 Next Steps

After deploying this module:

1. Deploy the Container Platform root module.
2. Install AWS Load Balancer Controller.
3. Install ExternalDNS.
4. Install External Secrets Operator.
5. Install Metrics Server.
6. Install Karpenter or Cluster Autoscaler.
7. Install Istio Service Mesh.
8. Deploy the observability stack.
9. Deploy workloads.