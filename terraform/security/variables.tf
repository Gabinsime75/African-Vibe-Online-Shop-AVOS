variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "aws_region" {
  description = "AWS region where security resources are deployed."
  type        = string
}

variable "alb_arn" {
  description = "ARN of the public Application Load Balancer to associate with AWS WAF."
  type        = string
}

variable "waf_log_retention_in_days" {
  description = "Number of days to retain WAF logs."
  type        = number
  default     = 90
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "waf_rate_limit" {
  description = "Maximum requests allowed from a single IP address in a 5-minute period."
  type        = number
  default     = 2000
}

variable "waf_allow_ip_addresses" {
  description = "IPv4 CIDR addresses explicitly allowed by WAF."
  type        = list(string)
  default     = []
}

variable "waf_block_ip_addresses" {
  description = "IPv4 CIDR addresses explicitly blocked by WAF."
  type        = list(string)
  default     = []
}

variable "enable_waf_blocked_requests_alarm" {
  description = "Whether to create a CloudWatch alarm for blocked WAF requests."
  type        = bool
  default     = true
}

variable "waf_blocked_requests_alarm_threshold" {
  description = "Blocked request threshold for the WAF alarm."
  type        = number
  default     = 100
}

variable "waf_blocked_requests_alarm_period" {
  description = "CloudWatch alarm period in seconds."
  type        = number
  default     = 300
}

variable "waf_blocked_requests_alarm_evaluation_periods" {
  description = "Number of evaluation periods for the WAF blocked request alarm."
  type        = number
  default     = 1
}

variable "waf_alarm_actions" {
  description = "SNS topic ARNs or other actions for WAF alarm state."
  type        = list(string)
  default     = []
}

variable "waf_ok_actions" {
  description = "SNS topic ARNs or other actions for WAF OK state."
  type        = list(string)
  default     = []
}