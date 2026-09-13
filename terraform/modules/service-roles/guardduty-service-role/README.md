# 🚀 GuardDuty Service Role Module

The **GuardDuty Service Role Module** provisions the IAM role required by AWS GuardDuty.

This module uses the reusable IAM module to create a standardized IAM service role that AWS GuardDuty can assume when performing threat detection and security monitoring.

---

## 🎯 Purpose

This module creates:

- AWS GuardDuty IAM Service Role
- Trust relationship for AWS GuardDuty
- IAM policy required by GuardDuty
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
| role_name | IAM role name | string | CloudHustler-GuardDuty-Service-Role |
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
module "guardduty_service_role" {

  source = "../modules/guardduty-service-role"

  role_name = "CloudHustler-GuardDuty-Service-Role"

  tags = {
    Environment = "Management"
    Terraform   = "true"
  }

}
```

---

## 🔒 Best Practices

- Use a dedicated IAM role for AWS GuardDuty.
- Follow the principle of least privilege.
- Apply consistent resource tagging.
- Reuse the generic IAM module for standardized IAM resources.
- Reference the exported role ARN when configuring GuardDuty.