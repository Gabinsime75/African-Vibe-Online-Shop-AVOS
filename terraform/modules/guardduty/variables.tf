variable "enable" {
  description = "Enable GuardDuty."
  type        = bool
  default     = true
}

variable "finding_publishing_frequency" {
  description = "Frequency for publishing GuardDuty findings."
  type        = string
  default     = "FIFTEEN_MINUTES"

  validation {
    condition = contains([
      "FIFTEEN_MINUTES",
      "ONE_HOUR",
      "SIX_HOURS"
    ], var.finding_publishing_frequency)

    error_message = "Valid values are FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  }
}

variable "datasources" {
  description = "Enable GuardDuty data sources."
  type = object({
    s3_logs = bool
    kubernetes = object({
      audit_logs = bool
    })
    malware_protection = object({
      scan_ec2_instance_with_findings = bool
    })
  })

  default = {
    s3_logs = true

    kubernetes = {
      audit_logs = true
    }

    malware_protection = {
      scan_ec2_instance_with_findings = true
    }
  }
}

variable "tags" {
  description = "Tags applied to the GuardDuty detector."
  type        = map(string)
  default     = {}
}