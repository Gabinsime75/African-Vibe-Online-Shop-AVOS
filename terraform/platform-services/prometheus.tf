# =============================================================================
# CloudHustler Commerce Platform - Prometheus Monitoring Foundation
# =============================================================================
# This file invokes the reusable Prometheus module to deploy the Phase 1
# Kubernetes monitoring foundation.
#
# The deployment includes:
# - Prometheus Operator
# - Prometheus Server
# - Alertmanager
# - kube-state-metrics
# - Prometheus Node Exporter
# - Kubernetes recording and alerting rules
#
# Grafana is intentionally disabled during Phase 1 and will be implemented
# separately during Phase 2.
# =============================================================================

# -----------------------------------------------------------------------------
# Prometheus Monitoring Module
# -----------------------------------------------------------------------------

module "prometheus" {
  source = "../modules/prometheus"

  # ---------------------------------------------------------------------------
  # Project Configuration
  # ---------------------------------------------------------------------------

  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags

  # ---------------------------------------------------------------------------
  # Kubernetes Namespace
  # ---------------------------------------------------------------------------

  namespace        = var.prometheus_namespace
  create_namespace = var.prometheus_create_namespace

  # ---------------------------------------------------------------------------
  # Helm Release Configuration
  # ---------------------------------------------------------------------------

  release_name     = var.prometheus_release_name
  chart_repository = var.prometheus_chart_repository
  chart_name       = var.prometheus_chart_name
  chart_version    = var.prometheus_chart_version

  helm_timeout           = var.prometheus_helm_timeout
  helm_wait              = var.prometheus_helm_wait
  helm_atomic            = var.prometheus_helm_atomic
  helm_cleanup_on_fail   = var.prometheus_helm_cleanup_on_fail
  helm_force_update      = var.prometheus_helm_force_update
  helm_recreate_pods     = var.prometheus_helm_recreate_pods
  helm_dependency_update = var.prometheus_helm_dependency_update

  # ---------------------------------------------------------------------------
  # Prometheus Server
  # ---------------------------------------------------------------------------

  prometheus_enabled             = var.prometheus_enabled
  prometheus_replicas            = var.prometheus_replicas
  prometheus_retention           = var.prometheus_retention
  prometheus_retention_size      = var.prometheus_retention_size
  prometheus_scrape_interval     = var.prometheus_scrape_interval
  prometheus_evaluation_interval = var.prometheus_evaluation_interval
  prometheus_enable_admin_api    = var.prometheus_enable_admin_api
  prometheus_external_url        = var.prometheus_external_url
  prometheus_route_prefix        = var.prometheus_route_prefix

  # ---------------------------------------------------------------------------
  # Prometheus Resources
  # ---------------------------------------------------------------------------

  prometheus_cpu_request    = var.prometheus_cpu_request
  prometheus_memory_request = var.prometheus_memory_request
  prometheus_cpu_limit      = var.prometheus_cpu_limit
  prometheus_memory_limit   = var.prometheus_memory_limit

  # ---------------------------------------------------------------------------
  # Prometheus Persistent Storage
  # ---------------------------------------------------------------------------

  prometheus_persistence_enabled  = var.prometheus_persistence_enabled
  prometheus_storage_class_name   = var.prometheus_storage_class_name
  prometheus_storage_size         = var.prometheus_storage_size
  prometheus_storage_access_modes = var.prometheus_storage_access_modes

  # ---------------------------------------------------------------------------
  # Prometheus Resource Discovery
  # ---------------------------------------------------------------------------

  service_monitor_selector_nil_uses_helm_values = var.prometheus_service_monitor_selector_nil_uses_helm_values
  pod_monitor_selector_nil_uses_helm_values     = var.prometheus_pod_monitor_selector_nil_uses_helm_values
  rule_selector_nil_uses_helm_values            = var.prometheus_rule_selector_nil_uses_helm_values

  service_monitor_namespace_selector = var.prometheus_service_monitor_namespace_selector
  pod_monitor_namespace_selector     = var.prometheus_pod_monitor_namespace_selector
  rule_namespace_selector            = var.prometheus_rule_namespace_selector

  # ---------------------------------------------------------------------------
  # Prometheus Operator
  # ---------------------------------------------------------------------------

  prometheus_operator_enabled        = var.prometheus_operator_enabled
  prometheus_operator_cpu_request    = var.prometheus_operator_cpu_request
  prometheus_operator_memory_request = var.prometheus_operator_memory_request
  prometheus_operator_cpu_limit      = var.prometheus_operator_cpu_limit
  prometheus_operator_memory_limit   = var.prometheus_operator_memory_limit

  # ---------------------------------------------------------------------------
  # Alertmanager
  # ---------------------------------------------------------------------------

  alertmanager_enabled        = var.alertmanager_enabled
  alertmanager_replicas       = var.alertmanager_replicas
  alertmanager_cpu_request    = var.alertmanager_cpu_request
  alertmanager_memory_request = var.alertmanager_memory_request
  alertmanager_cpu_limit      = var.alertmanager_cpu_limit
  alertmanager_memory_limit   = var.alertmanager_memory_limit

