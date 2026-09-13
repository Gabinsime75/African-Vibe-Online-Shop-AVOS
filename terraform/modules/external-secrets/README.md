# External Secrets Operator Terraform Module

## Overview

Brief description of the module and its purpose.

---

## Architecture

```text
AWS Secrets Manager
        │
        ▼
IAM Policy
        │
        ▼
IAM Role
        │
        ▼
EKS Pod Identity
        │
        ▼
External Secrets Operator
        │
        ▼
ClusterSecretStore
        │
        ▼
ExternalSecret
        │
        ▼
Kubernetes Secret
```

---

## Features

- Deploys External Secrets Operator using Helm
- Configures Amazon EKS Pod Identity
- Creates least-privilege IAM role and policy
- Supports AWS Secrets Manager
- Optionally supports AWS Systems Manager Parameter Store
- Creates an optional ClusterSecretStore
- Supports Prometheus ServiceMonitor
- Supports configurable resource limits and scheduling
- Applies standardized AWS tags and Kubernetes labels

---

## Resources Created

### AWS

- IAM Role
- IAM Policy
- IAM Role Policy Attachment
- EKS Pod Identity Association

### Kubernetes

- Namespace
- Helm Release
- ClusterSecretStore

---

## Module Structure

```text
external-secrets/
├── main.tf
├── variables.tf
├── iam.tf
├── helm.tf
├── secret-store.tf
├── outputs.tf
└── README.md
```

---

## Usage

```hcl
module "external_secrets" {
  source = "../../modules/external-secrets"

  platform_name = var.project_name
  name          = "${local.name_prefix}-external-secrets"

  cluster_name = var.cluster_name
  aws_region   = var.aws_region

  namespace            = "external-secrets"
  service_account_name = "external-secrets"

  enable_secrets_manager = true

  secrets_manager_secret_arns = [
    "arn:aws:secretsmanager:us-east-2:ACCOUNT_ID:secret:cloudhustler/dev/*"
  ]

  create_cluster_secret_store = true

  tags = local.common_tags
}
```

---

## Inputs

| Name | Description |
|------|-------------|
| platform_name | Platform name |
| cluster_name | EKS cluster name |
| namespace | Kubernetes namespace |
| aws_region | AWS Region |
| ... | ... |

---

## Outputs

| Name | Description |
|------|-------------|
| iam_role_arn | IAM role ARN |
| helm_release_status | Helm release status |
| cluster_secret_store_name | ClusterSecretStore name |

---

## Deployment

```bash
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

---

## Verification

```bash
kubectl get pods -n external-secrets

helm list -n external-secrets

kubectl get clustersecretstore
```

Expected:

- Helm release is **deployed**
- Pods are **Running**
- ClusterSecretStore is **Ready**

---

## Troubleshooting

| Issue | Resolution |
|--------|------------|
| ClusterSecretStore not ready | Verify Pod Identity and IAM permissions |
| AccessDeniedException | Verify IAM policy and KMS permissions |
| CRD not found | Re-run Terraform after Helm installs CRDs |

---

## CloudHustler Platform Integration

```text
AWS Secrets Manager
        │
        ▼
External Secrets Operator
        │
        ▼
Kubernetes Secrets
        │
        ▼
Microservices
```