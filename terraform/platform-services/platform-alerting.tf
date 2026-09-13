# =============================================================================
# CloudHustler Commerce Platform
# Platform Alerting
#
# Purpose:
# Integrates the reusable platform-alerting module with the platform-services
# root and deploys custom PrometheusRule resources into the monitoring
# namespace.
# =============================================================================

module "platform_alerting" {
  source = "../modules/platform-alerting"

  project_name = var.project_name
  environment  = var.environment
  namespace    = "monitoring"

  kubernetes_alerts_enabled    = true
  prometheus_alerts_enabled    = true
  loki_alerts_enabled          = true
  opentelemetry_alerts_enabled = true
  istio_alerts_enabled         = true
  application_alerts_enabled   = true

  depends_on = [
    module.prometheus,
    module.loki,
    module.opentelemetry_collector
  ]
}