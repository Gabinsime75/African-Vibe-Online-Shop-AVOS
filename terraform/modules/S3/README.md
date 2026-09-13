# 🚀 Amazon S3 Module

The **Amazon S3 Module** provisions and manages production-ready Amazon S3 buckets for the CloudHustler Commerce Platform.

The module provides a standardized, secure, and highly configurable way to deploy S3 buckets while following AWS Well-Architected Framework recommendations and security best practices.

It supports everything from simple encrypted buckets to enterprise-grade storage solutions with lifecycle management, replication, inventory reporting, object locking, intelligent tiering, event notifications, static website hosting, and more.

---

## 🎯 Purpose

This module provisions and manages:

- Amazon S3 Bucket
- Bucket Ownership Controls
- Public Access Block
- Server-Side Encryption (SSE-S3 or SSE-KMS)
- Bucket Versioning
- Lifecycle Configuration
- Server Access Logging
- Static Website Hosting
- Cross-Origin Resource Sharing (CORS)
- Bucket Notifications
- Cross-Region Replication
- Intelligent Tiering
- Inventory Reports
- Storage Analytics
- CloudWatch Request Metrics
- Requester Pays
- Object Lock
- Transfer Acceleration
- Bucket Policies
- Bucket ACLs (optional)
- Standardized outputs for downstream modules

---

## 📂 Module Structure

```text
modules/
└── s3/
    ├── main.tf
    ├── bucket.tf
    ├── ownership_controls.tf
    ├── public_access_block.tf
    ├── encryption.tf
    ├── versioning.tf
    ├── lifecycle_configuration.tf
    ├── logging.tf
    ├── website.tf
    ├── cors.tf
    ├── notification.tf
    ├── replication.tf
    ├── intelligent_tiering.tf
    ├── inventory.tf
    ├── analytics.tf
    ├── metrics.tf
    ├── request_payment.tf
    ├── object_lock.tf
    ├── acceleration.tf
    ├── policy.tf
    ├── acl.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

---

## 🏗 Resources Created

Depending on the configuration provided, this module may create:

- aws_s3_bucket
- aws_s3_bucket_ownership_controls
- aws_s3_bucket_public_access_block
- aws_s3_bucket_server_side_encryption_configuration
- aws_s3_bucket_versioning
- aws_s3_bucket_lifecycle_configuration
- aws_s3_bucket_logging
- aws_s3_bucket_website_configuration
- aws_s3_bucket_cors_configuration
- aws_s3_bucket_notification
- aws_s3_bucket_replication_configuration
- aws_s3_bucket_intelligent_tiering_configuration
- aws_s3_bucket_inventory
- aws_s3_bucket_analytics_configuration
- aws_s3_bucket_metric
- aws_s3_bucket_request_payment_configuration
- aws_s3_bucket_object_lock_configuration
- aws_s3_bucket_accelerate_configuration
- aws_s3_bucket_policy
- aws_s3_bucket_acl

---

## 📥 Inputs

### Required

| Name | Description | Type |
|------|-------------|------|
| bucket_name | Name of the S3 bucket | string |

---

### General

| Name | Type | Default |
|------|------|---------|
| force_destroy | bool | false |
| tags | map(string) | {} |

---

### Ownership

| Name | Type | Default |
|------|------|---------|
| object_ownership | string | BucketOwnerEnforced |

---

### Public Access Block

| Name | Type | Default |
|------|------|---------|
| enable_public_access_block | bool | true |
| block_public_acls | bool | true |
| ignore_public_acls | bool | true |
| block_public_policy | bool | true |
| restrict_public_buckets | bool | true |

---

### Encryption

| Name | Type | Default |
|------|------|---------|
| enable_encryption | bool | true |
| sse_algorithm | string | AES256 |
| kms_key_arn | string | null |
| bucket_key_enabled | bool | true |

---

### Versioning

| Name | Type | Default |
|------|------|---------|
| versioning_status | string | Enabled |

---

### Lifecycle

| Name | Type |
|------|------|
| lifecycle_rules | list(object(...)) |

---

### Logging

| Name | Type |
|------|------|
| logging_configuration | object(...) |

---

### Website

| Name | Type | Default |
|------|------|---------|
| enable_website | bool | false |
| index_document | string | index.html |
| error_document | string | error.html |

---

### CORS

| Name | Type |
|------|------|
| cors_rules | list(object(...)) |

---

### Notifications

| Name | Type |
|------|------|
| lambda_notifications | list(object(...)) |
| sns_notifications | list(object(...)) |
| sqs_notifications | list(object(...)) |

---

### Replication

| Name | Type |
|------|------|
| replication_configuration | object(...) |

---

### Intelligent Tiering

| Name | Type |
|------|------|
| intelligent_tiering | object(...) |

---

### Inventory

| Name | Type |
|------|------|
| inventory_configuration | object(...) |

---

### Analytics

| Name | Type |
|------|------|
| analytics_configuration | object(...) |

---

### Metrics

| Name | Type |
|------|------|
| metrics_configuration | object(...) |

---

### Object Lock

| Name | Type | Default |
|------|------|---------|
| enable_object_lock | bool | false |
| object_lock_mode | string | GOVERNANCE |
| object_lock_days | number | 30 |

---

### Miscellaneous

| Name | Type | Default |
|------|------|---------|
| enable_transfer_acceleration | bool | false |
| request_payer | string | BucketOwner |
| enable_acl | bool | false |
| acl | string | private |
| attach_bucket_policy | bool | false |
| bucket_policy | string | null |

---

## 📤 Outputs

The module exports:

| Output | Description |
|---------|-------------|
| bucket_id | Bucket ID |
| bucket_name | Bucket name |
| bucket_arn | Bucket ARN |
| bucket_domain_name | Bucket DNS name |
| bucket_regional_domain_name | Regional DNS name |
| hosted_zone_id | Route 53 Hosted Zone ID |
| website_endpoint | Website endpoint (if enabled) |
| kms_key_arn | KMS Key ARN |
| versioning_status | Bucket versioning status |

---

## 💡 Example Usage

### Simple Bucket

```hcl
module "artifacts_bucket" {

