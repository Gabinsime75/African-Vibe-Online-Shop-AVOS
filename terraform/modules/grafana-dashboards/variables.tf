# =============================================================================
# CloudHustler Commerce Platform
# Grafana Dashboards Module Variables
#
# This file defines all configurable settings used to provision Grafana
# dashboards as Kubernetes ConfigMaps discovered by the Grafana dashboard
# sidecar deployed through kube-prometheus-stack.
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
# Kubernetes Namespace
# -----------------------------------------------------------------------------

variable "namespace" {
  description = "Namespace where the Grafana dashboard ConfigMaps are created."
  type        = string
  default     = "monitoring"
}

# -----------------------------------------------------------------------------
# ConfigMap Naming
# -----------------------------------------------------------------------------

variable "configmap_name_prefix" {
  description = "Prefix applied to every Grafana dashboard ConfigMap."
  type        = string
  default     = "cloudhusller-dashboard"
}

# -----------------------------------------------------------------------------
# Grafana Sidecar Discovery
# -----------------------------------------------------------------------------

variable "sidecar_label" {
  description = "ConfigMap label watched by the Grafana dashboard sidecar."
  type        = string
  default     = "grafana_dashboard"
}

variable "sidecar_label_value" {
  description = "Value assigned to the Grafana dashboard sidecar label."
  type        = string
  default     = "1"
}

# -----------------------------------------------------------------------------
# Dashboard Folder
# -----------------------------------------------------------------------------

variable "dashboard_folder" {
  description = "Logical Grafana folder used for CloudHustler dashboards."
  type        = string
  default     = "CloudHustler Platform"
}

# -----------------------------------------------------------------------------
# Additional Metadata
# -----------------------------------------------------------------------------

variable "additional_labels" {
  description = "Additional labels applied to every dashboard ConfigMap."
  type        = map(string)
  default     = {}
}

variable "additional_annotations" {
  description = "Additional annotations applied to every dashboard ConfigMap."
  type        = map(string)
  default     = {}
}