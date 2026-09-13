# 🚀 IAM Access Analyzer Module

The **IAM Access Analyzer Module** provisions IAM Access Analyzer for the CloudHustler Commerce Platform.

This module continuously analyzes AWS resource policies to identify resources that are shared with external accounts or organizations, helping enforce least-privilege access and improve security posture.

---

## 🎯 Purpose

This module creates:

- IAM Access Analyzer
- Account or Organization Analyzer
- External access analysis
- Outputs for downstream Terraform modules

---

## 📁 Module Structure

```text
access-analyzer/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

## ✅ Features

- Creates an IAM Access Analyzer
- Supports Account analyzers
- Supports Organization analyzers
- Detects unintended external resource sharing
- Helps enforce least privilege
- Reusable across environments
- Enterprise-ready deployment

---

## 📥 Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| analyzer_name | Analyzer name | string | Required |
| type | ACCOUNT or ORGANIZATION | string | ACCOUNT |
| tags | Resource tags | map(string) | {} |

---

## 📤 Outputs

| Output | Description |
|---------|-------------|
| analyzer_name | Analyzer name |
| analyzer_arn | Analyzer ARN |
| analyzer_id | Analyzer ID |
| type | Analyzer type |

---

## 🚀 Example Usage

```hcl
module "access_analyzer" {

  source = "../../modules/access-analyzer"

  analyzer_name = "organization-access-analyzer"

  type = "ACCOUNT"

  tags = local.tags

}
```

---

## 🔒 Best Practices

- Create one analyzer in every AWS Region.
- Use ORGANIZATION analyzers when using AWS Organizations.
- Review findings regularly.
- Investigate publicly accessible resources.
- Integrate findings with AWS Security Hub.
- Follow the principle of least privilege.
- Continuously monitor cross-account resource sharing.

---

## 📚 Module Dependencies

This module is commonly deployed with:

- IAM Module
- AWS Organizations
- Security Hub Module
- GuardDuty Module
- AWS Config Module