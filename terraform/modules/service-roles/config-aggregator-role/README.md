# 🚀 AWS Config Aggregator Service Role Module

The **AWS Config Aggregator Service Role Module** provisions the IAM role required by AWS Config Configuration Aggregators.

This module leverages the reusable IAM module to create a standardized service role that AWS Config can assume when aggregating configuration data across multiple AWS accounts and Regions.

---

## 🎯 Purpose

This module creates:

- AWS Config Aggregator IAM Service Role
- Trust relationship for AWS Config
- IAM policy required by Configuration Aggregators
- IAM policy attachment
- Outputs for downstream Terraform modules

---

## 📁 Module Structure

```text
config-aggregator-role/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

## 🔐 Permissions

The IAM policy grants read-only permissions required to aggregate configuration data across an AWS Organization, including:

- AWS Organizations
  - DescribeOrganization
  - ListAccounts
  - ListDelegatedAdministrators
  - ListAWSServiceAccessForOrganization

- AWS Config
  - DescribeConfigurationAggregators
  - DescribeConfigurationAggregatorSourcesStatus
  - BatchGetAggregateResourceConfig
  - SelectAggregateResourceConfig

All permissions follow the principle of least privilege.

---

## 📤 Outputs

The module exports:

- IAM Role Name
- IAM Role ARN
- IAM Role ID

These outputs can be consumed by downstream governance modules.

---

## 💡 Example

```hcl
module "config_aggregator_role" {

  source = "../../modules/service-roles/config-aggregator-role"

  role_name = "aws-config-aggregator-role"

  tags = {
    Environment = "management"
    Project     = "CloudHustler"
  }

}
```

---

## 🔗 Used By

This module is intended to be consumed by:

- Config Aggregator Module
- Governance Layer

---

## 🔒 Security Best Practices

- Uses a dedicated IAM role.
- Uses AWS service trust relationships.
- Follows the principle of least privilege.
- Reuses the centralized IAM module for consistency.
- Suitable for AWS Organizations deployments.