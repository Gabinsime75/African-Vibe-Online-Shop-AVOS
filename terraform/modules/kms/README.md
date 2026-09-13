# AWS KMS Terraform Module

## Overview

This module provisions a reusable **AWS Key Management Service (KMS)** Customer Managed Key (CMK) for encrypting AWS resources across an enterprise AWS environment.

The module creates a **symmetric encryption key**, configures automatic key rotation, provisions a friendly alias, and applies a least-privilege key policy. It is designed to serve as the centralized encryption component for the **AWS Enterprise Foundation** project.

---

# Features

- Customer Managed Symmetric KMS Key
- Automatic Key Rotation
- Configurable Deletion Window
- Multi-Region Key Support
- KMS Alias Creation
- Enterprise Tagging Support
- Dynamic IAM Policy Generation
- Reusable Across Multiple AWS Services

---

# Resources Created

This module provisions the following AWS resources:

- AWS KMS Key
- AWS KMS Alias
- AWS KMS Key Policy

---

# Module Structure

```text
kms/
├── providers.tf
├── variables.tf
├── main.tf
├── policy.tf
├── outputs.tf
└── README.md
```

---

# Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `description` | Description of the KMS key | `string` | Required |
| `alias` | Alias assigned to the KMS key | `string` | Required |
| `enable_key_rotation` | Enable automatic annual key rotation | `bool` | `true` |
| `multi_region` | Create a Multi-Region KMS key | `bool` | `false` |
| `deletion_window_in_days` | Waiting period before permanent key deletion | `number` | `30` |
| `is_enabled` | Enable or disable the KMS key | `bool` | `true` |
| `customer_master_key_spec` | KMS key specification | `string` | `SYMMETRIC_DEFAULT` |
| `tags` | Tags applied to the KMS resources | `map(string)` | `{}` |

---

# Outputs

| Name | Description |
|------|-------------|
| `key_id` | Unique identifier of the KMS key |
| `key_arn` | ARN of the KMS key |
| `key_alias` | Alias assigned to the KMS key |
| `is_enabled` | Indicates whether the KMS key is enabled |

---

# Example Usage

```hcl
module "kms" {

  source = "../modules/kms"

  description             = "Terraform State Encryption Key"
  alias                   = "terraform-state"
  enable_key_rotation     = true
  multi_region            = false
  deletion_window_in_days = 30

  tags = {
    Project     = "AWS Enterprise Foundation"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }

}
```

---

# Security Best Practices

This module follows AWS security best practices by:

- Using a Customer Managed Key (CMK)
- Enabling automatic annual key rotation
- Applying a least-privilege key policy
- Supporting Multi-Region keys for disaster recovery
- Using Terraform IAM policy documents instead of embedded JSON
- Providing a configurable recovery window before key deletion
- Supporting centralized tagging for governance and compliance

---

# Common Use Cases

This module can be used to encrypt resources such as:

- Amazon S3 Buckets
- Amazon EBS Volumes
- Amazon RDS Databases
- Amazon DynamoDB Tables
- Amazon EKS Secrets
- AWS Secrets Manager
- AWS Systems Manager Parameter Store
- Amazon CloudWatch Logs
- Amazon SNS Topics
- Amazon SQS Queues
- AWS Lambda Environment Variables
- AWS Backup Vaults
- Amazon OpenSearch Service

---

# Validation

Validate the module before deploying:

```bash
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

---

# Future Enhancements

Planned improvements include:

- Cross-account KMS administration
- Service-specific KMS policies
- AWS Organizations integration
- CloudTrail encryption support
- AWS Backup integration
- Amazon EKS secrets encryption policies
- Terraform execution role permissions

---

# Author

**CloudHustler Labs**

Building production-grade AWS, Terraform, Kubernetes, and Platform Engineering solutions.