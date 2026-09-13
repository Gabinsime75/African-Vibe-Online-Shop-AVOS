# =============================================================================
# Fluent Bit Module Variables
# =============================================================================

variable "namespace" {
  description = "Kubernetes namespace for Fluent Bit."
  type        = string
  default     = "logging"
}

variable "create_namespace" {
  description = "Whether to create the Fluent Bit namespace."
  type        = bool
  default     = true
}

variable "release_name" {
  description = "Fluent Bit Helm release name."
  type        = string
  default     = "fluent-bit"
}

variable "chart_version" {
  description = "Fluent Bit Helm chart version."
  type        = string
  default     = "0.57.9"
}

variable "log_level" {
  description = "Fluent Bit internal log level."
  type        = string
  default     = "info"
}

variable "service_monitor_enabled" {
  description = "Enable the Fluent Bit ServiceMonitor."
  type        = bool
  default     = true
}

variable "monitoring_namespace" {
  description = "Namespace containing Prometheus."
  type        = string
  default     = "monitoring"
}

variable "scrape_interval" {
  description = "Prometheus scrape interval."
  type        = string
  default     = "30s"
}

variable "cpu_request" {
  type    = string
  default = "50m"
}

variable "memory_request" {
  type    = string
  default = "64Mi"
}

variable "cpu_limit" {
  type    = string
  default = "200m"
}

variable "memory_limit" {
  type    = string
  default = "256Mi"
}

variable "timeout" {
  type    = number
  default = 600
}

variable "atomic" {
  type    = bool
  default = true
}