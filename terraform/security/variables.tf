# =============================================================================
# AVOS Security — Input Variables
# =============================================================================

variable "aws_region" {
  description = "AWS Region in which regional AVOS security services are enabled."
  type        = string
  default     = "us-east-2"

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS Region name."
  }
}

variable "management_account_id" {
  description = "AWS Organizations management account in which this root may operate."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.management_account_id))
    error_message = "management_account_id must contain exactly 12 digits."
  }
}

variable "organization_id" {
  description = "Expected AWS Organizations organization ID."
  type        = string

  validation {
    condition     = can(regex("^o-[a-z0-9]{10,32}$", var.organization_id))
    error_message = "organization_id must use the AWS Organizations o-xxxxxxxxxx format."
  }
}

variable "project_name" {
  description = "Short project identifier used in resource names and tags."
  type        = string
  default     = "avos"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,19}$", var.project_name))
    error_message = "project_name must start with a lowercase letter and contain only lowercase letters, digits, and hyphens."
  }
}

variable "environment" {
  description = "AVOS environment protected by this deployment."
  type        = string
  default     = "dev"

  validation {
    condition = contains(
      ["dev", "staging", "prod"],
      var.environment
    )
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "owner" {
  description = "Team responsible for the AVOS security services."
  type        = string
  default     = "AVOS Platform Engineering"

  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "owner must not be empty."
  }
}

variable "repository_name" {
  description = "Repository associated with these security resources."
  type        = string
  default     = "African-Vibe-Online-Shop-AVOS"
}

variable "guardduty_finding_publishing_frequency" {
  description = "Frequency at which GuardDuty publishes updated findings."
  type        = string
  default     = "FIFTEEN_MINUTES"

  validation {
    condition = contains(
      ["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"],
      var.guardduty_finding_publishing_frequency
    )
    error_message = "GuardDuty publishing frequency must be FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  }
}

variable "additional_tags" {
  description = "Additional tags merged into the mandatory AVOS tag set."
  type        = map(string)
  default     = {}
}