  source = "../modules/s3"

  bucket_name = "cloudhustler-artifacts"

  tags = {
    Environment = "dev"
    Terraform  = "true"
  }

}
```

---

### Encrypted KMS Bucket

```hcl
module "logs_bucket" {

  source = "../modules/s3"

  bucket_name = "cloudhustler-logs"

  sse_algorithm = "aws:kms"

  kms_key_arn = module.kms.key_arn

}
```

---

### Versioned Bucket with Lifecycle Rules

```hcl
module "backups_bucket" {

  source = "../modules/s3"

  bucket_name = "cloudhustler-backups"

  versioning_status = "Enabled"

  lifecycle_rules = [

    {

      id = "archive"

      status = "Enabled"

      transitions = [

        {

          days = 30

          storage_class = "STANDARD_IA"

        }

      ]

    }

  ]

}
```

---

### Static Website Bucket

```hcl
module "website_bucket" {

  source = "../modules/s3"

  bucket_name = "cloudhustler-website"

  enable_website = true

  index_document = "index.html"

  error_document = "404.html"

}
```

---

## 🔒 Security Features

This module follows AWS security best practices by supporting:

- Bucket Owner Enforced object ownership
- Public Access Block
- Default encryption
- KMS encryption
- Versioning
- Object Lock
- Least-privilege bucket policies
- Cross-Region replication
- Lifecycle policies
- Secure logging
- CloudWatch metrics

---

## 🏛 AWS Services Used

- Amazon S3
- AWS KMS
- AWS IAM
- Amazon CloudWatch
- AWS Lambda
- Amazon SNS
- Amazon SQS

---

## 🚀 Best Practices

Recommended for production:

- Enable Versioning
- Enable SSE-KMS encryption
- Enable Public Access Block
- Use Bucket Owner Enforced ownership
- Configure Lifecycle Rules
- Enable Access Logging
- Use least-privilege IAM policies
- Enable CloudWatch Metrics
- Use Replication for disaster recovery
- Enable Inventory reporting for compliance

---

## 🔄 Module Dependencies

This module can integrate with:

- KMS Module
- IAM Module
- CloudTrail Module
- AWS Config Module
- GuardDuty Module
- Security Hub Module
- Route 53 Module
- CloudFront Module
- Lambda Module

---

## 📖 Terraform Compatibility

| Component | Version |
|-----------|---------|
| Terraform | >= 1.5 |
| AWS Provider | >= 5.x |

---

## 📜 License

This module is part of the **CloudHustler Commerce Platform** and follows the project's infrastructure standards for reusable, production-grade Terraform modules.