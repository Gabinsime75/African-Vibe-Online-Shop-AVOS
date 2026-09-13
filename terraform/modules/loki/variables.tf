# =============================================================================
# CloudHustler Commerce Platform
# Loki Terraform Module Variables
#
# This file defines all configurable settings used to deploy Grafana Loki.
# These variables control Helm, storage, resource allocation, monitoring,
# retention, and deployment behavior.
# =============================================================================

# -----------------------------------------------------------------------------
# Project Configuration
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "CloudHustler project name."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

# -----------------------------------------------------------------------------
# Namespace Configuration
# -----------------------------------------------------------------------------

variable "namespace" {
  description = "Namespace where Loki will be deployed."
  type        = string
  default     = "logging"
}

variable "create_namespace" {
  description = "Whether Terraform should create the namespace."
  type        = bool
  default     = false
}

variable "namespace_labels" {
  description = "Additional labels applied to the namespace."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Helm Configuration
# -----------------------------------------------------------------------------

variable "release_name" {
  description = "Loki Helm release name."
  type        = string
  default     = "loki"
}

variable "chart_repository" {
  description = "Grafana Helm repository."
  type        = string
  default     = "https://grafana.github.io/helm-charts"
}

variable "chart_name" {
  description = "Helm chart name."
  type        = string
  default     = "loki"
}

variable "chart_version" {
  description = "Pinned Loki Helm chart version."
  type        = string
}

variable "timeout" {
  description = "Helm deployment timeout."
  type        = number
  default     = 1200
}

variable "atomic" {
  description = "Automatically rollback failed Helm releases."
  type        = bool
  default     = false
}

variable "cleanup_on_fail" {
  description = "Cleanup resources after failed deployment."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Storage Configuration
# -----------------------------------------------------------------------------

variable "storage_class_name" {
  description = "Persistent volume StorageClass."
  type        = string
  default     = "gp3"
}

variable "storage_size" {
  description = "Persistent volume size."
  type        = string
  default     = "20Gi"
}

variable "retention_period" {
  description = "Log retention period."
  type        = string
  default     = "168h"
}

variable "schema_start_date" {
  description = "Loki schema start date."
  type        = string
  default     = "2024-01-01"
}

# -----------------------------------------------------------------------------
# Loki Limits
# -----------------------------------------------------------------------------

variable "ingestion_rate_mb" {
  description = "Maximum sustained ingestion rate."
  type        = number
  default     = 4
}

variable "ingestion_burst_size_mb" {
  description = "Maximum ingestion burst."
  type        = number
  default     = 8
}

variable "max_query_parallelism" {
  description = "Maximum query parallelism."
  type        = number
  default     = 16
}

variable "max_query_series" {
  description = "Maximum returned query series."
  type        = number
  default     = 500
}

variable "reject_old_samples_max_age" {
  description = "Maximum accepted age of log entries."
  type        = string
  default     = "168h"
}

variable "per_stream_rate_limit" {
  description = "Per-stream ingestion limit."
  type        = string
  default     = "5MB"
}

variable "per_stream_rate_limit_burst" {
  description = "Per-stream ingestion burst."
  type        = string
  default     = "15MB"
}

variable "compaction_interval" {
  description = "Compactor execution interval."
  type        = string
  default     = "10m"
}

variable "retention_delete_delay" {
  description = "Retention deletion delay."
  type        = string
  default     = "2h"
}

# -----------------------------------------------------------------------------
# Replica Configuration
# -----------------------------------------------------------------------------

variable "replica_count" {
  description = "Number of Loki replicas."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Resource Configuration
# -----------------------------------------------------------------------------

variable "cpu_request" {
  description = "Requested CPU."
  type        = string
  default     = "200m"
}

variable "memory_request" {
  description = "Requested memory."
  type        = string
  default     = "512Mi"
}

variable "cpu_limit" {
  description = "CPU limit."
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "Memory limit."
  type        = string
  default     = "2Gi"
}

# -----------------------------------------------------------------------------
# Gateway Resources
# -----------------------------------------------------------------------------

variable "gateway_cpu_request" {
  type    = string
  default = "50m"
}

variable "gateway_memory_request" {
  type    = string
  default = "64Mi"
}

variable "gateway_cpu_limit" {
  type    = string
  default = "250m"
}

variable "gateway_memory_limit" {
  type    = string
  default = "256Mi"
}

# -----------------------------------------------------------------------------
# Canary Resources
# -----------------------------------------------------------------------------

variable "canary_cpu_request" {
  type    = string
  default = "25m"
}

variable "canary_memory_request" {
  type    = string
  default = "64Mi"
}

variable "canary_cpu_limit" {
  type    = string
  default = "200m"
}

variable "canary_memory_limit" {
  type    = string
  default = "128Mi"
}

# -----------------------------------------------------------------------------
# Scheduling Configuration
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
# Monitoring
# -----------------------------------------------------------------------------

variable "service_monitor_enabled" {
  description = "Enable ServiceMonitor."
  type        = bool
  default     = true
}

variable "service_monitor_interval" {
  description = "Prometheus scrape interval."
  type        = string
  default     = "30s"
}

variable "prometheus_release_name" {
  description = "Prometheus release label."
  type        = string
  default     = "prometheus"
}

variable "loki_canary_enabled" {
  description = "Deploy Loki Canary."
  type        = bool
  default     = true
}