# =============================================================================
# CloudHustler Commerce Platform
# Kiali Platform Service
#
# This file deploys the Kiali observability dashboard for the Istio service
# mesh. Kiali integrates with the existing Prometheus and Grafana deployments
# to provide traffic visualization, workload health, service dependency
# graphs, latency, error rates, and Istio configuration validation.
#
# Dependencies
# - Istio Control Plane
# - Istio Ingress Gateway
# - Prometheus
# =============================================================================

# -----------------------------------------------------------------------------
# Kiali Module
# -----------------------------------------------------------------------------

module "kiali" {
  source = "../modules/kiali"

  # ---------------------------------------------------------------------------
  # Project Configuration
  # ---------------------------------------------------------------------------

  project_name = var.project_name
  environment  = var.environment
  cluster_name = var.cluster_name

  # ---------------------------------------------------------------------------
  # Namespace Configuration
  # ---------------------------------------------------------------------------

  namespace        = var.kiali_namespace
  create_namespace = false

  # ---------------------------------------------------------------------------
  # Helm Configuration
  # ---------------------------------------------------------------------------

  release_name  = var.kiali_release_name
  chart_version = var.kiali_chart_version

  timeout         = var.kiali_timeout
  atomic          = var.kiali_atomic
  cleanup_on_fail = var.kiali_cleanup_on_fail

  # ---------------------------------------------------------------------------
  # Authentication
  # ---------------------------------------------------------------------------

  auth_strategy = var.kiali_auth_strategy

  # ---------------------------------------------------------------------------
  # Deployment
  # ---------------------------------------------------------------------------

  instance_name         = var.kiali_instance_name
  replica_count         = var.kiali_replica_count
  accessible_namespaces = var.kiali_accessible_namespaces

  # ---------------------------------------------------------------------------
  # Resources
  # ---------------------------------------------------------------------------

  cpu_request    = var.kiali_cpu_request
  memory_request = var.kiali_memory_request

  cpu_limit    = var.kiali_cpu_limit
  memory_limit = var.kiali_memory_limit

  # ---------------------------------------------------------------------------
  # Scheduling
  # ---------------------------------------------------------------------------

  node_selector = var.kiali_node_selector
  tolerations   = var.kiali_tolerations
  affinity      = var.kiali_affinity

  # ---------------------------------------------------------------------------
  # Istio
  # ---------------------------------------------------------------------------

  istio_namespace = var.kiali_istio_namespace

  # ---------------------------------------------------------------------------
  # Prometheus
  # ---------------------------------------------------------------------------

  prometheus_url = var.kiali_prometheus_url

  # ---------------------------------------------------------------------------
  # Grafana
  # ---------------------------------------------------------------------------

  grafana_enabled        = var.kiali_grafana_enabled
  grafana_in_cluster_url = var.kiali_grafana_in_cluster_url
  grafana_external_url   = var.kiali_grafana_external_url

  # ---------------------------------------------------------------------------
  # Tracing
  # ---------------------------------------------------------------------------

  tracing_enabled = var.kiali_tracing_enabled

  # ---------------------------------------------------------------------------
  # Server
  # ---------------------------------------------------------------------------

  server_port = var.kiali_server_port
  web_root    = var.kiali_web_root

  metrics_enabled = var.kiali_metrics_enabled
  metrics_port    = var.kiali_metrics_port

  # ---------------------------------------------------------------------------
  # Service
  # ---------------------------------------------------------------------------

  service_type        = var.kiali_service_type
  service_annotations = var.kiali_service_annotations

  # ---------------------------------------------------------------------------
  # Dependencies
  # ---------------------------------------------------------------------------

  depends_on = [
    module.istio_control_plane,
    module.istio_ingress_gateway,
    module.prometheus
  ]
}