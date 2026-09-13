################################################################################
# General
################################################################################

variable "name" {
  description = "Name of the TargetGroupBinding Kubernetes resource."
  type        = string

  validation {
    condition = (
      length(var.name) > 0 &&
      length(var.name) <= 63 &&
      can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name))
    )

    error_message = "The TargetGroupBinding name must be a valid Kubernetes DNS-1123 label containing lowercase alphanumeric characters or hyphens and must not exceed 63 characters."
  }
}

variable "namespace" {
  description = "Kubernetes namespace where the TargetGroupBinding will be created."
  type        = string

  validation {
    condition = (
      length(var.namespace) > 0 &&
      length(var.namespace) <= 63 &&
      can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace))
    )

    error_message = "The namespace must be a valid Kubernetes DNS-1123 label containing lowercase alphanumeric characters or hyphens and must not exceed 63 characters."
  }
}

################################################################################
# Kubernetes Service
################################################################################

variable "service_name" {
  description = "Name of the Kubernetes Service that will receive traffic from the AWS target group."
  type        = string

  validation {
    condition = (
      length(var.service_name) > 0 &&
      length(var.service_name) <= 63 &&
      can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.service_name))
    )

    error_message = "The service name must be a valid Kubernetes DNS-1123 label containing lowercase alphanumeric characters or hyphens and must not exceed 63 characters."
  }
}

variable "service_port" {
  description = "Kubernetes Service port referenced by the TargetGroupBinding."
  type        = number

  validation {
    condition     = var.service_port >= 1 && var.service_port <= 65535
    error_message = "The service port must be between 1 and 65535."
  }
}

################################################################################
# AWS Target Group
################################################################################

variable "target_group_arn" {
  description = "ARN of the existing AWS Application Load Balancer target group."
  type        = string

  validation {
    condition = can(
      regex(
        "^arn:(aws|aws-us-gov|aws-cn):elasticloadbalancing:[a-z0-9-]+:[0-9]{12}:targetgroup/[A-Za-z0-9-]+/[A-Za-z0-9]+$",
        var.target_group_arn
      )
    )

    error_message = "The target_group_arn value must be a valid AWS Elastic Load Balancing target group ARN."
  }
}

variable "target_type" {
  description = "Target registration type used by the AWS target group. Valid values are ip or instance."
  type        = string
  default     = "ip"

  validation {
    condition     = contains(["ip", "instance"], var.target_type)
    error_message = "The target type must be either \"ip\" or \"instance\"."
  }
}

################################################################################
# Kubernetes Metadata
################################################################################

variable "labels" {
  description = "Additional labels to apply to the TargetGroupBinding resource."
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Annotations to apply to the TargetGroupBinding resource."
  type        = map(string)
  default     = {}
}