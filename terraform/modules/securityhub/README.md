# 🚀 Security Hub Module

The **Security Hub Module** provisions AWS Security Hub for the CloudHustler Commerce Platform.

This module centralizes security findings across AWS services, aggregates alerts from services such as Amazon GuardDuty and AWS Config, and enables the AWS Foundational Security Best Practices (FSBP) security standard.

---

## 🎯 Purpose

This module creates:

- AWS Security Hub Account
- AWS Foundational Security Best Practices Standard
- Centralized security findings
- Automatic security control management
- Outputs for downstream Terraform modules

---

## 📁 Module Structure

```text
securityhub/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

## ✅ Features

- Enables AWS Security Hub
- Enables AWS Foundational Security Best Practices
- Supports automatic security controls
- Configurable finding generation
- Aggregates findings from AWS services
- Reusable across environments
- Enterprise-ready deployment

---

## 📥 Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| enable_default_standards | Enable AWS default standards | bool | true |
| control_finding_generator | Finding generation mode | string | SECURITY_CONTROL |
| auto_enable_controls | Automatically enable new controls | bool | true |
| enable_fsbp_standard | Enable AWS Foundational Security Best Practices | bool | true |
| tags | Resource tags | map(string) | {} |

---

## 📤 Outputs

| Output | Description |
|---------|-------------|
| securityhub_account_id | Security Hub Account ID |
| securityhub_arn | Security Hub ARN |
| fsbp_enabled | Whether FSBP is enabled |

---

## 🚀 Example Usage

```hcl
module "securityhub" {

  source = "../../modules/securityhub"

  enable_default_standards = true

  control_finding_generator = "SECURITY_CONTROL"

  auto_enable_controls = true

  enable_fsbp_standard = true

  tags = local.tags

}
```

---

## 🔒 Best Practices

- Enable Security Hub in every AWS Region.
- Enable AWS Foundational Security Best Practices.
- Designate a delegated administrator for AWS Organizations.
- Aggregate findings from all AWS accounts.
- Integrate with Amazon GuardDuty.
- Integrate with AWS Config.
- Automate remediation using Amazon EventBridge and AWS Lambda.
- Regularly review and tune enabled security controls.

---

## 📚 Module Dependencies

This module is commonly deployed with:

- Security Hub Service Role Module
- GuardDuty Module
- AWS Config Module
- CloudTrail Module
- AWS Organizations
- EventBridge Module
- SNS Module