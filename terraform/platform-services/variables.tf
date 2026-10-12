# =============================================================================
# AVOS Platform Services — Environment Inputs
# =============================================================================

variable "aws_region" {
  description = "AWS Region containing the existing AVOS EKS cluster."
  type        = string
  default     = "us-east-2"
}

variable "aws_account_id" {
  description = "AWS account authorized for this Terraform root."
  type        = string
  default     = "396913735153"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must contain exactly 12 digits."
  }
}

variable "cluster_name" {
  description = "Existing EKS cluster managed by the container-platform root."
  type        = string
  default     = "avos-dev-eks"
}

variable "environment" {
  description = "AVOS deployment environment."
  type        = string
  default     = "dev"
}
