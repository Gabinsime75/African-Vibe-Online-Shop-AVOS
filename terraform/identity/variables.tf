# =============================================================================
# AVOS IAM Identity Center — Input Variables
#
# Defines regional, account, instance, ownership, and tagging inputs for the
# Identity Center Terraform root.
# =============================================================================

variable "identity_center_region" {
  description = "AWS Region containing the AVOS IAM Identity Center organization instance."
  type        = string
  default     = "us-east-2"

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]+$", var.identity_center_region))
    error_message = "identity_center_region must be a valid AWS Region identifier."
  }
}

variable "management_account_id" {
  description = "AWS Organizations management account in which the AVOS organization instance is enabled."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.management_account_id))
    error_message = "management_account_id must contain exactly 12 digits."
  }
}

variable "expected_identity_center_instance_arn" {
  description = "Expected ARN of the AVOS IAM Identity Center organization instance."
  type        = string

  validation {
    condition = can(regex(
      "^arn:aws:sso:::instance/ssoins-[A-Za-z0-9-.]{16}$",
      var.expected_identity_center_instance_arn
    ))

    error_message = "expected_identity_center_instance_arn must be a valid IAM Identity Center organization instance ARN."
  }
}

variable "expected_identity_store_id" {
  description = "Expected identity store ID associated with the AVOS organization instance."
  type        = string

  validation {
    condition     = can(regex("^d-[A-Za-z0-9-]+$", var.expected_identity_store_id))
    error_message = "expected_identity_store_id must be a valid Identity Store identifier."
  }
}

variable "owner" {
  description = "Team responsible for the identity platform."
  type        = string
  default     = "AVOS Platform Engineering"
}

variable "repository_name" {
  description = "Source repository responsible for this Terraform root."
  type        = string
  default     = "African-Vibe-Online-Shop-AVOS"
}

variable "additional_tags" {
  description = "Additional tags merged with the required AVOS identity tags."
  type        = map(string)
  default     = {}
}

variable "platform_admin_user_name" {
  description = "Username of the initial AVOS platform administrator in IAM Identity Center."
  type        = string

  validation {
    condition     = length(trimspace(var.platform_admin_user_name)) > 0
    error_message = "platform_admin_user_name must not be empty."
  }
}
