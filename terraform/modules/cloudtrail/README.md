# 🚀 CloudTrail Module

The **CloudTrail Module** provisions an AWS CloudTrail trail for the CloudHustler Commerce Platform.

This module centralizes AWS API activity logging across one or more AWS Regions and supports integration with Amazon S3, AWS KMS, and Amazon CloudWatch Logs.

---

## 🎯 Purpose

This module creates:

- AWS CloudTrail Trail
- Multi-Region trail support
- Organization trail support
- Global service event logging
- Log file integrity validation
- Amazon S3 log delivery
- AWS KMS encryption
- Optional CloudWatch Logs integration
- Outputs for downstream Terraform modules

---

## 📁 Module Structure

```text
cloudtrail/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

## ✅ Features

- Multi-Region logging
- Organization-wide trails
- Global service event collection
- Log file validation
- Customer-managed KMS encryption
- Optional CloudWatch Logs delivery
- Reusable across environments
- Fully taggable

---

## 📥 Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| trail_name | CloudTrail name | string | Required |
| s3_bucket_name | S3 bucket for logs | string | Required |
| kms_key_id | KMS Key ID | string | null |
| is_multi_region_trail | Enable Multi-Region trail | bool | true |
| include_global_service_events | Include IAM and global events | bool | true |
| enable_log_file_validation | Enable integrity validation | bool | true |
| is_organization_trail | Organization trail | bool | false |
| enable_logging | Enable logging | bool | true |
| cloud_watch_logs_group_arn | CloudWatch Log Group ARN | string | null |
| cloud_watch_logs_role_arn | CloudWatch IAM Role ARN | string | null |
| tags | Resource tags | map(string) | {} |

---

## 📤 Outputs

| Output | Description |
|---------|-------------|
| trail_name | CloudTrail name |
| trail_arn | CloudTrail ARN |
| home_region | Home Region |
| id | CloudTrail ID |

---

## 🚀 Example Usage

```hcl
module "cloudtrail" {

  source = "../../modules/cloudtrail"

  trail_name     = "organization-cloudtrail"
  s3_bucket_name = module.cloudtrail_logs.bucket_name

  kms_key_id = module.kms.key_arn

  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true

  tags = local.tags

}
```

---

## 🔒 Best Practices

- Enable Multi-Region trails.
- Enable log file validation.
- Encrypt logs with a customer-managed KMS key.
- Store logs in a dedicated S3 bucket.
- Protect the S3 bucket with least-privilege policies.
- Use organization trails in AWS Organizations environments.
- Enable CloudWatch Logs when real-time monitoring is required.

---

## 📚 Module Dependencies

This module is commonly deployed with:

- KMS Module
- S3 Module
- CloudTrail Service Role Module (when using CloudWatch Logs)
- AWS Organizations