variable "role_name" {
  description = "Name of the AWS GuardDuty service role."
  type        = string
}

variable "tags" {
  description = "Tags applied to the IAM resources."
  type        = map(string)
  default     = {}
}