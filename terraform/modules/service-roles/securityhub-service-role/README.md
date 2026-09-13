# 🚀 Security Hub Service Role Module

The **Security Hub Service Role Module** provisions the IAM role required by AWS Security Hub.

This module leverages the reusable IAM module to create a standardized IAM service role that AWS Security Hub can assume for security posture management, findings aggregation, and compliance monitoring.

---

## 🎯 Purpose

This module creates:

- AWS Security Hub IAM Service Role
- Trust relationship for AWS Security Hub
- IAM policy required by Security Hub
- IAM policy attachment
- Outputs for downstream Terraform modules

---

## 📦 Resources Created

- IAM Role
- IAM Policy
- IAM Role Policy Attachment

---

## 📥 Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| role_name | IAM role name | string | CloudHustler-SecurityHub-Service-Role |
| tags | Resource tags | map(string) | {} |

---

## 📤 Outputs

| Name | Description |
|------|-------------|
| role_name | IAM role name |
| role_arn | IAM role ARN |

---

## 💡 Example Usage

```hcl
module "securityhub_service_role" {

  source = "../modules/securityhub-service-role"

  role_name = "CloudHustler-SecurityHub-Service-Role"

  tags = {
    Environment = "Management"
    Terraform   = "true"
  }

}
```

---

## 🔒 Best Practices

- Use a dedicated IAM role for AWS Security Hub.
- Follow the principle of least privilege.
- Apply consistent resource tagging.
- Reuse the generic IAM module for standardized IAM resources.
- Reference the exported role ARN when configuring AWS Security Hub.