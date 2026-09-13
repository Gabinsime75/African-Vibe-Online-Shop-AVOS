# =============================================================================
# CloudHustler Commerce Platform - Prometheus Namespace
# =============================================================================
# This file creates the Kubernetes namespace used by the Prometheus monitoring
# stack.
#
# Resources deployed into this namespace include:
# - Prometheus Operator
# - Prometheus Server
# - Alertmanager
# - kube-state-metrics
# - Prometheus Node Exporter
#
# Grafana will be added during Phase 2.
# =============================================================================

# -----------------------------------------------------------------------------
# Monitoring Namespace
# -----------------------------------------------------------------------------

resource "kubernetes_namespace" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name   = var.namespace
    labels = local.namespace_labels
  }
}