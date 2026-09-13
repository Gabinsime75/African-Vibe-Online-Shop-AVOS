# 🚀 CloudTrail Service Role Module

The **CloudTrail Service Role Module** provisions the IAM role required by AWS CloudTrail.

This module leverages the reusable IAM module to create a standardized service role that CloudTrail can assume for delivering logs and interacting with AWS services.


## 🎯 Purpose

This module creates:

- AWS CloudTrail IAM Service Role
- Trust relationship for AWS CloudTrail
- IAM policy required by CloudTrail
- IAM policy attachment
- Outputs for downstream Terraform modules


## 📦 Resources Created

- IAM Role
- IAM Policy
- IAM Role Policy Attachment


## 📥 Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| role_name | IAM role name | string | CloudHustler-CloudTrail-Service-Role |
| tags | Resource tags | map(string) | {} |


## 📤 Outputs

| Name | Description |
|------|-------------|
| role_name | IAM role name |
| role_arn | IAM role ARN |


## 💡 Example Usage

```hcl
module "cloudtrail_service_role" {

  source = "../modules/cloudtrail-service-role"

  role_name = "CloudHustler-CloudTrail-Service-Role"

  tags = {
    Environment = "Management"
    Terraform   = "true"
  }

}
```


## 🔒 Best Practices

- Use a dedicated IAM role for AWS CloudTrail.
- Follow the principle of least privilege.
- Apply consistent resource tagging.
- Reuse the generic IAM module for standardized IAM resources.
- Reference the exported role ARN when configuring CloudTrail.