# =============================================================================
# AVOS Container Platform — Input Variables
#
# Defines the configurable inputs for the EKS control plane, API access,
# managed add-ons, system node group, encryption, and remote-state lookup.
# =============================================================================

variable "aws_region" {
  description = "AWS Region where the AVOS EKS platform is deployed."
  type        = string
  default     = "us-east-2"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS Region name."
  }
}

variable "project" {
  description = "Project identifier used in names and tags."
  type        = string
  default     = "avos"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.project))
    error_message = "project must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "owner" {
  description = "Team responsible for the EKS container platform."
  type        = string
  default     = "PlatformEngineering"
}

variable "kubernetes_version" {
  description = "Kubernetes minor version used by the EKS cluster."
  type        = string
  default     = "1.35"

  validation {
    condition     = can(regex("^1\\.[0-9]+$", var.kubernetes_version))
    error_message = "kubernetes_version must use the major.minor format, such as 1.35."
  }
}

variable "network_state_bucket" {
  description = "S3 bucket containing the AVOS Terraform remote states."
  type        = string
}

variable "network_state_key" {
  description = "S3 object key containing the AVOS networking Terraform state."
  type        = string
  default     = "network/terraform.tfstate"
}

variable "terraform_state_kms_key_arn" {
  description = "ARN of the KMS key encrypting AVOS Terraform state."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/.+$", var.terraform_state_kms_key_arn))
    error_message = "terraform_state_kms_key_arn must be a valid AWS KMS key ARN."
  }
}

variable "administrator_role_arn" {
  description = "Permanent IAM role ARN granted EKS cluster-administrator access."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.administrator_role_arn))
    error_message = "administrator_role_arn must be a valid IAM role ARN, not an STS assumed-role ARN."
  }
}

variable "cluster_endpoint_private_access" {
  description = "Whether the EKS Kubernetes API has a private VPC endpoint."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS Kubernetes API has a public endpoint."
  type        = bool
  default     = true
}

variable "cluster_public_access_cidrs" {
  description = "IPv4 CIDR blocks allowed to reach the public EKS API endpoint."
  type        = list(string)

  validation {
    condition = (
      length(var.cluster_public_access_cidrs) > 0 &&
      alltrue([
        for cidr in var.cluster_public_access_cidrs :
        can(cidrnetmask(cidr)) && cidr != "0.0.0.0/0"
      ])
    )
    error_message = "cluster_public_access_cidrs must contain valid restricted IPv4 CIDRs and must not include 0.0.0.0/0."
  }
}

variable "cluster_log_types" {
  description = "EKS control-plane log types sent to CloudWatch Logs."
  type        = set(string)

  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  validation {
    condition = alltrue([
      for log_type in var.cluster_log_types :
      contains(
        [
          "api",
          "audit",
          "authenticator",
          "controllerManager",
          "scheduler"
        ],
        log_type
      )
    ])
    error_message = "cluster_log_types contains an unsupported EKS control-plane log type."
  }
}

variable "cluster_log_retention_days" {
  description = "CloudWatch retention period for EKS control-plane logs."
  type        = number
  default     = 30

  validation {
    condition = contains(
      [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365],
      var.cluster_log_retention_days
    )
    error_message = "cluster_log_retention_days must be a supported CloudWatch Logs retention value."
  }
}

variable "cluster_deletion_protection" {
  description = "Whether EKS deletion protection is enabled."
  type        = bool
  default     = true
}

variable "kms_deletion_window_days" {
  description = "Waiting period before deletion of the EKS KMS key."
  type        = number
  default     = 30

  validation {
    condition = (
      var.kms_deletion_window_days >= 7 &&
      var.kms_deletion_window_days <= 30
    )
    error_message = "kms_deletion_window_days must be between 7 and 30."
  }
}

variable "kms_rotation_period_days" {
  description = "Automatic rotation period for the EKS KMS key."
  type        = number
  default     = 365

  validation {
    condition = (
      var.kms_rotation_period_days >= 90 &&
      var.kms_rotation_period_days <= 2560
    )
    error_message = "kms_rotation_period_days must be between 90 and 2560."
  }
}

variable "addon_versions" {
  description = "Explicit EKS managed add-on versions compatible with the selected Kubernetes version."
  type        = map(string)

  validation {
    condition = alltrue([
      for required_addon in [
        "vpc-cni",
        "coredns",
        "kube-proxy",
        "eks-pod-identity-agent",
        "aws-ebs-csi-driver"
      ] :
      contains(keys(var.addon_versions), required_addon)
    ])
    error_message = "addon_versions must include all five required AVOS EKS managed add-ons."
  }
}

variable "system_node_instance_types" {
  description = "EC2 instance types available to the stable EKS system node group."
  type        = list(string)
  default     = ["t3.large"]

  validation {
    condition     = length(var.system_node_instance_types) > 0
    error_message = "system_node_instance_types must contain at least one instance type."
  }
}

variable "system_node_capacity_type" {
  description = "Capacity type for the stable EKS system node group."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.system_node_capacity_type)
    error_message = "system_node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "system_node_ami_type" {
  description = "AMI family used by the EKS system managed node group."
  type        = string
  default     = "AL2023_x86_64_STANDARD"

  validation {
    condition = contains(
      [
        "AL2023_x86_64_STANDARD",
        "AL2023_ARM_64_STANDARD"
      ],
      var.system_node_ami_type
    )
    error_message = "system_node_ami_type must be an approved Amazon Linux 2023 EKS AMI type."
  }
}

variable "system_node_min_size" {
  description = "Minimum size of the stable EKS system node group."
  type        = number
  default     = 2

  validation {
    condition     = var.system_node_min_size >= 1
    error_message = "system_node_min_size must be at least 1."
  }
}

variable "system_node_desired_size" {
  description = "Initial desired size of the stable EKS system node group."
  type        = number
  default     = 2

  validation {
    condition     = var.system_node_desired_size >= 1
    error_message = "system_node_desired_size must be at least 1."
  }
}

variable "system_node_max_size" {
  description = "Maximum size of the stable EKS system node group."
  type        = number
  default     = 4

  validation {
    condition     = var.system_node_max_size >= 1
    error_message = "system_node_max_size must be at least 1."
  }
}

variable "system_node_disk_size_gib" {
  description = "Root EBS volume size for each managed system node."
  type        = number
  default     = 50

  validation {
    condition = (
      var.system_node_disk_size_gib >= 20 &&
      var.system_node_disk_size_gib <= 1024
    )
    error_message = "system_node_disk_size_gib must be between 20 and 1024 GiB."
  }
}

variable "additional_tags" {
  description = "Additional tags merged with the mandatory AVOS tags."
  type        = map(string)
  default     = {}
}

variable "karpenter_version" {
  description = "Pinned Karpenter Helm chart and application version."
  type        = string
  default     = "1.14.1"
}