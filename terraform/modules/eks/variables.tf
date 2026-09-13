variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs used by the EKS control plane. Usually private app subnet IDs."
  type        = list(string)
}

variable "cluster_security_group_ids" {
  description = "Additional security group IDs to attach to the EKS cluster."
  type        = list(string)
  default     = []
}

variable "endpoint_private_access" {
  description = "Whether the EKS private API endpoint is enabled."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the EKS public API endpoint is enabled."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to access the public EKS API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types to enable."
  type        = list(string)
  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}

variable "authentication_mode" {
  description = "EKS cluster authentication mode."
  type        = string
  default     = "API"

  validation {
    condition     = contains(["CONFIG_MAP", "API", "API_AND_CONFIG_MAP"], var.authentication_mode)
    error_message = "authentication_mode must be CONFIG_MAP, API, or API_AND_CONFIG_MAP."
  }
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Whether to grant the cluster creator admin permissions."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all EKS resources."
  type        = map(string)
  default     = {}
}

variable "enable_secrets_encryption" {
  description = "Whether to enable envelope encryption for Kubernetes secrets using KMS."
  type        = bool
  default     = true
}

variable "create_kms_key" {
  description = "Whether to create a dedicated KMS key for EKS secrets encryption."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Existing KMS key ARN to use for EKS secrets encryption when create_kms_key is false."
  type        = string
  default     = null
}

variable "kms_deletion_window_in_days" {
  description = "KMS key deletion window in days."
  type        = number
  default     = 30
}

variable "kms_enable_key_rotation" {
  description = "Whether to enable KMS key rotation."
  type        = bool
  default     = true
}

variable "kms_multi_region" {
  description = "Whether the EKS KMS key is multi-region."
  type        = bool
  default     = false
}

variable "node_groups" {
  description = "Map of EKS managed node group configurations."
  type = map(object({
    subnet_ids                = list(string)
    instance_types            = list(string)
    capacity_type             = optional(string, "ON_DEMAND")
    ami_type                  = optional(string, "AL2_x86_64")
    disk_size                 = optional(number, 50)
    desired_size              = number
    min_size                  = number
    max_size                  = number
    max_unavailable           = optional(number, 1)
    kubernetes_version        = optional(string)
    release_version           = optional(string)
    ec2_ssh_key               = optional(string)
    source_security_group_ids = optional(list(string), [])
    labels                    = optional(map(string), {})
    tags                      = optional(map(string), {})
  }))

  default = {}
}

###############################################################
# AWS Managed Add-ons
###############################################################

variable "enable_vpc_cni" {
  type    = bool
  default = true
}

variable "enable_coredns" {
  type    = bool
  default = true
}

variable "enable_kube_proxy" {
  type    = bool
  default = true
}

variable "enable_ebs_csi_driver" {
  type    = bool
  default = true
}

variable "enable_pod_identity_agent" {
  type    = bool
  default = true
}

variable "vpc_cni_version" {
  type    = string
  default = null
}

variable "coredns_version" {
  type    = string
  default = null
}

variable "kube_proxy_version" {
  type    = string
  default = null
}

variable "ebs_csi_driver_version" {
  type    = string
  default = null
}

variable "pod_identity_agent_version" {
  type    = string
  default = null
}

# variable "ebs_csi_role_arn" {
#   type    = string
#   default = null
# }

variable "access_entries" {
  description = "Map of EKS access entries and optional access policy associations."
  type = map(object({
    principal_arn     = string
    kubernetes_groups = optional(list(string))
    type              = optional(string, "STANDARD")

    policy_associations = optional(map(object({
      policy_arn = string
      access_scope = object({
        type       = string
        namespaces = optional(list(string))
      })
    })), {})
  }))

  default = {}
}

variable "enable_oidc_provider" {
  description = "Whether to create an IAM OIDC provider for the EKS cluster."
  type        = bool
  default     = true
}

variable "create_cloudwatch_log_group" {
  description = "Whether to create the EKS control plane CloudWatch Log Group."
  type        = bool
  default     = true
}

variable "cloudwatch_log_retention_in_days" {
  description = "Number of days to retain EKS control plane logs."
  type        = number
  default     = 90
}

variable "cloudwatch_log_kms_key_id" {
  description = "Optional KMS key ARN for encrypting EKS control plane CloudWatch logs."
  type        = string
  default     = null
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-2"
}

variable "create_ebs_csi_pod_identity" {
  description = "Whether to create an EKS Pod Identity IAM role and association for the EBS CSI controller."
  type        = bool
  default     = true
}