variable "aws_region" {

  description = "AWS region used by the AWS provider."
  type        = string
  default     = "us-east-2"

}


variable "create_security_ou" {

  description = "Whether to create the Security Organizational Unit."
  type        = bool
  default     = true

}

variable "create_infrastructure_ou" {

  description = "Whether to create the Infrastructure Organizational Unit."
  type        = bool
  default     = true

}

variable "create_shared_services_ou" {

  description = "Whether to create the Shared Services Organizational Unit."
  type        = bool
  default     = true

}

variable "create_logging_ou" {

  description = "Whether to create the Logging Organizational Unit."
  type        = bool
  default     = true

}

variable "create_nonproduction_ou" {

  description = "Whether to create the NonProduction Organizational Unit."
  type        = bool
  default     = true

}

variable "create_development_ou" {

  description = "Whether to create the Development Organizational Unit."
  type        = bool
  default     = true

}

variable "create_testing_ou" {

  description = "Whether to create the Testing Organizational Unit."
  type        = bool
  default     = true

}

variable "create_staging_ou" {

  description = "Whether to create the Staging Organizational Unit."
  type        = bool
  default     = true

}

variable "create_production_ou" {

  description = "Whether to create the Production Organizational Unit."
  type        = bool
  default     = true

}

variable "create_suspended_ou" {

  description = "Whether to create the Suspended Organizational Unit."
  type        = bool
  default     = true

}

variable "tags" {

  description = "Additional tags to apply to supported AWS resources."
  type        = map(string)
  default     = {}

}