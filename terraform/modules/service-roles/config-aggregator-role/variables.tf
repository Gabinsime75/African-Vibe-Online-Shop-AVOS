variable "role_name" {
  description = "Name of the AWS Config Aggregator IAM role."
  type        = string
  default     = "aws-config-aggregator-role"
}

variable "tags" {
  description = "Tags applied to the IAM resources."
  type        = map(string)
  default     = {}
}