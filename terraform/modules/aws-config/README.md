# 🚀 AWS Config Module

The **AWS Config Module** provisions AWS Config for the CloudHustler Commerce Platform.

This module records AWS resource configurations, tracks configuration changes over time, and delivers configuration snapshots to Amazon S3. It integrates with a reusable AWS Config Service Role module and supports optional Amazon SNS notifications.

---

## 🎯 Purpose

This module creates:

- AWS Config Configuration Recorder
- AWS Config Delivery Channel
- Configuration Recorder Status
- Amazon S3 snapshot delivery
- Optional Amazon SNS notifications
- Outputs for downstream Terraform modules

---

## 📁 Module Structure

```text
aws-config/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

## ✅ Features

- Records all supported AWS resource types
- Includes global IAM resources
- Stores configuration snapshots in Amazon S3
- Optional Amazon SNS notifications
- Uses a reusable IAM service role
- Fully reusable across environments
- Supports enterprise governance deployments

---

## 📥 Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| configuration_recorder_name | Recorder name | string | default |
| delivery_channel_name | Delivery channel name | string | default |
| s3_bucket_name | S3 bucket for configuration snapshots | string | Required |
| sns_topic_arn | SNS Topic ARN | string | null |
| iam_role_arn | AWS Config IAM Role ARN | string | Required |
| recording_group_all_supported | Record all supported resource types | bool | true |
| include_global_resource_types | Include IAM resources | bool | true |
| tags | Resource tags | map(string) | {} |

---

## 📤 Outputs

| Output | Description |
|---------|-------------|
| configuration_recorder_name | Recorder name |
| configuration_recorder_arn | Recorder ARN |
| delivery_channel_name | Delivery channel name |
| delivery_channel_id | Delivery channel ID |

---

## 🚀 Example Usage

```hcl
module "aws_config" {

  source = "../../modules/aws-config"

  configuration_recorder_name = "organization-config"

  delivery_channel_name = "organization-config"

  iam_role_arn = module.config_service_role.role_arn

  s3_bucket_name = module.config_bucket.bucket_name

  tags = local.tags

}
```

---

## 🔒 Best Practices

- Enable recording for all supported resource types.
- Include global IAM resources.
- Store configuration snapshots in a dedicated S3 bucket.
- Encrypt the S3 bucket using a customer-managed KMS key.
- Enable versioning on the S3 bucket.
- Use AWS Config Rules to evaluate compliance.
- Aggregate configuration data across AWS accounts using an AWS Config Aggregator.

---

## 📚 Module Dependencies

This module is commonly deployed with:

- Config Service Role Module
- S3 Module
- KMS Module
- SNS Module (optional)
- Config Aggregator Module