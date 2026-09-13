# =============================================================================
# CloudHustler Commerce Platform - Prometheus Module Configuration
# =============================================================================
# This file defines the shared local values used by the Prometheus module.
#
# The module deploys the Phase 1 monitoring foundation using the
# kube-prometheus-stack Helm chart:
#
# - Prometheus Operator
# - Prometheus server
# - Alertmanager
# - kube-state-metrics
# - Prometheus Node Exporter
# - Kubernetes monitoring and alerting rules
#
# Grafana is intentionally excluded from this phase and will be implemented
# separately during Phase 2.
# =============================================================================

# -----------------------------------------------------------------------------
# Resource Naming
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  prometheus_name   = "${local.name_prefix}-prometheus"
  alertmanager_name = "${local.name_prefix}-alertmanager"
  operator_name     = "${local.name_prefix}-prometheus-operator"
}

# -----------------------------------------------------------------------------
# Kubernetes Labels
# -----------------------------------------------------------------------------

locals {
  common_labels = {
    "app.kubernetes.io/managed-by" = "Terraform"
    "app.kubernetes.io/part-of"    = var.project_name
    "app.kubernetes.io/component"  = "monitoring"
    "app.kubernetes.io/instance"   = var.release_name
    "cloudhusller.com/environment" = var.environment
  }

  namespace_labels = merge(
    local.common_labels,
    {
      "app.kubernetes.io/name" = var.namespace
    }
  )
}

# -----------------------------------------------------------------------------
# Helm Release Metadata
# -----------------------------------------------------------------------------

locals {
  helm_release_metadata = {
    release_name     = var.release_name
    namespace        = var.namespace
    chart_name       = var.chart_name
    chart_repository = var.chart_repository
    chart_version    = var.chart_version
  }
}