  alertmanager_persistence_enabled = var.alertmanager_persistence_enabled
  alertmanager_storage_class_name  = var.alertmanager_storage_class_name
  alertmanager_storage_size        = var.alertmanager_storage_size

  # ---------------------------------------------------------------------------
  # Kubernetes Monitoring Components
  # ---------------------------------------------------------------------------

  default_rules_enabled      = var.prometheus_default_rules_enabled
  kube_state_metrics_enabled = var.prometheus_kube_state_metrics_enabled
  node_exporter_enabled      = var.prometheus_node_exporter_enabled
  kube_api_server_monitoring_enabled = (
    var.prometheus_kube_api_server_monitoring_enabled
  )
  kubelet_monitoring_enabled = var.prometheus_kubelet_monitoring_enabled
  core_dns_monitoring_enabled = (
    var.prometheus_core_dns_monitoring_enabled
  )
  kube_controller_manager_monitoring_enabled = (
    var.prometheus_kube_controller_manager_monitoring_enabled
  )
  kube_scheduler_monitoring_enabled = (
    var.prometheus_kube_scheduler_monitoring_enabled
  )
  kube_proxy_monitoring_enabled = var.prometheus_kube_proxy_monitoring_enabled

  # ---------------------------------------------------------------------------
  # kube-state-metrics Resources
  # ---------------------------------------------------------------------------

  kube_state_metrics_cpu_request    = var.prometheus_kube_state_metrics_cpu_request
  kube_state_metrics_memory_request = var.prometheus_kube_state_metrics_memory_request
  kube_state_metrics_cpu_limit      = var.prometheus_kube_state_metrics_cpu_limit
  kube_state_metrics_memory_limit   = var.prometheus_kube_state_metrics_memory_limit

  # ---------------------------------------------------------------------------
  # Node Exporter Resources
  # ---------------------------------------------------------------------------

  node_exporter_cpu_request    = var.prometheus_node_exporter_cpu_request
  node_exporter_memory_request = var.prometheus_node_exporter_memory_request
  node_exporter_cpu_limit      = var.prometheus_node_exporter_cpu_limit
  node_exporter_memory_limit   = var.prometheus_node_exporter_memory_limit

  # ===========================================================================
  # Grafana Phase 2
  # ===========================================================================

  grafana_enabled  = var.grafana_enabled
  grafana_replicas = var.grafana_replicas

  grafana_admin_user     = var.grafana_admin_user
  grafana_admin_password = var.grafana_admin_password

  grafana_persistence_enabled  = var.grafana_persistence_enabled
  grafana_storage_class_name   = var.grafana_storage_class_name
  grafana_storage_access_modes = var.grafana_storage_access_modes
  grafana_storage_size         = var.grafana_storage_size

  grafana_service_type = var.grafana_service_type
  grafana_service_port = var.grafana_service_port

  grafana_ingress_enabled = var.grafana_ingress_enabled
  grafana_root_url        = var.grafana_root_url

  grafana_default_dashboards_enabled  = var.grafana_default_dashboards_enabled
  grafana_default_dashboards_timezone = var.grafana_default_dashboards_timezone

  grafana_sidecar_dashboards_enabled  = var.grafana_sidecar_dashboards_enabled
  grafana_sidecar_datasources_enabled = var.grafana_sidecar_datasources_enabled

  grafana_disable_initial_admin_creation = var.grafana_disable_initial_admin_creation
  grafana_allow_sign_up                  = var.grafana_allow_sign_up
  grafana_anonymous_access_enabled       = var.grafana_anonymous_access_enabled
  grafana_user_auto_assign_org_role      = var.grafana_user_auto_assign_org_role

  grafana_cpu_request    = var.grafana_cpu_request
  grafana_memory_request = var.grafana_memory_request
  grafana_cpu_limit      = var.grafana_cpu_limit
  grafana_memory_limit   = var.grafana_memory_limit

  # ---------------------------------------------------------------------------
  # Istio Monitoring
  # ---------------------------------------------------------------------------

  istiod_service_monitor_enabled = var.istiod_service_monitor_enabled
  istio_namespace                = var.istio_namespace
  istio_revision                 = var.istio_revision
  istiod_metrics_port_name       = var.istiod_metrics_port_name
  istiod_metrics_path            = var.istiod_metrics_path
  istiod_scrape_interval         = var.istiod_scrape_interval
  istiod_scrape_timeout          = var.istiod_scrape_timeout


  # ---------------------------------------------------------------------------
  # Istio Ingress Gateway Monitoring
  # ---------------------------------------------------------------------------

  istio_ingress_pod_monitor_enabled = var.istio_ingress_pod_monitor_enabled
  istio_ingress_namespace           = var.istio_ingress_namespace
  istio_ingress_app_name            = var.istio_ingress_app_name
  istio_ingress_metrics_port        = var.istio_ingress_metrics_port
  istio_ingress_metrics_path        = var.istio_ingress_metrics_path
  istio_ingress_scrape_interval     = var.istio_ingress_scrape_interval
  istio_ingress_scrape_timeout      = var.istio_ingress_scrape_timeout

}

