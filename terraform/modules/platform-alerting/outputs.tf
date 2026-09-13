#############################################
# Platform Alerting Module Outputs
#
# Purpose:
# Exposes the key information produced by the
# Platform Alerting module after deployment.
#
# These outputs allow operators and downstream
# Terraform modules to quickly verify that the
# alerting platform has been successfully
# deployed and integrated with the
# kube-prometheus-stack.
#############################################

############################################################
# General Module Information
############################################################

output "namespace" {
  description = "Namespace containing the PrometheusRule resources."
  value       = var.namespace
}

output "prometheus_rule_selector" {
  description = "PrometheusRule selector used by the Prometheus Operator."

  value = {
    (var.prometheus_rule_label) = var.prometheus_rule_label_value
  }
}

############################################################
# Rule Groups
############################################################

output "rule_groups" {
  description = "Alert rule groups managed by this module."

  value = [
    "kubernetes",
    "prometheus",
    "loki",
    "opentelemetry",
    "istio",
    "application"
  ]
}

############################################################
# Enabled Rule Groups
############################################################

output "enabled_rule_groups" {

  description = "Alert rule groups currently enabled."

  value = compact([
    var.kubernetes_alerts_enabled ? "kubernetes" : "",
    var.prometheus_alerts_enabled ? "prometheus" : "",
    var.loki_alerts_enabled ? "loki" : "",
    var.opentelemetry_alerts_enabled ? "opentelemetry" : "",
    var.istio_alerts_enabled ? "istio" : "",
    var.application_alerts_enabled ? "application" : ""
  ])
}

############################################################
# Kubernetes Thresholds
############################################################

output "kubernetes_thresholds" {

  description = "Configured Kubernetes alert thresholds."

  value = {
    node_cpu_warning              = var.node_cpu_warning_threshold
    node_memory_warning           = var.node_memory_warning_threshold
    persistent_volume_warning     = var.persistent_volume_warning_threshold
    persistent_volume_critical    = var.persistent_volume_critical_threshold
    pod_restart_warning_threshold = var.pod_restart_warning_threshold
  }
}

############################################################
# Istio Thresholds
############################################################

output "istio_thresholds" {

  description = "Configured Istio alert thresholds."

  value = {
    http_5xx_warning = var.istio_http_5xx_warning_threshold
    latency_p95      = var.istio_p95_latency_warning_seconds
  }
}

############################################################
# OpenTelemetry Thresholds
############################################################

output "opentelemetry_thresholds" {

  description = "Configured OpenTelemetry alert thresholds."

  value = {
    unavailable_duration = var.otel_unavailable_duration
    receiver_refusals    = var.otel_receiver_refusal_threshold
    exporter_failures    = var.otel_export_failure_threshold
  }
}

############################################################
# Loki Thresholds
############################################################

output "loki_thresholds" {

  description = "Configured Loki alert thresholds."

  value = {
    unavailable_duration = var.loki_unavailable_duration
    ingestion_duration   = var.loki_ingestion_stalled_duration
    discard_rate         = var.loki_discard_rate_threshold
  }
}

############################################################
# Prometheus Thresholds
############################################################

output "prometheus_thresholds" {

  description = "Configured Prometheus alert thresholds."

  value = {
    target_down_duration = var.prometheus_target_down_duration
    rule_failure         = var.prometheus_rule_failure_duration
  }
}

############################################################
# Application Thresholds
############################################################

output "application_thresholds" {

  description = "Configured application alert thresholds."

  value = {
    unavailable_duration = var.application_unavailable_duration
    http_5xx_warning     = var.application_http_5xx_warning_threshold
    latency_p95          = var.application_p95_latency_warning_seconds
  }
}

############################################################
# Severity
############################################################

output "default_severity" {
  description = "Default alert severity."
  value       = var.default_severity
}

############################################################
# Deployment Summary
############################################################

output "deployment_summary" {

  description = "Summary of the Platform Alerting deployment."

  value = {
    namespace            = var.namespace
    monitoring_stack     = "kube-prometheus-stack"
    prometheus_operator  = true
    alertmanager_enabled = true
    grafana_enabled      = true

    rule_groups = compact([
      var.kubernetes_alerts_enabled ? "Kubernetes" : "",
      var.prometheus_alerts_enabled ? "Prometheus" : "",
      var.loki_alerts_enabled ? "Loki" : "",
      var.opentelemetry_alerts_enabled ? "OpenTelemetry" : "",
      var.istio_alerts_enabled ? "Istio" : "",
      var.application_alerts_enabled ? "Application" : ""
    ])
  }
}