# =============================================================================
# AVOS AWS Organizations — Input Variables
#
# Declares the account, organization, Region, ownership, and optional tagging
# values accepted by this Terraform root.
# =============================================================================

variable "aws_region" {
  description = "AWS Region used by the provider for API operations."
  type        = string
  default     = "us-east-2"

  validation {
    condition     = can(regex("^[a-z]{2}(-[a-z]+)+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS Region name such as us-east-2."
  }
}

variable "management_account_id" {
  description = "Twelve-digit AWS account ID authorized to manage the organization."
  type        = string

  validation {
    condition     = can(regex("^\\d{12}$", var.management_account_id))
    error_message = "management_account_id must contain exactly 12 digits."
  }
}

variable "expected_organization_id" {
  description = "AWS Organizations ID that this Terraform root is authorized to manage."
  type        = string

  validation {
    condition     = can(regex("^o-[a-z0-9]{10,32}$", var.expected_organization_id))
    error_message = "expected_organization_id must be a valid ID beginning with o-."
  }
}

variable "owner" {
  description = "Team responsible for the AVOS organization configuration."
  type        = string
  default     = "AVOS Platform Engineering"

  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "owner must not be empty."
  }
}

variable "additional_tags" {
  description = "Additional tags to merge with the mandatory AVOS tags."
  type        = map(string)
  default     = {}
}