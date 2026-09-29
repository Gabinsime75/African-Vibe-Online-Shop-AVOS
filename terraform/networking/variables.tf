# =============================================================================
# AVOS Network Foundation — Input Variables
#
# Defines and validates the account, Region, CIDR allocation, NAT topology,
# Flow Logs retention, and tagging inputs used by the network root.
# =============================================================================

variable "project_name" {
  description = "Short project identifier used in AVOS resource names and tags."
  type        = string
  default     = "avos"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment represented by this Terraform root."
  type        = string
  default     = "dev"

  validation {
    condition = contains(
      ["dev", "staging", "prod"],
      var.environment
    )
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "aws_account_id" {
  description = "AWS account in which the AVOS network may be deployed."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID."
  }
}

variable "aws_region" {
  description = "AWS Region in which the AVOS network is deployed."
  type        = string
  default     = "us-east-2"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS Region identifier."
  }
}

variable "vpc_cidr" {
  description = "Primary IPv4 CIDR block assigned to the AVOS VPC."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Three Availability Zones used by the AVOS network."
  type        = list(string)

  default = [
    "us-east-2a",
    "us-east-2b",
    "us-east-2c"
  ]

  validation {
    condition = (
      length(var.availability_zones) == 3 &&
      length(distinct(var.availability_zones)) == 3
    )
    error_message = "availability_zones must contain exactly three unique Availability Zones."
  }
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs keyed by Availability Zone."
  type        = map(string)

  default = {
    us-east-2a = "10.20.0.0/20"
    us-east-2b = "10.20.16.0/20"
    us-east-2c = "10.20.32.0/20"
  }

  validation {
    condition = alltrue([
      for cidr in values(var.public_subnet_cidrs) :
      can(cidrnetmask(cidr))
    ])
    error_message = "Every public subnet value must be a valid IPv4 CIDR block."
  }
}

variable "private_application_subnet_cidrs" {
  description = "Private application subnet CIDRs keyed by Availability Zone."
  type        = map(string)

  default = {
    us-east-2a = "10.20.64.0/20"
    us-east-2b = "10.20.80.0/20"
    us-east-2c = "10.20.96.0/20"
  }

  validation {
    condition = alltrue([
      for cidr in values(var.private_application_subnet_cidrs) :
      can(cidrnetmask(cidr))
    ])
    error_message = "Every private application subnet value must be a valid IPv4 CIDR block."
  }
}

variable "private_data_subnet_cidrs" {
  description = "Private data subnet CIDRs keyed by Availability Zone."
  type        = map(string)

  default = {
    us-east-2a = "10.20.128.0/20"
    us-east-2b = "10.20.144.0/20"
    us-east-2c = "10.20.160.0/20"
  }

  validation {
    condition = alltrue([
      for cidr in values(var.private_data_subnet_cidrs) :
      can(cidrnetmask(cidr))
    ])
    error_message = "Every private data subnet value must be a valid IPv4 CIDR block."
  }
}

variable "nat_gateway_mode" {
  description = "NAT topology: single for dev or per_az for higher availability."
  type        = string
  default     = "single"

  validation {
    condition     = contains(["single", "per_az"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode must be single or per_az."
  }
}

variable "flow_log_retention_days" {
  description = "Number of days CloudWatch Logs retains VPC Flow Logs."
  type        = number
  default     = 30

  validation {
    condition = contains(
      [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365,
      400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653],
      var.flow_log_retention_days
    )
    error_message = "flow_log_retention_days must be a supported CloudWatch Logs retention period."
  }
}

variable "additional_tags" {
  description = "Additional tags merged with the mandatory AVOS tags."
  type        = map(string)
  default     = {}
}