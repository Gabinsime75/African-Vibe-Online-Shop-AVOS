###############################################################
# Certificate Configuration
###############################################################

variable "domain_name" {
  description = "Primary domain name for the ACM certificate."
  type        = string
}

variable "subject_alternative_names" {
  description = "Subject Alternative Names (SANs) for the ACM certificate."
  type        = list(string)
  default     = []
}

variable "validation_method" {
  description = "Certificate validation method. Valid values are DNS or EMAIL."
  type        = string
  default     = "DNS"

  validation {
    condition = contains(
      ["DNS", "EMAIL"],
      upper(var.validation_method)
    )

    error_message = "validation_method must be DNS or EMAIL."
  }
}

###############################################################
# Route53 DNS Validation
###############################################################

variable "create_route53_records" {
  description = "Whether to automatically create Route53 DNS validation records."
  type        = bool
  default     = false
}

variable "hosted_zone_id" {
  description = "Existing Route53 Hosted Zone ID used for DNS validation. If null, hosted_zone_name can be used for lookup."
  type        = string
  default     = null
}

variable "hosted_zone_name" {
  description = "Route53 Hosted Zone name used for lookup when hosted_zone_id is not provided."
  type        = string
  default     = null
}

variable "allow_overwrite_validation_records" {
  description = "Whether Route53 validation records are allowed to overwrite existing records."
  type        = bool
  default     = true
}

variable "validation_record_ttl" {
  description = "TTL for Route53 DNS validation records."
  type        = number
  default     = 60
}

###############################################################
# Certificate Features
###############################################################

variable "key_algorithm" {
  description = "Key algorithm for the ACM certificate request."
  type        = string
  default     = "RSA_2048"

  validation {
    condition = contains(
      [
        "RSA_2048",
        "EC_prime256v1",
        "EC_secp384r1"
      ],
      var.key_algorithm
    )

    error_message = "key_algorithm must be RSA_2048, EC_prime256v1, or EC_secp384r1 for ACM certificate requests."
  }
}

variable "certificate_transparency_logging_preference" {
  description = "Certificate Transparency logging preference. Valid values are ENABLED or DISABLED."
  type        = string
  default     = "ENABLED"

  validation {
    condition = contains(
      ["ENABLED", "DISABLED"],
      upper(var.certificate_transparency_logging_preference)
    )

    error_message = "certificate_transparency_logging_preference must be ENABLED or DISABLED."
  }
}

###############################################################
# Tags
###############################################################

variable "tags" {
  description = "Tags applied to all supported ACM resources."
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-2"
}