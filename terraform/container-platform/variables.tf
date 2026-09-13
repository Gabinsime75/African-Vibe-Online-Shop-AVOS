variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "aws_region" {
  description = "AWS region where the EKS cluster is deployed."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

variable "private_app_subnet_ids" {
  description = "Private application subnet IDs from the networking root module."
  type        = list(string)
}

variable "cluster_security_group_ids" {
  description = "Additional security group IDs attached to the EKS cluster."
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

variable "enable_secrets_encryption" {
  description = "Whether to enable KMS encryption for Kubernetes secrets."
  type        = bool
  default     = true
}

variable "create_kms_key" {
  description = "Whether to create a dedicated KMS key for EKS secrets encryption."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Existing KMS key ARN to use when create_kms_key is false."
  type        = string
  default     = null
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
  description = "Optional KMS key ARN for encrypting EKS control plane logs."
  type        = string
  default     = null
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

variable "enable_oidc_provider" {
  description = "Whether to create the EKS IAM OIDC provider."
  type        = bool
  default     = true
}

variable "access_entries" {
  description = "Map of EKS access entries and access policy associations."
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

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "create_ebs_csi_pod_identity" {
  description = "Whether to create Pod Identity resources for the EBS CSI controller."
  type        = bool
  default     = true
}

variable "alb_security_group_id" {
  description = "Security group ID of the public ALB allowed to reach Istio ingress"
  type        = string
}