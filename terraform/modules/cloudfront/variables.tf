# =============================================================================
# CloudHustler Commerce Platform
# Module: CloudFront
# Variables
#
# Purpose:
# Defines configurable inputs used by the CloudFront distribution module.
# =============================================================================

variable "project_name" {
  description = "Project name used for naming and tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the existing public Application Load Balancer."
  type        = string
}

variable "origin_id" {
  description = "Unique CloudFront origin identifier."
  type        = string
  default     = "alb-origin"
}

variable "price_class" {
  description = "CloudFront edge-location price class."
  type        = string
  default     = "PriceClass_100"

  validation {
    condition = contains([
      "PriceClass_100",
      "PriceClass_200",
      "PriceClass_All"
    ], var.price_class)

    error_message = "price_class must be PriceClass_100, PriceClass_200, or PriceClass_All."
  }
}

variable "tags" {
  description = "Additional resource tags."
  type        = map(string)
  default     = {}
}

variable "aliases" {
  description = "Alternate domain names served by the CloudFront distribution."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN used for CloudFront viewer HTTPS."
  type        = string
  default     = null
}

variable "default_cache_policy_id" {
  description = "CloudFront cache policy ID used by the default cache behavior."
  type        = string
}

variable "static_cache_policy_id" {
  description = "CloudFront cache policy ID used for static-content behaviors."
  type        = string
}

variable "default_origin_request_policy_id" {
  description = "Origin request policy ID used by the default cache behavior."
  type        = string
}

variable "static_origin_request_policy_id" {
  description = "Origin request policy ID used by the static cache behavior."
  type        = string
}

variable "default_response_headers_policy_id" {
  description = "CloudFront response headers policy used by the default cache behavior."
  type        = string
}

variable "static_response_headers_policy_id" {
  description = "CloudFront response headers policy used by the static cache behavior."
  type        = string
}

variable "web_acl_id" {
  description = "ARN of the AWS WAFv2 Web ACL associated with CloudFront."
  type        = string
  default     = null
}