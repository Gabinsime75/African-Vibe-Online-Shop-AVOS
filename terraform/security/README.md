# Security Root Module

## 🚀 Overview

This root module deploys the security layer for the CloudHustler Commerce Platform.

The first security control implemented in this root is AWS WAF attached to the public Application Load Balancer created by the networking root module.

## 🎯 Purpose

The purpose of this root module is to protect public application traffic before it reaches backend workloads.

At this stage, the security root connects directly to the networking layer by consuming the ALB ARN and associating an AWS WAF Web ACL with that ALB.

## 🏗 Architecture

```text
Route 53
   ↓
ACM Certificate
   ↓
Application Load Balancer
   ↓
AWS WAF Web ACL
   ↓
Future EKS / ECS / Application Workloads
```

## 🚀 Features

- Calls the reusable `modules/waf` module
- Creates a regional AWS WAF Web ACL
- Associates WAF with the public ALB
- Enables AWS managed WAF rule groups
- Enables WAF CloudWatch metrics
- Enables sampled requests
- Enables WAF logging to CloudWatch Logs
- Supports configurable log retention
- Applies consistent project tags

## 📦 Resources Created

Resources are created through the reusable WAF module:

- `aws_wafv2_web_acl`
- `aws_wafv2_web_acl_association`
- `aws_cloudwatch_log_group`
- `aws_wafv2_web_acl_logging_configuration`

## 📁 Root Module Structure

```text
security/
├── main.tf
├── providers.tf
├── versions.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── terraform.tfvars.example
└── README.md
```

## 📥 Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `project_name` | Name of the project | `string` | n/a |
| `environment` | Deployment environment | `string` | n/a |
| `aws_region` | AWS region where security resources are deployed | `string` | n/a |
| `alb_arn` | ARN of the public ALB from the networking root module | `string` | n/a |
| `waf_log_retention_in_days` | Number of days to retain WAF logs | `number` | `90` |
| `tags` | Additional tags applied to resources | `map(string)` | `{}` |

## 📤 Outputs

| Name | Description |
|---|---|
| `waf_web_acl_id` | ID of the WAF Web ACL |
| `waf_web_acl_arn` | ARN of the WAF Web ACL |
| `waf_web_acl_name` | Name of the WAF Web ACL |
| `waf_web_acl_capacity` | WCU capacity used by the WAF Web ACL |
| `waf_log_group_name` | Name of the WAF CloudWatch Log Group |
| `waf_log_group_arn` | ARN of the WAF CloudWatch Log Group |

## 💻 Example Usage

```hcl
module "waf" {
  source = "../modules/waf"

  name        = "${local.name_prefix}-alb-waf"
  description = "WAF Web ACL for CloudHustler public Application Load Balancer."
  scope       = "REGIONAL"

  associate_resource_arn = var.alb_arn

  metric_name_prefix = "${local.name_prefix}-alb-waf"
  log_group_name     = "aws-waf-logs-${local.name_prefix}-alb"

  log_retention_in_days = var.waf_log_retention_in_days

  tags = local.common_tags
}
```

## 🔒 Security Considerations

This root module places WAF in front of the public ALB.

That means traffic is inspected before it reaches future workloads such as EKS services, ECS services, or application target groups.

The WAF module enables AWS managed rule groups for common attacks, known bad inputs, malicious IP reputation, and SQL injection protection.

WAF logs should be retained according to compliance and troubleshooting requirements.

## 💡 Design Decisions

This root module consumes the ALB ARN as an input instead of directly referencing the networking root state.

That keeps the security root loosely coupled and easier to test.

Later, this can be improved by using `terraform_remote_state` to read outputs from the networking backend once all root modules are migrated to the S3 backend.

## 📖 Next Steps

- Run `terraform init`
- Run `terraform fmt`
- Run `terraform validate`
- Run `terraform plan`
- Run `terraform apply`
- Add rate-based WAF rules
- Add custom allow/block IP sets if needed
- Add CloudWatch alarms for blocked request spikes