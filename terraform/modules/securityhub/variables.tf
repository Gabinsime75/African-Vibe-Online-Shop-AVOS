variable "enable_default_standards" {
  description = "Enable AWS Security Hub default standards."
  type        = bool
  default     = true
}

variable "control_finding_generator" {
  description = "Determines whether findings are generated for each control or consolidated."
  type        = string
  default     = "SECURITY_CONTROL"

  validation {
    condition = contains([
      "STANDARD_CONTROL",
      "SECURITY_CONTROL"
    ], var.control_finding_generator)

    error_message = "Valid values are STANDARD_CONTROL or SECURITY_CONTROL."
  }
}

variable "auto_enable_controls" {
  description = "Automatically enable new security controls."
  type        = bool
  default     = true
}

variable "enable_fsbp_standard" {
  description = "Enable AWS Foundational Security Best Practices."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to Security Hub resources."
  type        = map(string)
  default     = {}
}