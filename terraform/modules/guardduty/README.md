# 🚀 GuardDuty Module

The **GuardDuty Module** provisions Amazon GuardDuty for the CloudHustler Commerce Platform.

This module enables intelligent threat detection using machine learning, anomaly detection, AWS CloudTrail events, VPC Flow Logs, DNS logs, Amazon S3 protection, Kubernetes audit logs, and malware protection for Amazon EC2.

---

## 🎯 Purpose

This module creates:

- Amazon GuardDuty Detector
- S3 Protection
- Kubernetes Audit Log Monitoring
- EC2 Malware Protection
- Configurable finding publishing frequency
- Outputs for downstream Terraform modules

---

## 📁 Module Structure

```text
guardduty/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

## ✅ Features

- Enables Amazon GuardDuty
- Detects malicious activity across AWS accounts
- Monitors CloudTrail, DNS, and VPC Flow Logs
- Supports Amazon S3 Protection
- Supports Kubernetes Audit Logs
- Supports EC2 Malware Protection
- Configurable finding publishing frequency
- Fully reusable across environments
- Enterprise-ready deployment

---

## 📥 Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| enable | Enable GuardDuty | bool | true |
| finding_publishing_frequency | Finding publishing frequency | string | FIFTEEN_MINUTES |
| datasources | GuardDuty data sources | object | See variables.tf |
| tags | Resource tags | map(string) | {} |

---

## 📤 Outputs

| Output | Description |
|---------|-------------|
| detector_id | GuardDuty Detector ID |
| detector_arn | GuardDuty Detector ARN |
| status | Detector enabled status |

---

## 🚀 Example Usage

```hcl
module "guardduty" {

  source = "../../modules/guardduty"

  enable = true

  finding_publishing_frequency = "FIFTEEN_MINUTES"

  datasources = {

    s3_logs = true

    kubernetes = {
      audit_logs = true
    }

    malware_protection = {
      scan_ec2_instance_with_findings = true
    }

  }

  tags = local.tags

}
```

---

## 🔒 Best Practices

- Enable GuardDuty in every AWS Region.
- Enable S3 Protection.
- Enable Kubernetes Audit Log monitoring for Amazon EKS.
- Enable EC2 Malware Protection.
- Aggregate GuardDuty findings using a delegated administrator account.
- Integrate GuardDuty with AWS Security Hub.
- Automate response using Amazon EventBridge and AWS Lambda.

---

## 📚 Module Dependencies

This module is commonly deployed with:

- GuardDuty Service Role Module
- AWS Organizations
- Security Hub Module
- CloudTrail Module
- EventBridge Module
- SNS Module