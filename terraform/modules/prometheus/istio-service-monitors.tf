# =============================================================================
# CloudHustler Commerce Platform - Istio ServiceMonitors
# =============================================================================
# This file configures Prometheus ServiceMonitor resources for the Istio
# service mesh.
#
# The resources implemented here allow Prometheus to scrape:
# - Istiod control-plane metrics
#
# Istio ingress gateway monitoring will be added after the gateway Service is
# deployed and its labels and metrics port have been validated.
# =============================================================================

# -----------------------------------------------------------------------------
# Istiod ServiceMonitor
# -----------------------------------------------------------------------------

resource "kubernetes_manifest" "istiod_service_monitor" {
  count = var.istiod_service_monitor_enabled ? 1 : 0

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"

    metadata = {
      name      = "${var.release_name}-istiod"
      namespace = var.namespace

      labels = merge(
        local.common_labels,
        {
          "app.kubernetes.io/name"      = "istiod"
          "app.kubernetes.io/component" = "service-monitor"
          "istio.io/rev"                = var.istio_revision
          "release"                     = var.release_name
        }
      )
    }

    spec = {
      namespaceSelector = {
        matchNames = [
          var.istio_namespace
        ]
      }

      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "istiod"
          "istio.io/rev"           = var.istio_revision
        }
      }

      endpoints = [
        {
          port     = var.istiod_metrics_port_name
          path     = var.istiod_metrics_path
          interval = var.istiod_scrape_interval

          scrapeTimeout = var.istiod_scrape_timeout

          scheme = "http"
        }
      ]
    }
  }

  depends_on = [
    helm_release.this
  ]
}