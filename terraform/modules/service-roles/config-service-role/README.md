# 🚀 Config Service Role Module

The **Config Service Role Module** provisions the IAM role required by AWS Config.

Rather than manually creating service roles throughout the infrastructure, this module standardizes the deployment of the AWS Config service role using the reusable IAM module.


## 🎯 Purpose

This module creates:

- AWS Config IAM Service Role
- Trust relationship for AWS Config
- IAM policy required by AWS Config
- IAM policy attachment
- Outputs for downstream Terraform modules


## 📦 Resources Created

- IAM Role
- IAM Policy
- IAM Role Policy Attachment


## 📥 Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| role_name | IAM role name | string | CloudHustler-Config-Service-Role |
| tags | Resource tags | map(string) | {} |


## 📤 Outputs

| Name | Description |
|------|-------------|
| role_name | IAM role name |
| role_arn | IAM role ARN |


## 💡 Example Usage

```hcl
module "config_service_role" {

  source = "../modules/config-service-role"

  role_name = "CloudHustler-Config-Service-Role"

  tags = {
    Environment = "Management"
    Terraform   = "true"
  }

}
```


## 🔒 Best Practices

- Use a dedicated service role for AWS Config.
- Follow the principle of least privilege.
- Apply consistent resource tagging.
- Reuse the generic IAM module for standardized IAM resources.
- Reference the exported role ARN when configuring AWS Config resources.