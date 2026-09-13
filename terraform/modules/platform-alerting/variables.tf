# =============================================================================
# CloudHustler Commerce Platform
# Platform Alerting Module Variables
#
# This file defines the configurable settings used by the platform-alerting
# module. These variables control the PrometheusRule namespace, resource
# metadata, rule enablement, and alert thresholds for Kubernetes, Prometheus,
# Loki, OpenTelemetry, Istio, and application workloads.
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

# -----------------------------------------------------------------------------
# PrometheusRule Namespace
# -----------------------------------------------------------------------------

variable "namespace" {
  description = "Namespace where custom PrometheusRule resources are created."
  type        = string
  default     = "monitoring"
}

# -----------------------------------------------------------------------------
# Prometheus Operator Discovery
# -----------------------------------------------------------------------------

variable "prometheus_rule_label" {
  description = "Label key used by the Prometheus Operator to discover custom PrometheusRule resources."
  type        = string
  default     = "release"
}

variable "prometheus_rule_label_value" {
  description = "Label value used by the Prometheus Operator to discover custom PrometheusRule resources."
  type        = string
  default     = "kube-prometheus-stack"
}

# -----------------------------------------------------------------------------
# Rule Group Enablement
# -----------------------------------------------------------------------------

variable "kubernetes_alerts_enabled" {
  description = "Whether Kubernetes platform alerts are enabled."
  type        = bool
  default     = true
}

variable "prometheus_alerts_enabled" {
  description = "Whether Prometheus health alerts are enabled."
  type        = bool
  default     = true
}

variable "loki_alerts_enabled" {
  description = "Whether Loki health alerts are enabled."
  type        = bool
  default     = true
}

variable "opentelemetry_alerts_enabled" {
  description = "Whether OpenTelemetry Collector alerts are enabled."
  type        = bool
  default     = true
}

variable "istio_alerts_enabled" {
  description = "Whether Istio service mesh alerts are enabled."
  type        = bool
  default     = true
}

variable "application_alerts_enabled" {
  description = "Whether generic application workload alerts are enabled."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Kubernetes Alert Thresholds
# -----------------------------------------------------------------------------

variable "node_cpu_warning_threshold" {
  description = "Node CPU utilization percentage that triggers a warning alert."
  type        = number
  default     = 80

  validation {
    condition = (
      var.node_cpu_warning_threshold > 0 &&
      var.node_cpu_warning_threshold <= 100
    )

    error_message = "node_cpu_warning_threshold must be between 1 and 100."
  }
}

variable "node_memory_warning_threshold" {
  description = "Node memory utilization percentage that triggers a warning alert."
  type        = number
  default     = 85

  validation {
    condition = (
      var.node_memory_warning_threshold > 0 &&
      var.node_memory_warning_threshold <= 100
    )

    error_message = "node_memory_warning_threshold must be between 1 and 100."
  }
}

variable "persistent_volume_warning_threshold" {
  description = "Persistent volume utilization percentage that triggers a warning alert."
  type        = number
  default     = 80

  validation {
    condition = (
      var.persistent_volume_warning_threshold > 0 &&
      var.persistent_volume_warning_threshold <= 100
    )

    error_message = "persistent_volume_warning_threshold must be between 1 and 100."
  }
}

variable "persistent_volume_critical_threshold" {
  description = "Persistent volume utilization percentage that triggers a critical alert."
  type        = number
  default     = 90

  validation {
    condition = (
      var.persistent_volume_critical_threshold > 0 &&
      var.persistent_volume_critical_threshold <= 100 &&
      var.persistent_volume_critical_threshold >
      var.persistent_volume_warning_threshold
    )

    error_message = "persistent_volume_critical_threshold must be greater than the warning threshold and no more than 100."
  }
}

variable "pod_restart_warning_threshold" {
  description = "Number of container restarts within the evaluation window that triggers a warning."
  type        = number
  default     = 5

  validation {
    condition     = var.pod_restart_warning_threshold >= 1
    error_message = "pod_restart_warning_threshold must be at least 1."
  }
}

# -----------------------------------------------------------------------------
# Prometheus Alert Thresholds
# -----------------------------------------------------------------------------

variable "prometheus_target_down_duration" {
  description = "Duration a Prometheus target must remain unavailable before alerting."
  type        = string
  default     = "5m"
}

variable "prometheus_rule_failure_duration" {
  description = "Duration Prometheus rule evaluation failures must persist before alerting."
  type        = string
  default     = "5m"
}

# -----------------------------------------------------------------------------
# Loki Alert Thresholds
# -----------------------------------------------------------------------------

variable "loki_unavailable_duration" {
  description = "Duration Loki must remain unavailable before alerting."
  type        = string
  default     = "5m"
}

variable "loki_ingestion_stalled_duration" {
  description = "Duration Loki ingestion must remain at zero before alerting."
  type        = string
  default     = "10m"
}

variable "loki_discard_rate_threshold" {
  description = "Discarded Loki log lines per second that trigger a warning."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# OpenTelemetry Alert Thresholds
# -----------------------------------------------------------------------------

variable "otel_unavailable_duration" {
  description = "Duration the OpenTelemetry Collector must remain unavailable before alerting."
  type        = string
  default     = "5m"
}

variable "otel_receiver_refusal_threshold" {
  description = "Refused telemetry items per second that trigger a warning."
  type        = number
  default     = 1
}

variable "otel_export_failure_threshold" {
  description = "Failed telemetry exports per second that trigger a warning."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Istio Alert Thresholds
# -----------------------------------------------------------------------------

variable "istiod_unavailable_duration" {
  description = "Duration Istiod must remain unavailable before alerting."
  type        = string
  default     = "5m"
}

variable "istio_http_5xx_warning_threshold" {
  description = "Istio HTTP 5xx percentage that triggers a warning alert."
  type        = number
  default     = 5

  validation {
    condition = (
      var.istio_http_5xx_warning_threshold > 0 &&
      var.istio_http_5xx_warning_threshold <= 100
    )

    error_message = "istio_http_5xx_warning_threshold must be between 1 and 100."
  }
}

variable "istio_p95_latency_warning_seconds" {
  description = "Istio P95 request latency in seconds that triggers a warning."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Application Alert Thresholds
# -----------------------------------------------------------------------------

variable "application_unavailable_duration" {
  description = "Duration an application target must remain unavailable before alerting."
  type        = string
  default     = "5m"
}

variable "application_http_5xx_warning_threshold" {
  description = "Application HTTP 5xx percentage that triggers a warning."
  type        = number
  default     = 5

  validation {
    condition = (
      var.application_http_5xx_warning_threshold > 0 &&
      var.application_http_5xx_warning_threshold <= 100
    )

    error_message = "application_http_5xx_warning_threshold must be between 1 and 100."
  }
}

variable "application_p95_latency_warning_seconds" {
  description = "Application P95 request latency in seconds that triggers a warning."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Alert Metadata
# -----------------------------------------------------------------------------

variable "default_severity" {
  description = "Default severity label applied to alerts that do not define a specific severity."
  type        = string
  default     = "warning"

  validation {
    condition = contains(
      [
        "info",
        "warning",
        "critical"
      ],
      var.default_severity
    )

    error_message = "default_severity must be info, warning, or critical."
  }
}

variable "additional_labels" {
  description = "Additional labels applied to every PrometheusRule resource."
  type        = map(string)
  default     = {}
}

variable "additional_annotations" {
  description = "Additional annotations applied to every PrometheusRule resource."
  type        = map(string)
  default     = {}
}