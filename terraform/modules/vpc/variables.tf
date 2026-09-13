###############################################
# General
###############################################

variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

###############################################
# VPC Configuration
###############################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "enable_dns_support" {
  description = "Enable DNS resolution within the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames within the VPC."
  type        = bool
  default     = true
}

###############################################
# Availability Zones
###############################################

variable "az_count" {
  description = "Number of Availability Zones to use."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2
    error_message = "The VPC module requires at least two Availability Zones."
  }
}

###############################################
# Public Subnets
###############################################

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == var.az_count
    error_message = "The number of public subnet CIDRs must equal az_count."
  }
}

###############################################
# Private Application Subnets
###############################################

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets."
  type        = list(string)

  validation {
    condition     = length(var.private_app_subnet_cidrs) == var.az_count
    error_message = "The number of application subnet CIDRs must equal az_count."
  }
}

###############################################
# Private Database Subnets
###############################################

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets."
  type        = list(string)

  validation {
    condition     = length(var.private_db_subnet_cidrs) == var.az_count
    error_message = "The number of database subnet CIDRs must equal az_count."
  }
}

###############################################
# NAT Gateway Configuration
###############################################

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateways."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Deploy a single NAT Gateway instead of one per Availability Zone."
  type        = bool
  default     = false
}

###############################################
# Flow Logs
###############################################

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs."
  type        = bool
  default     = false
}

variable "flow_logs_destination_arn" {
  description = "CloudWatch Log Group or S3 bucket ARN for Flow Logs."
  type        = string
  default     = null
}

variable "flow_logs_iam_role_arn" {
  description = "IAM role used by Flow Logs."
  type        = string
  default     = null
}

variable "flow_logs_traffic_type" {
  description = "Traffic type captured by Flow Logs."
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ALL", "ACCEPT", "REJECT"], var.flow_logs_traffic_type)
    error_message = "Traffic type must be ALL, ACCEPT, or REJECT."
  }
}

###############################################
# IPv6
###############################################

variable "enable_ipv6" {
  description = "Assign an Amazon-provided IPv6 CIDR block."
  type        = bool
  default     = false
}