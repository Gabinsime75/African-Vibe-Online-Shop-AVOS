# =============================================================================
# Fluent Bit Platform Service
# =============================================================================
# Deploys Fluent Bit across the EKS cluster as a DaemonSet.
# Fluent Bit collects Kubernetes container logs, enriches them with metadata,
# and temporarily writes them to stdout until Loki is implemented.
# =============================================================================

module "fluent_bit" {
  source = "../modules/fluent-bit"

  # ---------------------------------------------------------------------------
  # Helm Release
  # ---------------------------------------------------------------------------

  release_name  = var.fluent_bit_release_name
  namespace     = var.fluent_bit_namespace
  chart_version = var.fluent_bit_chart_version

  create_namespace = var.fluent_bit_create_namespace

  # ---------------------------------------------------------------------------
  # Logging Configuration
  # ---------------------------------------------------------------------------

  log_level = var.fluent_bit_log_level

  # ---------------------------------------------------------------------------
  # Prometheus Monitoring
  # ---------------------------------------------------------------------------

  service_monitor_enabled = var.fluent_bit_service_monitor_enabled
  monitoring_namespace    = var.prometheus_namespace
  scrape_interval         = var.fluent_bit_scrape_interval

  # ---------------------------------------------------------------------------
  # Resource Configuration
  # ---------------------------------------------------------------------------

  cpu_request    = var.fluent_bit_cpu_request
  memory_request = var.fluent_bit_memory_request
  cpu_limit      = var.fluent_bit_cpu_limit
  memory_limit   = var.fluent_bit_memory_limit

  # ---------------------------------------------------------------------------
  # Helm Behavior
  # ---------------------------------------------------------------------------

  timeout = var.fluent_bit_timeout
  atomic  = var.fluent_bit_atomic
}