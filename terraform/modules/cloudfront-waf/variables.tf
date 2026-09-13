# =============================================================================
# CloudHustler Commerce Platform
# Phase 7.7 - CloudFront WAF
#
# Purpose:
# Defines inputs used to create the CloudFront-scoped AWS WAF Web ACL.
# =============================================================================

variable "project_name" {
  description = "Name of the CloudHustler Commerce Platform."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "tags" {
  description = "Tags applied to the WAF resources."
  type        = map(string)
  default     = {}
}

variable "rate_limit" {
  description = "Maximum number of requests allowed per source IP during the WAF rate evaluation window."
  type        = number
  default     = 2000
}

variable "log_retention_days" {
  description = "Number of days to retain AWS WAF logs in CloudWatch Logs."
  type        = number
  default     = 14
}

variable "blocked_requests_threshold" {
  description = "Blocked request count within the alarm period that triggers the WAF blocked-request alarm."
  type        = number
  default     = 100
}

variable "rate_limit_alarm_threshold" {
  description = "Rate-limit blocked request count within the alarm period that triggers the alarm."
  type        = number
  default     = 1
}

variable "alert_email" {
  description = "Email address that receives WAF CloudWatch alarm notifications."
  type        = string
}