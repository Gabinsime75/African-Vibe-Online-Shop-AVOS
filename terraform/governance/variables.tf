# =============================================================================
# AVOS Governance — Input Variables
# =============================================================================

variable "aws_region" {
  description = "Primary AWS Region for regional AVOS governance resources."
  type        = string
  default     = "us-east-2"

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS Region name."
  }
}

variable "management_account_id" {
  description = "AWS Organizations management account in which this root is allowed to operate."
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
  description = "Short project identifier used in names and tags."
  type        = string
  default     = "avos"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,19}$", var.project_name))
    error_message = "project_name must start with a lowercase letter and contain only lowercase letters, digits, and hyphens."
  }
}

variable "environment" {
  description = "AVOS environment represented by this governance deployment."
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
  description = "Team responsible for the governance infrastructure."
  type        = string
  default     = "AVOS Platform Engineering"

  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "owner must not be empty."
  }
}

variable "repository_name" {
  description = "Source repository associated with these resources."
  type        = string
  default     = "African-Vibe-Online-Shop-AVOS"
}

variable "additional_tags" {
  description = "Additional tags merged into the mandatory AVOS tag set."
  type        = map(string)
  default     = {}
}

variable "audit_log_retention_days" {
  description = "Number of days audit evidence is retained before expiration."
  type        = number
  default     = 2555

  validation {
    condition = (
      var.audit_log_retention_days >= 365 &&
      var.audit_log_retention_days <= 3650
    )
    error_message = "audit_log_retention_days must be between 365 and 3650 days."
  }
}