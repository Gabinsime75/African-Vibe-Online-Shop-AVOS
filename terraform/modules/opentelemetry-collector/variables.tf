# =============================================================================
# CloudHustler Commerce Platform
# OpenTelemetry Collector Module Variables
#
# This file defines all configurable settings used to deploy the OpenTelemetry
# Collector and optionally integrate it with AWS X-Ray through EKS Pod Identity.
# =============================================================================

# -----------------------------------------------------------------------------
# Project Configuration
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Name of the CloudHustler Commerce Platform project."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "cluster_name" {
  description = "Name of the Amazon EKS cluster."
  type        = string
}

variable "aws_region" {
  description = "AWS Region used by the OpenTelemetry Collector."
  type        = string
}

# -----------------------------------------------------------------------------
# Namespace Configuration
# -----------------------------------------------------------------------------

variable "namespace" {
  description = "Kubernetes namespace where the OpenTelemetry Collector is deployed."
  type        = string
  default     = "observability"
}

variable "create_namespace" {
  description = "Whether Terraform should create the Collector namespace."
  type        = bool
  default     = true
}

variable "namespace_labels" {
  description = "Additional labels applied to the Collector namespace."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Helm Configuration
# -----------------------------------------------------------------------------

variable "release_name" {
  description = "OpenTelemetry Collector Helm release name."
  type        = string
  default     = "opentelemetry-collector"
}

variable "chart_repository" {
  description = "Official OpenTelemetry Helm chart repository."
  type        = string
  default     = "https://open-telemetry.github.io/opentelemetry-helm-charts"
}

variable "chart_name" {
  description = "OpenTelemetry Collector Helm chart name."
  type        = string
  default     = "opentelemetry-collector"
}

variable "chart_version" {
  description = "Pinned OpenTelemetry Collector Helm chart version."
  type        = string
}

variable "timeout" {
  description = "Maximum time in seconds allowed for the Helm deployment."
  type        = number
  default     = 900
}

variable "atomic" {
  description = "Whether Helm should roll back the release automatically when deployment fails."
  type        = bool
  default     = false
}

variable "cleanup_on_fail" {
  description = "Whether Helm should remove newly created resources after a failed deployment."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Collector Image Configuration
# -----------------------------------------------------------------------------

variable "image_repository" {
  description = "OpenTelemetry Collector container image repository."
  type        = string
  default     = "otel/opentelemetry-collector-contrib"
}

variable "image_tag" {
  description = "Pinned OpenTelemetry Collector image tag."
  type        = string
}

variable "image_pull_policy" {
  description = "Kubernetes image pull policy."
  type        = string
  default     = "IfNotPresent"

  validation {
    condition = contains(
      [
        "Always",
        "IfNotPresent",
        "Never"
      ],
      var.image_pull_policy
    )

    error_message = "image_pull_policy must be Always, IfNotPresent, or Never."
  }
}

# -----------------------------------------------------------------------------
# Deployment Configuration
# -----------------------------------------------------------------------------

variable "replica_count" {
  description = "Number of OpenTelemetry Collector replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.replica_count >= 1
    error_message = "replica_count must be at least 1."
  }
}

variable "service_account_name" {
  description = "Kubernetes service account used by the Collector."
  type        = string
  default     = "opentelemetry-collector"
}

variable "service_account_annotations" {
  description = "Additional annotations applied to the Collector service account."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# OTLP Receiver Ports
# -----------------------------------------------------------------------------

variable "otlp_grpc_port" {
  description = "Port used to receive OTLP telemetry over gRPC."
  type        = number
  default     = 4317
}

variable "otlp_http_port" {
  description = "Port used to receive OTLP telemetry over HTTP."
  type        = number
  default     = 4318
}

# -----------------------------------------------------------------------------
# Collector Operational Ports
# -----------------------------------------------------------------------------

variable "prometheus_exporter_port" {
  description = "Port used to expose application metrics received through OTLP."
  type        = number
  default     = 8889
}

variable "internal_metrics_port" {
  description = "Port used to expose the Collector's internal operational metrics."
  type        = number
  default     = 8888
}

variable "health_check_port" {
  description = "Port used by the Collector health-check extension."
  type        = number
  default     = 13133
}

variable "zpages_enabled" {
  description = "Whether the Collector zPages diagnostic extension is exposed."
  type        = bool
  default     = true
}

variable "zpages_port" {
  description = "Port used by the Collector zPages diagnostic extension."
  type        = number
  default     = 55679
}

# -----------------------------------------------------------------------------
# Processor Configuration
# -----------------------------------------------------------------------------

variable "memory_limiter_check_interval" {
  description = "Interval at which the memory limiter checks Collector memory consumption."
  type        = string
  default     = "5s"
}

variable "memory_limiter_limit_percentage" {
  description = "Maximum percentage of available memory the Collector may use."
  type        = number
  default     = 80

  validation {
    condition = (
      var.memory_limiter_limit_percentage > 0 &&
      var.memory_limiter_limit_percentage <= 100
    )

    error_message = "memory_limiter_limit_percentage must be between 1 and 100."
  }
}

variable "memory_limiter_spike_limit_percentage" {
  description = "Percentage of memory reserved for temporary usage spikes."
  type        = number
  default     = 25

  validation {
    condition = (
      var.memory_limiter_spike_limit_percentage >= 0 &&
      var.memory_limiter_spike_limit_percentage <= 100
    )

    error_message = "memory_limiter_spike_limit_percentage must be between 0 and 100."
  }
}

variable "batch_timeout" {
  description = "Maximum amount of time telemetry remains in a batch before export."
  type        = string
  default     = "5s"
}

variable "batch_send_size" {
  description = "Preferred number of telemetry items sent in each batch."
  type        = number
  default     = 512
}

variable "batch_max_size" {
  description = "Maximum number of telemetry items allowed in a batch."
  type        = number
  default     = 1024
}

# -----------------------------------------------------------------------------
# Prometheus Export Configuration
# -----------------------------------------------------------------------------

variable "prometheus_namespace" {
  description = "Metric prefix applied by the Collector Prometheus exporter."
  type        = string
  default     = "cloudhusller"
}

variable "prometheus_scrape_enabled" {
  description = "Whether Prometheus pod-scrape annotations are enabled."
  type        = bool
  default     = true
}

variable "service_monitor_enabled" {
  description = "Whether the Helm chart creates a Prometheus ServiceMonitor."
  type        = bool
  default     = true
}

variable "service_monitor_interval" {
  description = "Prometheus scrape interval for Collector operational metrics."
  type        = string
  default     = "30s"
}

variable "prometheus_release_name" {
  description = "Prometheus Helm release label used to discover the ServiceMonitor."
  type        = string
  default     = "kube-prometheus-stack"
}

# -----------------------------------------------------------------------------
# AWS X-Ray Integration
# -----------------------------------------------------------------------------

variable "aws_xray_enabled" {
  description = "Whether traces are exported to AWS X-Ray."
  type        = bool
  default     = false
}

variable "aws_xray_indexed_attributes" {
  description = "Trace attributes indexed as AWS X-Ray annotations."
  type        = list(string)

  default = [
    "service.name",
    "service.namespace",
    "deployment.environment.name",
    "k8s.namespace.name",
    "k8s.pod.name"
  ]
}

variable "debug_exporter_verbosity" {
  description = "Verbosity used by the debug trace exporter when AWS X-Ray is disabled."
  type        = string
  default     = "basic"

  validation {
    condition = contains(
      [
        "basic",
        "normal",
        "detailed"
      ],
      var.debug_exporter_verbosity
    )

    error_message = "debug_exporter_verbosity must be basic, normal, or detailed."
  }
}

# -----------------------------------------------------------------------------
# IAM Configuration
# -----------------------------------------------------------------------------

variable "iam_role_name" {
  description = "IAM role name used by the Collector for AWS X-Ray export."
  type        = string
}

variable "iam_policy_name" {
  description = "IAM policy name used by the Collector for AWS X-Ray export."
  type        = string
}

variable "permissions_boundary_arn" {
  description = "Optional IAM permissions boundary applied to the Collector role."
  type        = string
  default     = null
}

variable "iam_tags" {
  description = "Additional tags applied to OpenTelemetry IAM resources."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Collector Logging
# -----------------------------------------------------------------------------

variable "collector_log_level" {
  description = "OpenTelemetry Collector internal log level."
  type        = string
  default     = "info"

  validation {
    condition = contains(
      [
        "debug",
        "info",
        "warn",
        "error"
      ],
      var.collector_log_level
    )

    error_message = "collector_log_level must be debug, info, warn, or error."
  }
}

# -----------------------------------------------------------------------------
# Kubernetes Service Configuration
# -----------------------------------------------------------------------------

variable "service_type" {
  description = "Kubernetes Service type used by the Collector."
  type        = string
  default     = "ClusterIP"

  validation {
    condition = contains(
      [
        "ClusterIP",
        "NodePort",
        "LoadBalancer"
      ],
      var.service_type
    )

    error_message = "service_type must be ClusterIP, NodePort, or LoadBalancer."
  }
}

# -----------------------------------------------------------------------------
# Resource Configuration
# -----------------------------------------------------------------------------

variable "cpu_request" {
  description = "CPU requested by each Collector pod."
  type        = string
  default     = "100m"
}

variable "memory_request" {
  description = "Memory requested by each Collector pod."
  type        = string
  default     = "256Mi"
}

variable "cpu_limit" {
  description = "Maximum CPU available to each Collector pod."
  type        = string
  default     = "500m"
}

variable "memory_limit" {
  description = "Maximum memory available to each Collector pod."
  type        = string
  default     = "512Mi"
}

# -----------------------------------------------------------------------------
# Horizontal Pod Autoscaling
# -----------------------------------------------------------------------------

variable "autoscaling_enabled" {
  description = "Whether Horizontal Pod Autoscaling is enabled."
  type        = bool
  default     = false
}

variable "autoscaling_min_replicas" {
  description = "Minimum Collector replicas when autoscaling is enabled."
  type        = number
  default     = 1
}

variable "autoscaling_max_replicas" {
  description = "Maximum Collector replicas when autoscaling is enabled."
  type        = number
  default     = 3
}

variable "autoscaling_cpu_target" {
  description = "Target average CPU utilization percentage for autoscaling."
  type        = number
  default     = 70
}

# -----------------------------------------------------------------------------
# Kubernetes Scheduling
# -----------------------------------------------------------------------------

variable "node_selector" {
  description = "Node labels used to control Collector pod placement."
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Kubernetes tolerations assigned to Collector pods."
  type        = list(any)
  default     = []
}

variable "affinity" {
  description = "Kubernetes affinity configuration assigned to Collector pods."
  type        = any
  default     = {}
}