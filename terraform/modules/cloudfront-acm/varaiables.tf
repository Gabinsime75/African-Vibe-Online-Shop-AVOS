# =============================================================================
# CloudHustler Commerce Platform
# Module: CloudFront ACM
# Variables
# =============================================================================

variable "project_name" {
  description = "CloudHustler project name."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "domain_name" {
  description = "Primary domain covered by the CloudFront certificate."
  type        = string
}

variable "subject_alternative_names" {
  description = "Additional domain names covered by the certificate."
  type        = list(string)
  default     = []
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID used for ACM DNS validation."
  type        = string
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}