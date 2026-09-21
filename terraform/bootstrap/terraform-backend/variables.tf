# =============================================================================
# AVOS Terraform Bootstrap — Input Variables
#
# Defines validated inputs for account safety, resource naming, encryption,
# state retention, and mandatory resource ownership.
# =============================================================================

variable "expected_aws_account_id" {
  description = "Twelve-digit AWS account ID in which bootstrap resources may be created."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_aws_account_id))
    error_message = "expected_aws_account_id must contain exactly 12 digits."
  }
}

variable "aws_region" {
  description = "AWS Region in which the AVOS state foundation is created."
  type        = string
  default     = "us-east-2"

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS Region name, such as us-east-2."
  }
}

variable "environment" {
  description = "AVOS environment represented by this bootstrap deployment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Lowercase project identifier used in AWS resource names."
  type        = string
  default     = "avos"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,19}$", var.project_name))
    error_message = "project_name must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "owner" {
  description = "Team responsible for the bootstrap resources."
  type        = string
  default     = "platform-engineering"

  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "owner cannot be empty."
  }
}

variable "state_noncurrent_version_expiration_days" {
  description = "Number of days S3 retains noncurrent Terraform state versions."
  type        = number
  default     = 365

  validation {
    condition     = var.state_noncurrent_version_expiration_days >= 90
    error_message = "Terraform state versions must be retained for at least 90 days."
  }
}

variable "kms_deletion_window_in_days" {
  description = "Waiting period before AWS KMS permanently deletes a scheduled key."
  type        = number
  default     = 30

  validation {
    condition = (
      var.kms_deletion_window_in_days >= 7 &&
      var.kms_deletion_window_in_days <= 30
    )
    error_message = "kms_deletion_window_in_days must be between 7 and 30."
  }
}

variable "additional_tags" {
  description = "Additional non-sensitive tags applied to bootstrap resources."
  type        = map(string)
  default     = {}
}