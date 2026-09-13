# =============================================================================
# CloudHustler Commerce Platform
# Kiali Terraform Module Variables
#
# This file defines all configurable settings for the Kiali deployment.
# =============================================================================

# -----------------------------------------------------------------------------
# Project Configuration
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "cluster_name" {
  description = "Amazon EKS cluster name."
  type        = string
}

# -----------------------------------------------------------------------------
# Namespace Configuration
# -----------------------------------------------------------------------------

variable "namespace" {
  description = "Namespace where Kiali will be deployed."
  type        = string
  default     = "istio-system"
}

variable "create_namespace" {
  description = "Whether Terraform should create the namespace."
  type        = bool
  default     = false
}

variable "namespace_labels" {
  description = "Additional namespace labels."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Helm Configuration
# -----------------------------------------------------------------------------

variable "release_name" {
  description = "Helm release name."
  type        = string
  default     = "kiali"
}

variable "chart_repository" {
  description = "Kiali Helm repository."
  type        = string
  default     = "https://kiali.org/helm-charts"
}

variable "chart_name" {
  description = "Helm chart name."
  type        = string
  default     = "kiali-server"
}

variable "chart_version" {
  description = "Pinned Kiali Helm chart version."
  type        = string
}

variable "timeout" {
  description = "Helm deployment timeout."
  type        = number
  default     = 900
}

variable "atomic" {
  description = "Automatically rollback failed releases."
  type        = bool
  default     = false
}

variable "cleanup_on_fail" {
  description = "Cleanup failed releases."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Authentication
# -----------------------------------------------------------------------------

variable "auth_strategy" {
  description = "Authentication strategy."
  type        = string
  default     = "anonymous"

  validation {
    condition = contains([
      "anonymous",
      "openid"
    ], var.auth_strategy)

    error_message = "Supported authentication strategies are anonymous and openid."
  }
}

# -----------------------------------------------------------------------------
# Deployment Configuration
# -----------------------------------------------------------------------------

variable "instance_name" {
  description = "Kiali instance name."
  type        = string
  default     = "kiali"
}

variable "replica_count" {
  description = "Number of Kiali replicas."
  type        = number
  default     = 1
}

variable "accessible_namespaces" {
  description = "Namespaces monitored by Kiali."
  type        = list(string)
  default = [
    "**"
  ]
}

# -----------------------------------------------------------------------------
# Resources
# -----------------------------------------------------------------------------

variable "cpu_request" {
  description = "Requested CPU."
  type        = string
  default     = "100m"
}

variable "memory_request" {
  description = "Requested memory."
  type        = string
  default     = "128Mi"
}

variable "cpu_limit" {
  description = "CPU limit."
  type        = string
  default     = "500m"
}

variable "memory_limit" {
  description = "Memory limit."
  type        = string
  default     = "512Mi"
}

# -----------------------------------------------------------------------------
# Scheduling
# -----------------------------------------------------------------------------

variable "node_selector" {
  description = "Node selector."
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Pod tolerations."
  type        = list(any)
  default     = []
}

variable "affinity" {
  description = "Pod affinity."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# Istio
# -----------------------------------------------------------------------------

variable "istio_namespace" {
  description = "Istio control plane namespace."
  type        = string
  default     = "istio-system"
}

# -----------------------------------------------------------------------------
# Prometheus
# -----------------------------------------------------------------------------

variable "prometheus_url" {
  description = "Internal Prometheus URL."
  type        = string
}

# -----------------------------------------------------------------------------
# Grafana
# -----------------------------------------------------------------------------

variable "grafana_enabled" {
  description = "Enable Grafana integration."
  type        = bool
  default     = true
}

variable "grafana_in_cluster_url" {
  description = "Internal Grafana URL."
  type        = string
}

variable "grafana_external_url" {
  description = "External Grafana URL."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Distributed Tracing
# -----------------------------------------------------------------------------

variable "tracing_enabled" {
  description = "Enable tracing integration."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Server Configuration
# -----------------------------------------------------------------------------

variable "server_port" {
  description = "Kiali server port."
  type        = number
  default     = 20001
}

variable "web_root" {
  description = "Kiali web root."
  type        = string
  default     = "/"
}

variable "metrics_enabled" {
  description = "Expose Prometheus metrics."
  type        = bool
  default     = true
}

variable "metrics_port" {
  description = "Metrics endpoint port."
  type        = number
  default     = 9090
}

# -----------------------------------------------------------------------------
# Service
# -----------------------------------------------------------------------------

variable "service_type" {
  description = "Kubernetes Service type."
  type        = string
  default     = "ClusterIP"

  validation {
    condition = contains([
      "ClusterIP",
      "NodePort",
      "LoadBalancer"
    ], var.service_type)

    error_message = "Unsupported Kubernetes Service type."
  }
}

variable "service_annotations" {
  description = "Additional Service annotations."
  type        = map(string)
  default     = {}
}