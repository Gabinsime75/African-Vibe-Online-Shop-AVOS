variable "name" {
  description = "Name of the WAF Web ACL."
  type        = string
}

variable "description" {
  description = "Description of the WAF Web ACL."
  type        = string
  default     = "Managed WAF Web ACL."
}

variable "scope" {
  description = "Scope of the WAF Web ACL. Use REGIONAL for ALB/API Gateway/AppSync, CLOUDFRONT for CloudFront."
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "scope must be either REGIONAL or CLOUDFRONT."
  }
}

variable "associate_resource_arn" {
  description = "ARN of the AWS resource to associate with the Web ACL, such as an ALB ARN. Set to null to skip association."
  type        = string
  default     = null
}

variable "cloudwatch_metrics_enabled" {
  description = "Whether CloudWatch metrics are enabled for the Web ACL and rules."
  type        = bool
  default     = true
}

variable "sampled_requests_enabled" {
  description = "Whether sampled requests are enabled for the Web ACL and rules."
  type        = bool
  default     = true
}

variable "metric_name_prefix" {
  description = "Prefix used for WAF CloudWatch metric names."
  type        = string
}

variable "enable_logging" {
  description = "Whether to enable WAF logging to CloudWatch Logs."
  type        = bool
  default     = true
}

variable "log_group_name" {
  description = "Name of the CloudWatch Log Group for WAF logs. AWS WAF log groups should start with aws-waf-logs-."
  type        = string
}

variable "log_retention_in_days" {
  description = "Number of days to retain WAF logs."
  type        = number
  default     = 90
}

variable "log_kms_key_id" {
  description = "Optional KMS key ARN for encrypting WAF CloudWatch logs."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to WAF resources."
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region used for WAF CloudWatch metric dimensions."
  type        = string
}

variable "rate_limit" {
  description = "Maximum number of requests allowed from a single IP address in a 5-minute period."
  type        = number
  default     = 2000
}

variable "allow_ip_addresses" {
  description = "List of IPv4 CIDR addresses to explicitly allow."
  type        = list(string)
  default     = []
}

variable "block_ip_addresses" {
  description = "List of IPv4 CIDR addresses to explicitly block."
  type        = list(string)
  default     = []
}

variable "enable_blocked_requests_alarm" {
  description = "Whether to create a CloudWatch alarm for blocked WAF requests."
  type        = bool
  default     = true
}

variable "blocked_requests_alarm_threshold" {
  description = "Number of blocked requests that triggers the alarm."
  type        = number
  default     = 100
}

variable "blocked_requests_alarm_period" {
  description = "CloudWatch alarm period in seconds."
  type        = number
  default     = 300
}

variable "blocked_requests_alarm_evaluation_periods" {
  description = "Number of periods over which blocked requests are evaluated."
  type        = number
  default     = 1
}

variable "alarm_actions" {
  description = "SNS topic ARNs or other actions to trigger when the alarm enters ALARM state."
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "SNS topic ARNs or other actions to trigger when the alarm returns to OK."
  type        = list(string)
  default     = []
}