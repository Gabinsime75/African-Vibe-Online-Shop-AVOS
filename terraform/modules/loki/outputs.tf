# =============================================================================
# CloudHustler Commerce Platform
# Loki Terraform Module Outputs
#
# This file exports the Loki Helm release details, Kubernetes namespace,
# internal service endpoints, and deployment metadata required by Fluent Bit,
# Grafana, Prometheus, and platform validation workflows.
# =============================================================================

# -----------------------------------------------------------------------------
# Helm Release Outputs
# -----------------------------------------------------------------------------

output "release_name" {
  description = "Name of the Loki Helm release."
  value       = helm_release.this.name
}

output "release_status" {
  description = "Current status of the Loki Helm release."
  value       = helm_release.this.status
}

output "chart_name" {
  description = "Name of the deployed Loki Helm chart."
  value       = helm_release.this.chart
}

output "chart_version" {
  description = "Version of the deployed Loki Helm chart."
  value       = helm_release.this.version
}

# -----------------------------------------------------------------------------
# Namespace Outputs
# -----------------------------------------------------------------------------

output "namespace" {
  description = "Kubernetes namespace where Loki is deployed."
  value       = var.namespace
}

output "namespace_created" {
  description = "Indicates whether the Loki module created the namespace."
  value       = var.create_namespace
}

# -----------------------------------------------------------------------------
# Loki Service Outputs
# -----------------------------------------------------------------------------

output "gateway_service_name" {
  description = "Internal Kubernetes Service name for the Loki gateway."
  value       = "${var.release_name}-gateway"
}

output "gateway_service_fqdn" {
  description = "Fully qualified Kubernetes DNS name for the Loki gateway."
  value       = "${var.release_name}-gateway.${var.namespace}.svc.cluster.local"
}

output "gateway_url" {
  description = "Internal Loki gateway URL used by Grafana."
  value       = "http://${var.release_name}-gateway.${var.namespace}.svc.cluster.local"
}

# -----------------------------------------------------------------------------
# Loki API Endpoint Outputs
# -----------------------------------------------------------------------------

output "push_endpoint" {
  description = "Internal Loki ingestion endpoint used by Fluent Bit."
  value       = "http://${var.release_name}-gateway.${var.namespace}.svc.cluster.local/loki/api/v1/push"
}

output "query_endpoint" {
  description = "Internal Loki query endpoint."
  value       = "http://${var.release_name}-gateway.${var.namespace}.svc.cluster.local/loki/api/v1/query"
}

output "query_range_endpoint" {
  description = "Internal Loki range query endpoint."
  value       = "http://${var.release_name}-gateway.${var.namespace}.svc.cluster.local/loki/api/v1/query_range"
}

output "ready_endpoint" {
  description = "Internal Loki readiness endpoint."
  value       = "http://${var.release_name}-gateway.${var.namespace}.svc.cluster.local/ready"
}

# -----------------------------------------------------------------------------
# Storage Outputs
# -----------------------------------------------------------------------------

output "storage_class_name" {
  description = "StorageClass used by Loki persistent storage."
  value       = var.storage_class_name
}

output "storage_size" {
  description = "Persistent storage size allocated to Loki."
  value       = var.storage_size
}

output "retention_period" {
  description = "Configured Loki log-retention period."
  value       = var.retention_period
}

# -----------------------------------------------------------------------------
# Monitoring Outputs
# -----------------------------------------------------------------------------

output "service_monitor_enabled" {
  description = "Indicates whether Loki Prometheus monitoring is enabled."
  value       = var.service_monitor_enabled
}

output "loki_canary_enabled" {
  description = "Indicates whether the Loki Canary workload is enabled."
  value       = var.loki_canary_enabled
}

# -----------------------------------------------------------------------------
# Deployment Outputs
# -----------------------------------------------------------------------------

output "deployment_mode" {
  description = "Loki deployment mode."
  value       = "SingleBinary"
}

output "replica_count" {
  description = "Number of configured Loki SingleBinary replicas."
  value       = var.replica_count
}