# =============================================================================
# CloudHustler Commerce Platform - Grafana Administrator Secret
# =============================================================================
# This file creates the Kubernetes Secret that stores the Grafana
# administrator credentials.
#
# The kube-prometheus-stack Helm chart is configured to reference this
# existing secret rather than embedding credentials directly in the Helm
# values.
#
# NOTE:
# The Secret is managed by Terraform and stored in the monitoring namespace.
# =============================================================================

# -----------------------------------------------------------------------------
# Grafana Administrator Secret
# -----------------------------------------------------------------------------

resource "kubernetes_secret_v1" "grafana_admin" {
  count = var.grafana_enabled ? 1 : 0

  metadata {
    name      = "${var.release_name}-grafana-admin"
    namespace = var.namespace

    labels = local.common_labels
  }

  type = "Opaque"

  data = {
    admin-user     = var.grafana_admin_user
    admin-password = var.grafana_admin_password
  }
}