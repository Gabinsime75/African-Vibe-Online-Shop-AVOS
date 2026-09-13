# =============================================================================
# CloudHustler Commerce Platform
# OpenTelemetry Collector Module Outputs
#
# This file exports the OpenTelemetry Collector deployment details, internal
# OTLP endpoints, Prometheus endpoints, AWS X-Ray integration status, and IAM
# resources required for validation and platform-level integration.
# =============================================================================

# -----------------------------------------------------------------------------
# Helm Release Outputs
# -----------------------------------------------------------------------------

output "release_name" {
  description = "Name of the OpenTelemetry Collector Helm release."
  value       = helm_release.this.name
}

output "release_status" {
  description = "Current status of the OpenTelemetry Collector Helm release."
  value       = helm_release.this.status
}

output "chart_name" {
  description = "Name of the deployed OpenTelemetry Collector Helm chart."
  value       = helm_release.this.chart
}

output "chart_version" {
  description = "Version of the deployed OpenTelemetry Collector Helm chart."
  value       = helm_release.this.version
}

# -----------------------------------------------------------------------------
# Namespace Outputs
# -----------------------------------------------------------------------------

output "namespace" {
  description = "Kubernetes namespace where the OpenTelemetry Collector is deployed."
  value       = var.namespace
}

output "namespace_created" {
  description = "Indicates whether this module created the namespace."
  value       = var.create_namespace
}

# -----------------------------------------------------------------------------
# Kubernetes Service Outputs
# -----------------------------------------------------------------------------

output "service_name" {
  description = "Kubernetes Service name used by the OpenTelemetry Collector."
  value       = var.release_name
}

output "service_type" {
  description = "Kubernetes Service type used by the OpenTelemetry Collector."
  value       = var.service_type
}

output "service_fqdn" {
  description = "Fully qualified Kubernetes DNS name for the Collector Service."
  value       = "${var.release_name}.${var.namespace}.svc.cluster.local"
}

# -----------------------------------------------------------------------------
# OTLP Receiver Endpoints
# -----------------------------------------------------------------------------

output "otlp_grpc_endpoint" {
  description = "Internal OTLP gRPC endpoint used by instrumented applications."
  value       = "${var.release_name}.${var.namespace}.svc.cluster.local:${var.otlp_grpc_port}"
}

output "otlp_grpc_url" {
  description = "Internal OTLP gRPC URL."
  value       = "http://${var.release_name}.${var.namespace}.svc.cluster.local:${var.otlp_grpc_port}"
}

output "otlp_http_endpoint" {
  description = "Internal OTLP HTTP endpoint used by instrumented applications."
  value       = "http://${var.release_name}.${var.namespace}.svc.cluster.local:${var.otlp_http_port}"
}

output "otlp_http_traces_endpoint" {
  description = "Internal OTLP HTTP traces endpoint."
  value       = "http://${var.release_name}.${var.namespace}.svc.cluster.local:${var.otlp_http_port}/v1/traces"
}

output "otlp_http_metrics_endpoint" {
  description = "Internal OTLP HTTP metrics endpoint."
  value       = "http://${var.release_name}.${var.namespace}.svc.cluster.local:${var.otlp_http_port}/v1/metrics"
}

# -----------------------------------------------------------------------------
# Prometheus Outputs
# -----------------------------------------------------------------------------

output "prometheus_exporter_endpoint" {
  description = "Internal Prometheus endpoint exposing application metrics received through OTLP."
  value       = "http://${var.release_name}.${var.namespace}.svc.cluster.local:${var.prometheus_exporter_port}/metrics"
}

output "internal_metrics_endpoint" {
  description = "Collector internal operational metrics endpoint."
  value       = "http://${var.release_name}.${var.namespace}.svc.cluster.local:${var.internal_metrics_port}/metrics"
}

output "service_monitor_enabled" {
  description = "Indicates whether the Collector ServiceMonitor is enabled."
  value       = var.service_monitor_enabled
}

output "prometheus_namespace" {
  description = "Metric prefix configured for the Collector Prometheus exporter."
  value       = var.prometheus_namespace
}

# -----------------------------------------------------------------------------
# Health and Diagnostics Outputs
# -----------------------------------------------------------------------------

output "health_endpoint" {
  description = "Internal Collector health-check endpoint."
  value       = "http://${var.release_name}.${var.namespace}.svc.cluster.local:${var.health_check_port}/"
}

output "zpages_enabled" {
  description = "Indicates whether the zPages diagnostics extension is enabled."
  value       = var.zpages_enabled
}

output "zpages_endpoint" {
  description = "Internal zPages diagnostic endpoint."
  value = var.zpages_enabled ? (
    "http://${var.release_name}.${var.namespace}.svc.cluster.local:${var.zpages_port}/debug/servicez"
  ) : null
}

# -----------------------------------------------------------------------------
# Deployment Outputs
# -----------------------------------------------------------------------------

output "deployment_mode" {
  description = "OpenTelemetry Collector deployment mode."
  value       = "deployment"
}

output "replica_count" {
  description = "Configured number of Collector replicas."
  value       = var.replica_count
}

output "service_account_name" {
  description = "Kubernetes service account used by the Collector."
  value       = var.service_account_name
}

output "collector_log_level" {
  description = "Configured OpenTelemetry Collector log level."
  value       = var.collector_log_level
}

# -----------------------------------------------------------------------------
# AWS X-Ray Integration Outputs
# -----------------------------------------------------------------------------

output "aws_xray_enabled" {
  description = "Indicates whether traces are exported to AWS X-Ray."
  value       = var.aws_xray_enabled
}

output "trace_exporter" {
  description = "Configured trace exporter."
  value       = var.aws_xray_enabled ? "awsxray" : "debug"
}

output "iam_role_name" {
  description = "IAM role name used for AWS X-Ray export."
  value       = var.aws_xray_enabled ? aws_iam_role.this[0].name : null
}

output "iam_role_arn" {
  description = "IAM role ARN used for AWS X-Ray export."
  value       = var.aws_xray_enabled ? aws_iam_role.this[0].arn : null
}

output "iam_policy_name" {
  description = "IAM policy name used for AWS X-Ray export."
  value       = var.aws_xray_enabled ? aws_iam_policy.xray[0].name : null
}

output "iam_policy_arn" {
  description = "IAM policy ARN used for AWS X-Ray export."
  value       = var.aws_xray_enabled ? aws_iam_policy.xray[0].arn : null
}

output "pod_identity_association_id" {
  description = "EKS Pod Identity association ID used by the Collector."
  value = var.aws_xray_enabled ? (
    aws_eks_pod_identity_association.this[0].association_id
  ) : null
}

output "pod_identity_association_arn" {
  description = "EKS Pod Identity association ARN used by the Collector."
  value = var.aws_xray_enabled ? (
    aws_eks_pod_identity_association.this[0].association_arn
  ) : null
}