# 🚀 CloudWatch Log Group Module

The **CloudWatch Log Group Module** provisions reusable Amazon CloudWatch Log Groups for the CloudHustler Commerce Platform.

This module provides centralized log storage with configurable retention, optional KMS encryption, log group classes, and tagging. It is designed to be consumed by services across the platform.

---

## 🎯 Purpose

This module creates:

- Amazon CloudWatch Log Group
- Optional KMS encryption
- Configurable retention period
- Configurable Log Group Class
- Optional deletion protection
- Outputs for downstream Terraform modules

---

## 📁 Module Structure

```text
cloudwatch-log-group/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

## ✨ Features

- Configurable log group name
- Configurable retention period
- Customer-managed KMS key support
- STANDARD and INFREQUENT_ACCESS classes
- Optional skip_destroy protection
- Resource tagging

---

## 📤 Outputs

The module exports:

- Log Group Name
- Log Group ARN
- Log Group ID

---

## 💡 Example

```hcl
module "cloudtrail_logs" {

  source = "../modules/cloudwatch-log-group"

  name = "/aws/cloudtrail/cloudhustler"

  retention_in_days = 365

  kms_key_id = module.kms.key_arn

  tags = {
    Project = "CloudHustler"
  }

}
```

---

## 🔗 Used By

This module is intended to be reused by:

- CloudTrail
- AWS Config
- VPC Flow Logs
- EKS Control Plane
- Lambda
- API Gateway
- Route 53 Resolver
- GuardDuty
- Security Hub
- Application Logs

---

## 🔒 Security Best Practices

- Supports customer-managed KMS encryption
- Configurable retention policies
- Consistent tagging
- Reusable across all platform services
- Supports Infrastructure as Code best practices