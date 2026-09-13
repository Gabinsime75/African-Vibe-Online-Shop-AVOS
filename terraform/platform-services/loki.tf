# =============================================================================
# CloudHustler Commerce Platform
# Loki Platform Service
#
# This file deploys Grafana Loki through the reusable Loki Terraform module.
# Loki provides centralized Kubernetes log storage for logs collected by
# Fluent Bit and queried through Grafana.
#
# Deployment characteristics:
# - Loki Helm chart version 7.2.0
# - SingleBinary deployment mode
# - Existing logging namespace
# - EBS gp3 persistent storage
# - Prometheus ServiceMonitor integration
# - Loki Canary validation
# =============================================================================

# -----------------------------------------------------------------------------
# Loki Module
# -----------------------------------------------------------------------------

module "loki" {
  source = "../modules/loki"

  # ---------------------------------------------------------------------------
  # Project Configuration
  # ---------------------------------------------------------------------------

  project_name = var.project_name
  environment  = var.environment

  # ---------------------------------------------------------------------------
  # Namespace Configuration
  #
  # The logging namespace is already managed by the Fluent Bit module.
  # Loki must reuse the existing namespace rather than attempting to create it.
  # ---------------------------------------------------------------------------

  namespace        = var.loki_namespace
  create_namespace = false

  # ---------------------------------------------------------------------------
  # Helm Configuration
  # ---------------------------------------------------------------------------

  release_name  = var.loki_release_name
  chart_version = var.loki_chart_version

  timeout         = var.loki_timeout
  atomic          = var.loki_atomic
  cleanup_on_fail = var.loki_cleanup_on_fail

  # ---------------------------------------------------------------------------
  # Storage Configuration
  # ---------------------------------------------------------------------------

  storage_class_name = var.loki_storage_class_name
  storage_size       = var.loki_storage_size
  retention_period   = var.loki_retention_period
  schema_start_date  = var.loki_schema_start_date

  # ---------------------------------------------------------------------------
  # Loki Ingestion and Query Limits
  # ---------------------------------------------------------------------------

  ingestion_rate_mb           = var.loki_ingestion_rate_mb
  ingestion_burst_size_mb     = var.loki_ingestion_burst_size_mb
  max_query_parallelism       = var.loki_max_query_parallelism
  max_query_series            = var.loki_max_query_series
  reject_old_samples_max_age  = var.loki_reject_old_samples_max_age
  per_stream_rate_limit       = var.loki_per_stream_rate_limit
  per_stream_rate_limit_burst = var.loki_per_stream_rate_limit_burst

  # ---------------------------------------------------------------------------
  # Retention and Compaction
  # ---------------------------------------------------------------------------

  compaction_interval    = var.loki_compaction_interval
  retention_delete_delay = var.loki_retention_delete_delay

  # ---------------------------------------------------------------------------
  # Loki Workload Configuration
  # ---------------------------------------------------------------------------

  replica_count = var.loki_replica_count

  cpu_request    = var.loki_cpu_request
  memory_request = var.loki_memory_request
  cpu_limit      = var.loki_cpu_limit
  memory_limit   = var.loki_memory_limit

  # ---------------------------------------------------------------------------
  # Loki Gateway Resources
  # ---------------------------------------------------------------------------

  gateway_cpu_request    = var.loki_gateway_cpu_request
  gateway_memory_request = var.loki_gateway_memory_request
  gateway_cpu_limit      = var.loki_gateway_cpu_limit
  gateway_memory_limit   = var.loki_gateway_memory_limit

  # ---------------------------------------------------------------------------
  # Loki Canary Resources
  # ---------------------------------------------------------------------------

  canary_cpu_request    = var.loki_canary_cpu_request
  canary_memory_request = var.loki_canary_memory_request
  canary_cpu_limit      = var.loki_canary_cpu_limit
  canary_memory_limit   = var.loki_canary_memory_limit

  # ---------------------------------------------------------------------------
  # Kubernetes Scheduling
  # ---------------------------------------------------------------------------

  node_selector = var.loki_node_selector
  tolerations   = var.loki_tolerations
  affinity      = var.loki_affinity

  # ---------------------------------------------------------------------------
  # Monitoring Configuration
  # ---------------------------------------------------------------------------

  service_monitor_enabled  = var.loki_service_monitor_enabled
  service_monitor_interval = var.loki_service_monitor_interval
  prometheus_release_name  = var.prometheus_release_name
  loki_canary_enabled      = var.loki_canary_enabled

  # ---------------------------------------------------------------------------
  # Deployment Dependencies
  #
  # Prometheus must exist before Loki creates its ServiceMonitor.
  # Fluent Bit manages the shared logging namespace used by Loki.
  # ---------------------------------------------------------------------------

  depends_on = [
    module.prometheus,
    module.fluent_bit
  ]
}