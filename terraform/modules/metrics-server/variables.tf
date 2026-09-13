###############################################################
# Helm Chart Configuration
###############################################################

variable "release_name" {
  description = "Helm release name for Metrics Server."
  type        = string
  default     = "metrics-server"
}

variable "namespace" {
  description = "Kubernetes namespace for Metrics Server."
  type        = string
  default     = "kube-system"
}

variable "chart_repository" {
  description = "Official Metrics Server Helm repository."
  type        = string
  default     = "https://kubernetes-sigs.github.io/metrics-server/"
}

variable "chart_name" {
  description = "Metrics Server Helm chart name."
  type        = string
  default     = "metrics-server"
}

variable "chart_version" {
  description = "Pinned Metrics Server Helm chart version."
  type        = string
  default     = "3.13.1"
}

###############################################################
# Deployment Configuration
###############################################################

variable "replica_count" {
  description = "Number of Metrics Server replicas."
  type        = number
  default     = 2

  validation {
    condition     = var.replica_count >= 2
    error_message = "replica_count must be at least 2 for high availability."
  }
}

variable "create_api_service" {
  description = "Whether the chart creates the metrics.k8s.io APIService."
  type        = bool
  default     = true
}

variable "create_rbac" {
  description = "Whether the chart creates Metrics Server RBAC resources."
  type        = bool
  default     = true
}

variable "create_service_account" {
  description = "Whether the chart creates the Metrics Server service account."
  type        = bool
  default     = true
}

variable "service_account_name" {
  description = "Kubernetes service account used by Metrics Server."
  type        = string
  default     = "metrics-server"
}

variable "enable_metrics_endpoint" {
  description = "Whether to expose the Metrics Server metrics endpoint."
  type        = bool
  default     = false
}

###############################################################
# Helm Behavior
###############################################################

variable "create_namespace" {
  description = "Whether Helm creates the namespace."
  type        = bool
  default     = false
}

variable "atomic" {
  description = "Whether Helm rolls back a failed installation."
  type        = bool
  default     = true
}

variable "cleanup_on_fail" {
  description = "Whether Helm removes resources created by a failed upgrade."
  type        = bool
  default     = true
}

variable "wait" {
  description = "Whether Terraform waits for Metrics Server to become ready."
  type        = bool
  default     = true
}

variable "helm_timeout" {
  description = "Helm timeout in seconds."
  type        = number
  default     = 600
}

variable "additional_set_values" {
  description = "Additional Metrics Server Helm set values."
  type        = map(string)
  default     = {}
}

variable "values" {
  description = "Additional raw YAML values passed to the chart."
  type        = list(string)
  default     = []
}