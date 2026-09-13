variable "trail_name" {
  description = "Name of the CloudTrail trail."
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket where CloudTrail logs will be stored."
  type        = string
}

variable "kms_key_id" {
  description = "KMS key used to encrypt CloudTrail logs."
  type        = string
  default     = null
}

variable "is_multi_region_trail" {
  description = "Whether the trail applies to all AWS Regions."
  type        = bool
  default     = true
}

variable "include_global_service_events" {
  description = "Include global service events."
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Enable log file integrity validation."
  type        = bool
  default     = true
}

variable "is_organization_trail" {
  description = "Create an organization trail."
  type        = bool
  default     = false
}

variable "enable_logging" {
  description = "Enable logging."
  type        = bool
  default     = true
}

variable "cloud_watch_logs_group_arn" {
  description = "CloudWatch Logs group ARN."
  type        = string
  default     = null
}

variable "cloud_watch_logs_role_arn" {
  description = "IAM role ARN for CloudWatch Logs."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

