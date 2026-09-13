# =============================================================================
# CloudHustler Commerce Platform
# OpenTelemetry Collector Platform Service
#
# This file deploys the OpenTelemetry Collector through the reusable Terraform
# module. The Collector provides the centralized OTLP gateway for application
# metrics and distributed traces.
#
# Current integrations:
# - OTLP over gRPC and HTTP
# - Prometheus metrics export
# - Kubernetes metadata enrichment
# - Optional AWS X-Ray trace export through EKS Pod Identity
#
# Fluent Bit remains responsible for Kubernetes container logs.
# =============================================================================

# -----------------------------------------------------------------------------
# OpenTelemetry Collector Module
# -----------------------------------------------------------------------------

module "opentelemetry_collector" {
  source = "../modules/opentelemetry-collector"

  # ---------------------------------------------------------------------------
  # Project Configuration
  # ---------------------------------------------------------------------------

  project_name = var.project_name
  environment  = var.environment
  cluster_name = var.cluster_name
  aws_region   = var.aws_region

  # ---------------------------------------------------------------------------
  # Namespace Configuration
  # ---------------------------------------------------------------------------

  namespace        = var.otel_namespace
  create_namespace = var.otel_create_namespace
  namespace_labels = var.otel_namespace_labels

  # ---------------------------------------------------------------------------
  # Helm Configuration
  # ---------------------------------------------------------------------------

  release_name  = var.otel_release_name
  chart_version = var.otel_chart_version

  timeout         = var.otel_timeout
  atomic          = var.otel_atomic
  cleanup_on_fail = var.otel_cleanup_on_fail

  # ---------------------------------------------------------------------------
  # Collector Image
  # ---------------------------------------------------------------------------

  image_repository  = var.otel_image_repository
  image_tag         = var.otel_image_tag
  image_pull_policy = var.otel_image_pull_policy

  # ---------------------------------------------------------------------------
  # Deployment Configuration
  # ---------------------------------------------------------------------------

  replica_count        = var.otel_replica_count
  service_account_name = var.otel_service_account_name

  service_account_annotations = var.otel_service_account_annotations

  # ---------------------------------------------------------------------------
  # Receiver Ports
  # ---------------------------------------------------------------------------

  otlp_grpc_port = var.otel_otlp_grpc_port
  otlp_http_port = var.otel_otlp_http_port

  # ---------------------------------------------------------------------------
  # Operational Ports
  # ---------------------------------------------------------------------------

  prometheus_exporter_port = var.otel_prometheus_exporter_port
  internal_metrics_port    = var.otel_internal_metrics_port
  health_check_port        = var.otel_health_check_port

  zpages_enabled = var.otel_zpages_enabled
  zpages_port    = var.otel_zpages_port

  # ---------------------------------------------------------------------------
  # Processor Configuration
  # ---------------------------------------------------------------------------

  memory_limiter_check_interval         = var.otel_memory_limiter_check_interval
  memory_limiter_limit_percentage       = var.otel_memory_limiter_limit_percentage
  memory_limiter_spike_limit_percentage = var.otel_memory_limiter_spike_limit_percentage

  batch_timeout   = var.otel_batch_timeout
  batch_send_size = var.otel_batch_send_size
  batch_max_size  = var.otel_batch_max_size

  # ---------------------------------------------------------------------------
  # Prometheus Integration
  # ---------------------------------------------------------------------------

  prometheus_namespace      = var.otel_prometheus_namespace
  prometheus_scrape_enabled = var.otel_prometheus_scrape_enabled

  service_monitor_enabled  = var.otel_service_monitor_enabled
  service_monitor_interval = var.otel_service_monitor_interval
  prometheus_release_name  = var.prometheus_release_name

  # ---------------------------------------------------------------------------
  # AWS X-Ray Integration
  # ---------------------------------------------------------------------------

  aws_xray_enabled            = var.otel_aws_xray_enabled
  aws_xray_indexed_attributes = var.otel_aws_xray_indexed_attributes

  debug_exporter_verbosity = var.otel_debug_exporter_verbosity

  # ---------------------------------------------------------------------------
  # IAM Configuration
  # ---------------------------------------------------------------------------

  iam_role_name   = var.otel_iam_role_name
  iam_policy_name = var.otel_iam_policy_name

  permissions_boundary_arn = var.otel_permissions_boundary_arn
  iam_tags                 = var.otel_iam_tags

  # ---------------------------------------------------------------------------
  # Collector Logging
  # ---------------------------------------------------------------------------

  collector_log_level = var.otel_collector_log_level

  # ---------------------------------------------------------------------------
  # Kubernetes Service
  # ---------------------------------------------------------------------------

  service_type = var.otel_service_type

  # ---------------------------------------------------------------------------
  # Resources
  # ---------------------------------------------------------------------------

  cpu_request    = var.otel_cpu_request
  memory_request = var.otel_memory_request
  cpu_limit      = var.otel_cpu_limit
  memory_limit   = var.otel_memory_limit

  # ---------------------------------------------------------------------------
  # Autoscaling
  # ---------------------------------------------------------------------------

  autoscaling_enabled      = var.otel_autoscaling_enabled
  autoscaling_min_replicas = var.otel_autoscaling_min_replicas
  autoscaling_max_replicas = var.otel_autoscaling_max_replicas
  autoscaling_cpu_target   = var.otel_autoscaling_cpu_target

  # ---------------------------------------------------------------------------
  # Scheduling
  # ---------------------------------------------------------------------------

  node_selector = var.otel_node_selector
  tolerations   = var.otel_tolerations
  affinity      = var.otel_affinity

  # ---------------------------------------------------------------------------
  # Dependencies
  #
  # Prometheus must exist before the ServiceMonitor is created.
  # Kiali is included because tracing integration can later be enabled there
  # after the Collector and trace backend are fully available.
  # ---------------------------------------------------------------------------

  depends_on = [
    module.prometheus,
    module.kiali
  ]
}