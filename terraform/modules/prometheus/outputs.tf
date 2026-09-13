# =============================================================================
# CloudHustler Commerce Platform - Prometheus Module Outputs
# =============================================================================
# This file exports the key attributes of the Prometheus monitoring stack after
# deployment.
#
# These outputs are consumed by the root platform-services module and provide
# information useful for validation, troubleshooting, and future integrations.
# =============================================================================

# -----------------------------------------------------------------------------
# Namespace
# -----------------------------------------------------------------------------

output "namespace" {
  description = "Namespace where the Prometheus monitoring stack is deployed."

  value = (
    var.create_namespace
    ? kubernetes_namespace.this[0].metadata[0].name
    : var.namespace
  )
}

# -----------------------------------------------------------------------------
# Helm Release
# -----------------------------------------------------------------------------

output "helm_release_name" {
  description = "Name of the Prometheus Helm release."
  value       = helm_release.this.name
}

output "helm_release_namespace" {
  description = "Namespace of the Prometheus Helm release."
  value       = helm_release.this.namespace
}

output "helm_chart" {
  description = "Helm chart deployed by this module."
  value       = helm_release.this.chart
}

output "helm_chart_version" {
  description = "Version of the deployed Helm chart."
  value       = helm_release.this.version
}

output "helm_release_status" {
  description = "Status of the Helm release."
  value       = helm_release.this.status
}

output "helm_release_revision" {
  description = "Current Helm release revision."
  value       = helm_release.this.metadata.revision
}

# -----------------------------------------------------------------------------
# Prometheus
# -----------------------------------------------------------------------------

output "prometheus_enabled" {
  description = "Indicates whether Prometheus is enabled."
  value       = var.prometheus_enabled
}

output "prometheus_retention" {
  description = "Configured Prometheus metric retention period."
  value       = var.prometheus_retention
}

output "prometheus_storage_size" {
  description = "Configured Prometheus persistent storage size."
  value       = var.prometheus_storage_size
}

# -----------------------------------------------------------------------------
# Alertmanager
# -----------------------------------------------------------------------------

output "alertmanager_enabled" {
  description = "Indicates whether Alertmanager is enabled."
  value       = var.alertmanager_enabled
}

output "alertmanager_replicas" {
  description = "Configured Alertmanager replica count."
  value       = var.alertmanager_replicas
}

# -----------------------------------------------------------------------------
# Kubernetes Monitoring Components
# -----------------------------------------------------------------------------

output "kube_state_metrics_enabled" {
  description = "Indicates whether kube-state-metrics is enabled."
  value       = var.kube_state_metrics_enabled
}

output "node_exporter_enabled" {
  description = "Indicates whether Prometheus Node Exporter is enabled."
  value       = var.node_exporter_enabled
}

output "default_rules_enabled" {
  description = "Indicates whether the default Kubernetes monitoring rules are enabled."
  value       = var.default_rules_enabled
}