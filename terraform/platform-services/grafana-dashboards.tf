# =============================================================================
# CloudHustler Commerce Platform
# Grafana Dashboards
# =============================================================================
#
# This file deploys the CloudHustler Grafana dashboards.
#
# Dashboards are provisioned as Kubernetes ConfigMaps and automatically
# imported into Grafana through the kube-prometheus-stack dashboard sidecar.
#
# This module contains:
#
# • Kubernetes Platform dashboards
# • Prometheus dashboards
# • Istio dashboards
# • Loki dashboards
# • OpenTelemetry dashboards
# • AWS CloudWatch dashboards
#
# No Grafana API credentials are required because dashboards are imported
# directly by the Grafana sidecar.
#
# =============================================================================

module "grafana_dashboards" {

  source = "../modules/grafana-dashboards"

  # ---------------------------------------------------------------------------
  # Project Configuration
  # ---------------------------------------------------------------------------

  project_name = var.project_name
  environment  = var.environment

  # ---------------------------------------------------------------------------
  # Namespace
  # ---------------------------------------------------------------------------

  namespace = var.grafana_dashboards_namespace

  # ---------------------------------------------------------------------------
  # Dashboard Naming
  # ---------------------------------------------------------------------------

  configmap_name_prefix = var.grafana_dashboard_configmap_prefix

  dashboard_folder = var.grafana_dashboard_folder

  # ---------------------------------------------------------------------------
  # Dashboard Sidecar Discovery
  # ---------------------------------------------------------------------------

  sidecar_label       = var.grafana_dashboard_sidecar_label
  sidecar_label_value = var.grafana_dashboard_sidecar_label_value

  # ---------------------------------------------------------------------------
  # Metadata
  # ---------------------------------------------------------------------------

  additional_labels = var.grafana_dashboard_labels

  additional_annotations = var.grafana_dashboard_annotations

  # ---------------------------------------------------------------------------
  # Dependencies
  #
  # Dashboards are imported only after Grafana, Prometheus, Loki,
  # Kiali and the OpenTelemetry Collector are operational.
  # ---------------------------------------------------------------------------

  depends_on = [

    module.prometheus,
    module.loki,
    module.kiali,
    module.opentelemetry_collector

  ]

}