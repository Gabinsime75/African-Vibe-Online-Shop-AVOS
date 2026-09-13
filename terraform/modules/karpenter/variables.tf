# =============================================================================
# CloudHustler Commerce Platform
# Karpenter Module Variables
# =============================================================================
# Defines the configuration inputs required to deploy Karpenter, create its AWS
# permissions, configure interruption handling, and install the Helm release.
# =============================================================================

# -----------------------------------------------------------------------------
# General Configuration
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region where the EKS cluster is deployed."
  type        = string
}

variable "name_prefix" {
  description = "Naming prefix applied to Karpenter AWS resources."
  type        = string
}

variable "tags" {
  description = "Common tags applied to Karpenter-managed AWS resources."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# EKS Cluster Configuration
# -----------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster where Karpenter is deployed."
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS Kubernetes API server endpoint."
  type        = string
}

# -----------------------------------------------------------------------------
# Kubernetes Configuration
# -----------------------------------------------------------------------------

variable "namespace" {
  description = "Kubernetes namespace where Karpenter is installed."
  type        = string
  default     = "kube-system"
}

variable "service_account_name" {
  description = "Kubernetes service account used by Karpenter."
  type        = string
  default     = "karpenter"
}

# -----------------------------------------------------------------------------
# Helm Configuration
# -----------------------------------------------------------------------------

variable "chart_version" {
  description = "Pinned version of the Karpenter Helm chart."
  type        = string
}

variable "controller_replicas" {
  description = "Number of Karpenter controller replicas."
  type        = number
  default     = 2

  validation {
    condition     = var.controller_replicas >= 1
    error_message = "Karpenter must have at least one controller replica."
  }
}

variable "controller_cpu_request" {
  description = "CPU request for each Karpenter controller pod."
  type        = string
  default     = "500m"
}

variable "controller_memory_request" {
  description = "Memory request for each Karpenter controller pod."
  type        = string
  default     = "512Mi"
}

variable "controller_cpu_limit" {
  description = "CPU limit for each Karpenter controller pod."
  type        = string
  default     = "1"
}

variable "controller_memory_limit" {
  description = "Memory limit for each Karpenter controller pod."
  type        = string
  default     = "1Gi"
}

# -----------------------------------------------------------------------------
# IAM Configuration
# -----------------------------------------------------------------------------

variable "controller_iam_role_name" {
  description = "Name assigned to the Karpenter controller IAM role."
  type        = string
  default     = null
}

variable "node_iam_role_name" {
  description = "Name assigned to the Karpenter-managed EC2 node IAM role."
  type        = string
  default     = null
}

variable "node_iam_role_additional_policies" {
  description = "Additional IAM policies attached to the Karpenter node role."
  type        = map(string)

  default = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

# -----------------------------------------------------------------------------
# Interruption Handling
# -----------------------------------------------------------------------------

variable "enable_interruption_handling" {
  description = "Whether to create the SQS queue and EventBridge interruption rules."
  type        = bool
  default     = true
}

variable "interruption_queue_name" {
  description = "Optional explicit name for the Karpenter interruption queue."
  type        = string
  default     = null
}