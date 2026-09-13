# 🚀 AWS Config Aggregator Module

The **AWS Config Aggregator Module** provisions an AWS Config Configuration Aggregator for the CloudHustler Commerce Platform.

This module aggregates AWS Config data from multiple AWS accounts and Regions into a single location, providing centralized visibility into resource configurations and compliance across the organization.

---

## 🎯 Purpose

This module creates:

- AWS Config Configuration Aggregator
- AWS Organizations aggregation
- Cross-account aggregation
- Multi-Region aggregation
- Outputs for downstream Terraform modules

---

## 📁 Module Structure

```text
config-aggregator/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

## ✅ Features

- Supports AWS Organizations aggregation
- Supports cross-account aggregation
- Supports multi-Region aggregation
- Enterprise governance ready
- Reusable across environments
- Centralized compliance reporting

---

## 📥 Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| aggregator_name | Aggregator name | string | Required |
| organization_aggregation | Use AWS Organizations | bool | true |
| account_ids | AWS accounts to aggregate | list(string) | [] |
| aws_regions | AWS Regions to aggregate | list(string) | [] |
| tags | Resource tags | map(string) | {} |

---

## 📤 Outputs

| Output | Description |
|---------|-------------|
| aggregator_name | Aggregator name |
| aggregator_arn | Aggregator ARN |
| aggregator_id | Aggregator ID |

---

## 🚀 Example Usage

### Organization Aggregator

```hcl
module "config_aggregator" {

  source = "../../modules/config-aggregator"

  aggregator_name = "organization-config"

  organization_aggregation = true

  tags = local.tags

}
```

### Cross-Account Aggregator

```hcl
module "config_aggregator" {

  source = "../../modules/config-aggregator"

  aggregator_name = "shared-services-config"

  organization_aggregation = false

  account_ids = [
    "111111111111",
    "222222222222",
    "333333333333"
  ]

  aws_regions = [
    "us-east-1",
    "us-east-2"
  ]

  tags = local.tags

}
```

---

## 🔒 Best Practices

- Deploy the aggregator in the Security or Audit account.
- Use AWS Organizations aggregation whenever possible.
- Aggregate all AWS Regions.
- Ensure AWS Config is enabled in every account.
- Use delegated administrator permissions for AWS Organizations.
- Integrate aggregated compliance data with AWS Security Hub.
- Use the aggregator for organization-wide compliance reporting.

---

## 📚 Module Dependencies

This module is commonly deployed with:

- AWS Config Module
- AWS Organizations
- IAM Module
- Security Hub Module
- GuardDuty Module