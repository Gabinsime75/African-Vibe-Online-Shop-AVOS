variable "configuration_recorder_name" {
  description = "Name of the AWS Config configuration recorder."
  type        = string
  default     = "default"
}

variable "delivery_channel_name" {
  description = "Name of the AWS Config delivery channel."
  type        = string
  default     = "default"
}

variable "s3_bucket_name" {
  description = "S3 bucket used to store AWS Config snapshots."
  type        = string

}

variable "sns_topic_arn" {
  description = "SNS topic ARN for configuration notifications."
  type        = string
  default     = null
}

variable "iam_role_arn" {
  description = "IAM Role ARN used by AWS Config."
  type        = string
}

variable "recording_group_all_supported" {
  description = "Record all supported resource types."
  type        = bool
  default     = true
}

variable "include_global_resource_types" {
  description = "Include global IAM resources."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to AWS Config resources."
  type        = map(string)
  default     = {}
}