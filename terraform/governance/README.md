# 🚀 Governance Layer

The **Governance Layer** deploys the core AWS governance services for the CloudHustler Commerce Platform.

It consumes reusable Terraform modules to establish centralized auditing, compliance monitoring, threat detection, security posture management, and IAM access analysis.

---

## 🎯 Purpose

This deployment provisions:

- AWS CloudTrail
- AWS Config
- AWS Config Aggregator
- Amazon GuardDuty
- AWS Security Hub
- IAM Access Analyzer
- Required IAM Service Roles

---

## 📁 Directory Structure

```text
governance/
├── main.tf
├── providers.tf
├── versions.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
└── README.md
```

---

## 🚀 Modules Deployed

```text
Identity
├── CloudTrail Service Role
├── Config Service Role
├── GuardDuty Service Role
└── SecurityHub Service Role

Governance
├── CloudTrail
├── AWS Config
├── Config Aggregator
├── GuardDuty
├── Security Hub
└── IAM Access Analyzer
```

---

## 🔒 Governance Capabilities

- Organization-wide API auditing
- Configuration recording
- Compliance monitoring
- Threat detection
- Security findings aggregation
- IAM external access analysis
- Multi-account governance
- Enterprise-ready architecture

---

## 🚀 Deployment

```bash
terraform init
terraform plan
terraform apply
```

---

## 📦 Dependencies

This deployment relies on:

- Bootstrap Layer
- Organization Layer
- Identity Layer
- KMS Module
- S3 Module