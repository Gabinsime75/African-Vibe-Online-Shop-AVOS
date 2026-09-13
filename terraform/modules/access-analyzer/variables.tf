variable "analyzer_name" {
  description = "Name of the IAM Access Analyzer."
  type        = string
  default     = "commerce-platform-access-analyzer"
}

variable "type" {
  description = "Type of analyzer."
  type        = string
  default     = "ACCOUNT"

  validation {
    condition = contains([
      "ACCOUNT",
      "ORGANIZATION"
    ], var.type)

    error_message = "Valid values are ACCOUNT or ORGANIZATION."
  }
}

variable "tags" {
  description = "Tags applied to the analyzer."
  type        = map(string)
  default     = {}
}