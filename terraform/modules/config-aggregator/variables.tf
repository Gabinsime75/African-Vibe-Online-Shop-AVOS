variable "aggregator_name" {
  description = "Name of the AWS Config Aggregator."
  type        = string
}

variable "organization_aggregation" {
  description = "Enable AWS Organizations aggregation."
  type        = bool
  default     = true
}

variable "account_ids" {
  description = "AWS account IDs to aggregate when not using AWS Organizations."
  type        = list(string)
  default     = []
}

variable "aws_regions" {
  description = "AWS Regions to aggregate."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to the Config Aggregator."
  type        = map(string)
  default     = {}
}

variable "organization_role_arn" {
  description = "IAM role ARN used by AWS Config to aggregate organization configuration."
  type        = string
  default     = null
}