
# IAM Role
variable "role_name" {
  description = "Name of the IAM role."
  type        = string
  default     = "commerce-platform-iam-role"
}

variable "role_description" {
  description = "Description of the IAM role."
  type        = string
  default     = null
}

variable "path" {
  description = "Path in which to create the IAM role."
  type        = string
  default     = "/"
}

# Trust Policy
variable "trusted_services" {
  description = "AWS services that are allowed to assume the IAM role."
  type        = list(string)
  default     = []
}

variable "trusted_aws_principals" {
  description = "AWS account ARNs that are allowed to assume the IAM role."
  type        = list(string)
  default     = []
}

variable "trusted_federated_principals" {
  description = "Federated identity provider ARNs (OIDC/SAML) allowed to assume the IAM role."
  type        = list(string)
  default     = []
}

# IAM Policy
variable "policy_name" {
  description = "Name of the IAM policy."
  type        = string
  default     = null
}

variable "policy_description" {
  description = "Description of the IAM policy."
  type        = string
  default     = null
}

variable "policy_document" {
  description = "JSON policy document used to create the IAM policy."
  type        = string
  default     = null
}

# Instance Profile
variable "create_instance_profile" {
  description = "Whether to create an IAM Instance Profile."
  type        = bool
  default     = false
}

variable "instance_profile_name" {
  description = "Name of the IAM Instance Profile."
  type        = string
  default     = null
}

# Permission Boundary
variable "create_permission_boundary" {
  description = "Whether to create and attach a permission boundary."
  type        = bool
  default     = false
}

variable "permission_boundary_name" {
  description = "Name of the permission boundary policy."
  type        = string
  default     = null
}

variable "permission_boundary_policy" {
  description = "JSON policy document for the permission boundary."
  type        = string
  default     = null
}

# Tags
variable "tags" {
  description = "Tags applied to all supported IAM resources."
  type        = map(string)
  default     = {}
}

# Managed IAM Policies
variable "managed_policy_arns" {
  description = "List of AWS or customer-managed IAM policy ARNs to attach to the role."
  type        = list(string)
  default     = []
}

# Why these variables?

# This design supports nearly every IAM use case you'll encounter in the CloudHustler Commerce Platform:

# EC2 → IAM Role + Instance Profile
# Lambda → IAM Role + Trust Policy + IAM Policy
# ECS Tasks → IAM Role + Trust Policy
# EKS Pod Identity / IRSA → IAM Role + Federated Trust Policy
# GitHub Actions OIDC → Federated Trust Policy
# Cross-Account Access → AWS Principal Trust
# Enterprise Governance → Permission Boundaries
# Reusable IAM Policies → Standalone managed policies