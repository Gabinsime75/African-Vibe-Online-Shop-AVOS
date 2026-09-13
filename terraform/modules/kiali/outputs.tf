# =============================================================================
# CloudHustler Commerce Platform
# Kiali Terraform Module Outputs
#
# This file exports the Kiali deployment information for validation,
# integration, and platform-level outputs.
# =============================================================================

# -----------------------------------------------------------------------------
# Helm Release Outputs
# -----------------------------------------------------------------------------

output "release_name" {
  description = "Kiali Helm release name."
  value       = helm_release.this.name
}

output "release_status" {
  description = "Current Helm release status."
  value       = helm_release.this.status
}

output "chart_name" {
  description = "Installed Helm chart."
  value       = helm_release.this.chart
}

output "chart_version" {
  description = "Installed Helm chart version."
  value       = helm_release.this.version
}

# -----------------------------------------------------------------------------
# Namespace Outputs
# -----------------------------------------------------------------------------

output "namespace" {
  description = "Namespace where Kiali is deployed."
  value       = var.namespace
}

output "namespace_created" {
  description = "Whether Terraform created the namespace."
  value       = var.create_namespace
}

# -----------------------------------------------------------------------------
# Service Outputs
# -----------------------------------------------------------------------------

output "service_name" {
  description = "Kiali Kubernetes Service."
  value       = helm_release.this.name
}

output "service_type" {
  description = "Kiali Kubernetes Service type."
  value       = var.service_type
}

output "internal_url" {
  description = "Internal Kubernetes URL for Kiali."
  value       = "http://${helm_release.this.name}.${var.namespace}.svc.cluster.local:${var.server_port}"
}

# -----------------------------------------------------------------------------
# External Integrations
# -----------------------------------------------------------------------------

output "prometheus_url" {
  description = "Configured Prometheus endpoint."
  value       = var.prometheus_url
}

output "grafana_url" {
  description = "Configured Grafana endpoint."
  value       = var.grafana_in_cluster_url
}

output "tracing_enabled" {
  description = "Whether tracing integration is enabled."
  value       = var.tracing_enabled
}

# -----------------------------------------------------------------------------
# Deployment Outputs
# -----------------------------------------------------------------------------

output "replica_count" {
  description = "Configured number of Kiali replicas."
  value       = var.replica_count
}

output "auth_strategy" {
  description = "Configured authentication strategy."
  value       = var.auth_strategy
}

output "metrics_enabled" {
  description = "Whether Prometheus metrics are enabled."
  value       = var.metrics_enabled
}

output "accessible_namespaces" {
  description = "Namespaces monitored by Kiali."
  value       = var.accessible_namespaces
}