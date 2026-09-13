###############################################################
# Cluster Configuration
###############################################################

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string

  validation {
    condition     = length(trimspace(var.cluster_name)) > 0
    error_message = "cluster_name cannot be empty."
  }
}

variable "aws_region" {
  description = "AWS region containing the EKS cluster and target groups."
  type        = string

  validation {
    condition     = length(trimspace(var.aws_region)) > 0
    error_message = "aws_region cannot be empty."
  }
}

variable "vpc_id" {
  description = "VPC ID containing the EKS cluster and existing target groups."
  type        = string

  validation {
    condition     = can(regex("^vpc-[0-9a-f]+$", var.vpc_id))
    error_message = "vpc_id must be a valid AWS VPC ID."
  }
}

variable "target_group_arns" {
  description = "Target-group ARNs that the controller may manage through TargetGroupBinding."
  type        = list(string)

  validation {
    condition = (
      length(var.target_group_arns) > 0 &&
      alltrue([
        for arn in var.target_group_arns :
        can(regex(
          "^arn:[^:]+:elasticloadbalancing:[^:]+:[0-9]{12}:targetgroup/.+$",
          arn
        ))
      ])
    )

    error_message = "target_group_arns must contain at least one valid target-group ARN."
  }
}

###############################################################
# IAM Configuration
###############################################################

variable "create_iam_policy" {
  description = "Whether to create the TargetGroupBinding IAM policy."
  type        = bool
  default     = true
}

variable "iam_policy_name" {
  description = "Name of the IAM policy used by the controller."
  type        = string
  default     = "AWSLoadBalancerControllerTargetGroupBindingPolicy"
}

variable "existing_iam_policy_arn" {
  description = "Existing IAM policy ARN used when create_iam_policy is false."
  type        = string
  default     = null

  validation {
    condition = (
      var.create_iam_policy ||
      var.existing_iam_policy_arn != null
    )

    error_message = "existing_iam_policy_arn is required when create_iam_policy is false."
  }
}

variable "create_pod_identity_role" {
  description = "Whether to create an IAM role for EKS Pod Identity."
  type        = bool
  default     = true
}

variable "iam_role_name" {
  description = "Name of the AWS Load Balancer Controller Pod Identity IAM role."
  type        = string
}

variable "existing_pod_identity_role_arn" {
  description = "Existing Pod Identity IAM role ARN when create_pod_identity_role is false."
  type        = string
  default     = null

  validation {
    condition = (
      var.create_pod_identity_role ||
      var.existing_pod_identity_role_arn != null
    )

    error_message = "existing_pod_identity_role_arn is required when create_pod_identity_role is false."
  }
}

variable "create_pod_identity_association" {
  description = "Whether to create an EKS Pod Identity association."
  type        = bool
  default     = true
}

variable "iam_path" {
  description = "IAM path used for the policy and role."
  type        = string
  default     = "/"
}

###############################################################
# Kubernetes and Helm Configuration
###############################################################

variable "namespace" {
  description = "Kubernetes namespace for the controller."
  type        = string
  default     = "kube-system"
}

variable "service_account_name" {
  description = "Kubernetes service account used by the controller."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "create_service_account" {
  description = "Whether the Helm chart creates the Kubernetes service account."
  type        = bool
  default     = true
}

variable "release_name" {
  description = "Helm release name."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "chart_repository" {
  description = "AWS EKS Helm chart repository."
  type        = string
  default     = "https://aws.github.io/eks-charts"
}

variable "chart_name" {
  description = "AWS Load Balancer Controller Helm chart name."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "chart_version" {
  description = "Optional pinned Helm chart version. Null installs the latest version available from the repository."
  type        = string
  default     = null
}

variable "replica_count" {
  description = "Number of AWS Load Balancer Controller replicas."
  type        = number
  default     = 2

  validation {
    condition     = var.replica_count >= 2
    error_message = "replica_count must be at least 2 for high availability."
  }
}

variable "enable_service_mutator_webhook" {
  description = "Whether the controller mutates LoadBalancer Services. Disable when using only TargetGroupBinding."
  type        = bool
  default     = false
}

variable "create_namespace" {
  description = "Whether Helm creates the Kubernetes namespace."
  type        = bool
  default     = false
}

variable "atomic" {
  description = "Whether a failed Helm installation is automatically rolled back."
  type        = bool
  default     = true
}

variable "cleanup_on_fail" {
  description = "Whether Helm deletes newly created resources after a failed upgrade."
  type        = bool
  default     = true
}

variable "wait" {
  description = "Whether Terraform waits for Helm resources to become ready."
  type        = bool
  default     = true
}

variable "helm_timeout" {
  description = "Helm installation timeout in seconds."
  type        = number
  default     = 600
}

variable "additional_set_values" {
  description = "Additional Helm values supplied with set blocks."
  type        = map(string)
  default     = {}
}

variable "values" {
  description = "Additional raw YAML values passed to the Helm chart."
  type        = list(string)
  default     = []
}

###############################################################
# Tags
###############################################################

variable "tags" {
  description = "Tags applied to AWS resources."
  type        = map(string)
  default     = {}
}