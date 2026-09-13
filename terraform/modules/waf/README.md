# WAF Module

## 🚀 Overview

This module creates an AWS WAFv2 Web ACL for the CloudHustler Commerce Platform.

It is designed to protect internet-facing entry points such as Application Load Balancers, API Gateway, AppSync, and eventually CloudFront.

## 🎯 Purpose

The purpose of this module is to provide a reusable security layer in front of application traffic.

For the current platform phase, this module attaches to the public Application Load Balancer created in the networking root module.

## 🏗 Architecture

\`\`\`text
Route 53
   ↓
ACM Certificate
   ↓
Application Load Balancer
   ↓
AWS WAF Web ACL
   ↓
Future EKS / ECS / Application Workloads
\`\`\`

## 🚀 Features

- Creates AWS WAFv2 Web ACL
- Supports REGIONAL scope for ALB, API Gateway, and AppSync
- Supports optional resource association
- Enables AWS managed rule groups
- Enables CloudWatch metrics
- Enables sampled requests
- Supports WAF logging to CloudWatch Logs
- Supports log retention
- Supports optional KMS encryption for logs
- Supports tagging

## 📦 Resources Created

- `aws_wafv2_web_acl`
- `aws_wafv2_web_acl_association`
- `aws_cloudwatch_log_group`
- `aws_wafv2_web_acl_logging_configuration`

## 📁 Module Structure

\`\`\`text
modules/waf/
├── web_acl.tf
├── logging.tf
├── variables.tf
├── outputs.tf
└── README.md
\`\`\`

## 📥 Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `name` | Name of the WAF Web ACL | `string` | n/a |
| `description` | Description of the WAF Web ACL | `string` | `"Managed WAF Web ACL."` |
| `scope` | WAF scope, usually `REGIONAL` for ALB | `string` | `"REGIONAL"` |
| `associate_resource_arn` | ARN of the resource to associate with the Web ACL | `string` | `null` |
| `cloudwatch_metrics_enabled` | Enable CloudWatch metrics | `bool` | `true` |
| `sampled_requests_enabled` | Enable sampled requests | `bool` | `true` |
| `metric_name_prefix` | Metric name prefix | `string` | n/a |
| `enable_logging` | Enable WAF logging | `bool` | `true` |
| `log_group_name` | CloudWatch Log Group name | `string` | n/a |
| `log_retention_in_days` | WAF log retention in days | `number` | `90` |
| `log_kms_key_id` | Optional KMS key ARN for log encryption | `string` | `null` |
| `tags` | Tags applied to resources | `map(string)` | `{}` |

## 📤 Outputs

| Name | Description |
|---|---|
| `web_acl_id` | ID of the WAF Web ACL |
| `web_acl_arn` | ARN of the WAF Web ACL |
| `web_acl_name` | Name of the WAF Web ACL |
| `web_acl_capacity` | WCU capacity used by the Web ACL |
| `log_group_name` | Name of the WAF CloudWatch Log Group |
| `log_group_arn` | ARN of the WAF CloudWatch Log Group |

## 💻 Example Usage

\`\`\`hcl
module "waf" {
  source = "../modules/waf"

  name                   = "${local.name_prefix}-alb-waf"
  description            = "WAF Web ACL for CloudHustler public ALB."
  scope                  = "REGIONAL"
  associate_resource_arn = module.alb.load_balancer_arn

  metric_name_prefix = "${local.name_prefix}-alb-waf"
  log_group_name     = "aws-waf-logs-${local.name_prefix}-alb"

  log_retention_in_days = 90

  tags = local.common_tags
}
\`\`\`

## 🔒 Security Considerations

This module enables AWS managed rule groups for common web attacks, malicious IP reputation, known bad inputs, and SQL injection protection.

The Web ACL should be associated with the public ALB before production workloads are exposed.

WAF logs may contain request metadata. Use retention policies and KMS encryption where required.

## 💡 Design Decisions

This module starts with AWS managed rule groups instead of custom rules because managed rules provide a strong baseline for common threats.

The module supports optional association so the same module can be reused later for CloudFront, API Gateway, or other regional resources.

Logging is included because WAF without logs is difficult to troubleshoot and tune.

## 📖 Next Steps

- Call this module from the `security/` root module
- Attach it to the networking ALB
- Add rate-based rules
- Add custom allow/block IP sets if needed
- Add CloudWatch alarms for blocked request spikes