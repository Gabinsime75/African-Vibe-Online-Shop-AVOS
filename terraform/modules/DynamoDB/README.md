# Amazon DynamoDB Module

## Overview

This Terraform module provisions a secure, production-ready Amazon DynamoDB table following AWS best practices. It is intended for use cases such as Terraform state locking, application data storage, metadata management, session storage, and other NoSQL workloads.

The module supports on-demand billing, Point-in-Time Recovery (PITR), server-side encryption using customer-managed AWS KMS keys, deletion protection, table class selection, and resource tagging.

---

# Features

- Creates an Amazon DynamoDB table
- Supports PAY_PER_REQUEST billing mode
- Supports Terraform remote state locking
- Supports Point-in-Time Recovery (PITR)
- Supports server-side encryption (SSE)
- Supports customer-managed AWS KMS keys
- Supports deletion protection
- Supports STANDARD and STANDARD_INFREQUENT_ACCESS table classes
- Supports resource tagging
- Reusable across multiple environments

---

# Resources Created

This module provisions the following AWS resource:

- `aws_dynamodb_table`

---

# Module Structure

```text
dynamodb/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── providers.tf
└── README.md
```

---

# Input Variables

| Variable | Description | Type |
|----------|-------------|------|
| `table_name` | Name of the DynamoDB table | `string` |
| `billing_mode` | Billing mode for the table | `string` |
| `hash_key` | Partition key (hash key) for the table | `string` |
| `point_in_time_recovery_enabled` | Enable Point-in-Time Recovery | `bool` |
| `deletion_protection_enabled` | Enable deletion protection | `bool` |
| `server_side_encryption_enabled` | Enable server-side encryption | `bool` |
| `kms_key_arn` | ARN of the customer-managed KMS key | `string` |
| `table_class` | DynamoDB table class | `string` |
| `tags` | Resource tags | `map(string)` |

---

# Outputs

| Output | Description |
|---------|-------------|
| `table_name` | Name of the DynamoDB table |
| `table_arn` | ARN of the DynamoDB table |
| `table_id` | ID of the DynamoDB table |
| `hash_key` | Partition key configured for the table |

---

# Security Features

- Server-side encryption (SSE)
- Customer-managed AWS KMS key support
- Point-in-Time Recovery (PITR)
- Optional deletion protection
- Resource tagging
- Production-ready configuration
- Suitable for Terraform state locking

---

# Example Usage

```hcl
module "dynamodb" {

  source = "../modules/dynamodb"

  table_name   = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  point_in_time_recovery_enabled = true

  deletion_protection_enabled = true

  server_side_encryption_enabled = true

  kms_key_arn = module.kms.kms_key_arn

  table_class = "STANDARD"

  tags = {
    Name        = "terraform-locks"
    Environment = "Production"
    Project     = "CloudHustler"
    ManagedBy   = "Terraform"
  }

}
```

---

# Best Practices

- Use `PAY_PER_REQUEST` billing for variable or unpredictable workloads.
- Enable Point-in-Time Recovery (PITR) to protect against accidental writes and deletions.
- Encrypt tables using a customer-managed AWS KMS key whenever possible.
- Enable deletion protection for production workloads.
- Use consistent tagging across all AWS resources.
- Follow the principle of least privilege when granting IAM permissions.
- Use DynamoDB for Terraform state locking to prevent concurrent state modifications.

---

# Common Use Cases

- Terraform remote state locking
- Application metadata storage
- User session management
- Configuration management
- Event-driven applications
- Serverless application backends
- High-performance NoSQL workloads

---

# Notes

- This module follows AWS Well-Architected Framework recommendations.
- Supports both `STANDARD` and `STANDARD_INFREQUENT_ACCESS` table classes.
- Optimized for production, staging, and development environments.
- Designed as a reusable enterprise Terraform module.
- Can be integrated with customer-managed AWS KMS keys for centralized encryption management.
```