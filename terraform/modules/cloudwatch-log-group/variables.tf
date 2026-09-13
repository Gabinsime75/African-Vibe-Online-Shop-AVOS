variable "name" {
  description = "Name of the CloudWatch Log Group."
  type        = string
  default     = "commerce-platform-log-group"
}

variable "retention_in_days" {
  description = "Number of days to retain log events."
  type        = number
  default     = 365
}

variable "kms_key_id" {
  description = "ARN of the KMS key used to encrypt the CloudWatch log group."
  type        = string
}

variable "log_group_class" {
  description = "CloudWatch Log Group class."
  type        = string
  default     = "STANDARD"

  validation {
    condition = contains([
      "STANDARD",
      "INFREQUENT_ACCESS"
    ], var.log_group_class)

    error_message = "log_group_class must be STANDARD or INFREQUENT_ACCESS."
  }
}

variable "skip_destroy" {
  description = "Prevent deletion of log group when Terraform destroys resources."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the log group."
  type        = map(string)
  default     = {}
}