# Helps identify the key's purpose in AWS.
#---------------------------------------------------------
variable "description" {
  type        = string
  description = "Description of the KMS key."
  default     = "KMS key created by Terraform."
}

# Provides a friendly name instead of the key ID.
#------------------------------------------------------------
variable "alias" {
  type        = string
  description = "Alias for the KMS key."
  default     = "alias/terraform-kms-key"
}

# Recommended for long-lived customer-managed keys.
#---------------------------------------------------------------
variable "enable_key_rotation" {
  type        = bool
  description = "Enable automatic annual key rotation."
  default     = true
}

# Used for disaster recovery and cross-region replication.
#------------------------------------------------------------------
variable "multi_region" {
  type        = bool
  description = "Whether the KMS key should be Multi-Region."
  default     = false
}

# Provides a recovery window for accidental deletions.
#-------------------------------------------------------------------
variable "deletion_window_in_days" {
  type        = number
  description = "Number of days before the KMS key is permanently deleted."
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Deletion window must be between 7 and 30 days."
  }
}

# Applied to all resources created by this module.
#-------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  description = "Map of tags applied to the KMS resources."
  default     = {}
}

# Disabled keys cannot be used for cryptographic operations.
#-----------------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "Whether the KMS key is enabled."
  default     = true
}

# Defaults to a symmetric encryption key.
#-------------------------------------------------------------------
variable "customer_master_key_spec" {
  type        = string
  description = "KMS key specification."

  default = "SYMMETRIC_DEFAULT"
}

variable "aws_region" {
  description = "AWS Region."
  type        = string
  default     = "us-east-2"
}