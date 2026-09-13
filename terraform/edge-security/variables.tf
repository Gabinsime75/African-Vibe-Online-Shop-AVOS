variable "project_name" {
  description = "CloudHustler project name."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

# variable "alb_dns_name" {
#   description = "DNS name of the public ALB used as the CloudFront origin."
#   type        = string
# }

variable "cloudfront_price_class" {
  description = "CloudFront edge-location price class."
  type        = string
  default     = "PriceClass_100"
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region for the CloudFront distribution."
  type        = string
  default     = "us-east-2"
}

variable "domain_name" {
  description = "Primary public domain for the CloudHustler platform."
  type        = string
  default     = "cloudhusller.com"
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID for cloudhusller.com."
  type        = string
}

variable "waf_rate_limit" {
  description = "Maximum requests allowed per source IP during the WAF rate evaluation window."
  type        = number
  default     = 2000
}

variable "waf_log_retention_days" {
  description = "CloudWatch Logs retention period for AWS WAF request logs."
  type        = number
  default     = 14
}

variable "waf_blocked_requests_threshold" {
  description = "Threshold for blocked WAF requests within a 5-minute period."
  type        = number
  default     = 100
}

variable "waf_rate_limit_alarm_threshold" {
  description = "Threshold for rate-limit blocking activity within a 5-minute period."
  type        = number
  default     = 1
}

variable "waf_alert_email" {
  description = "Email address that receives WAF security alarm notifications."
  type        = string
}