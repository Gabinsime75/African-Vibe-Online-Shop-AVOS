# ExternalDNS Module

---

# 🚀 Overview

This module deploys **ExternalDNS** into an Amazon EKS cluster using the official Helm chart and integrates it with **Amazon Route 53** using **EKS Pod Identity**.

ExternalDNS continuously watches Kubernetes resources and automatically creates, updates, and removes DNS records in Route 53, eliminating manual DNS management.

This module is production-ready and designed for multi-environment deployments across Development, Staging, and Production.

---

# 🎯 Purpose

This module automates DNS management by:

- Deploying ExternalDNS using Helm
- Creating an IAM Role with least-privilege Route53 permissions
- Configuring EKS Pod Identity
- Creating the Kubernetes namespace
- Deploying the ExternalDNS ServiceAccount
- Synchronizing Route53 DNS records
- Managing TXT ownership records
- Supporting Istio Gateways and Kubernetes Ingress resources

---

# 🏗 Architecture

```text
                   +---------------------------+
                   |     Route53 Hosted Zone   |
                   +------------▲--------------+
                                │
                        Route53 API Calls
                                │
                   +------------┴--------------+
                   |        IAM Policy         |
                   +------------▲--------------+
                                │
                   +------------┴--------------+
                   |          IAM Role         |
                   +------------▲--------------+
                                │
              EKS Pod Identity Association
                                │
                   +------------▲--------------+
                   | Kubernetes ServiceAccount |
                   +------------▲--------------+
                                │
                   +------------┴--------------+
                   |       ExternalDNS Pod     |
                   +------------▲--------------+
                                │
                Watches Kubernetes Resources
                                │
      Services • Ingress • Istio Gateway • VirtualService
```

---

# 🚀 Features

- Official ExternalDNS Helm Chart
- Amazon Route53 Provider
- EKS Pod Identity
- Least-Privilege IAM Policy
- TXT Registry Ownership
- Domain Filtering
- Public or Private Hosted Zone Support
- Automatic DNS Record Cleanup
- Helm Atomic Upgrades
- Automatic Rollbacks
- ServiceMonitor Support
- Production Resource Limits
- Terraform Managed

---

# 📦 Resources Created

## AWS

- IAM Role
- IAM Policy
- IAM Policy Attachment
- EKS Pod Identity Association

## Kubernetes

- Namespace
- ServiceAccount
- Helm Release

---

# 📁 Module Structure

```text
modules/
└── external-dns/
    ├── main.tf
    ├── iam.tf
    ├── helm.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

---

# 📥 Inputs

| Name | Description |
|------|-------------|
| cluster_name | EKS cluster name |
| namespace | Kubernetes namespace |
| hosted_zone_id | Route53 Hosted Zone ID |
| domain_filters | Domains managed by ExternalDNS |
| service_account_name | Kubernetes ServiceAccount |
| chart_version | ExternalDNS Helm chart version |
| replica_count | Number of ExternalDNS replicas |
| policy | Sync policy |
| registry | TXT registry type |
| txt_owner_id | TXT ownership identifier |
| resources | CPU/Memory requests and limits |
| tags | AWS tags |

---

# 📤 Outputs

| Output | Description |
|---------|-------------|
| iam_role_arn | ExternalDNS IAM Role ARN |
| iam_policy_arn | Route53 Policy ARN |
| namespace | Kubernetes namespace |
| service_account_name | Kubernetes ServiceAccount |
| pod_identity_association_id | Pod Identity Association |
| helm_release_name | Helm Release |
| helm_release_status | Helm Release Status |

---

# 💻 Example Usage

```hcl
module "external_dns" {

  source = "../modules/external-dns"

  cluster_name = module.eks.cluster_name

  name = "${var.project_name}-${var.environment}-external-dns"

  namespace = "external-dns"

  hosted_zone_id = module.route53.hosted_zone_id

  domain_filters = [
    "cloudhusller.com"
  ]

  txt_owner_id = var.project_name

  tags = local.common_tags
}
```

---

# 🔒 Security Considerations

- Uses EKS Pod Identity (no long-lived AWS credentials)
- IAM policy follows least-privilege principles
- DNS changes are limited to the configured Route53 hosted zone
- TXT ownership records prevent conflicts with other DNS controllers
- All resources are managed by Terraform

---

# 💡 Design Decisions

## Why EKS Pod Identity?

AWS recommends EKS Pod Identity for new EKS clusters because it provides secure temporary AWS credentials without relying on OIDC-based IRSA.

---

## Why TXT Registry?

TXT records ensure ExternalDNS only modifies records that it owns, preventing accidental conflicts with manually managed DNS records or other controllers.

---

## Why Helm?

Using the official Helm chart ensures compatibility with future ExternalDNS releases while simplifying upgrades and lifecycle management.

---

## Why Least-Privilege IAM?

The module grants permission to modify only the specified Route53 hosted zone instead of every hosted zone in the AWS account.

---

# 📖 Operational Flow

```text
Developer deploys Service / Gateway
                │
                ▼
      ExternalDNS detects change
                │
                ▼
   Determines required DNS records
                │
                ▼
   Authenticates using Pod Identity
                │
                ▼
      Calls Route53 API
                │
                ▼
 DNS Record Created / Updated / Deleted
```

---

# 📖 Next Steps

After deploying this module, continue with:

1. Cert-Manager
2. External Secrets Operator
3. Karpenter
4. Observability Stack

These components complete the CloudHustler Commerce Platform's Kubernetes platform services layer.