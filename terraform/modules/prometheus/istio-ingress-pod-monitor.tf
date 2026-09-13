# =============================================================================
# CloudHustler Commerce Platform - Istio Ingress PodMonitor
# =============================================================================
# This file configures Prometheus to scrape metrics directly from the Istio
# ingress gateway pods.
#
# The gateway Helm Service does not expose the Prometheus metrics port.
# Therefore, this PodMonitor scrapes the Istio proxy directly on:
#
# - Port: 15020
# - Path: /stats/prometheus
# =============================================================================

# -----------------------------------------------------------------------------
# Istio Ingress Gateway PodMonitor
# -----------------------------------------------------------------------------

resource "kubernetes_manifest" "istio_ingress_pod_monitor" {
  count = var.istio_ingress_pod_monitor_enabled ? 1 : 0

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PodMonitor"

    metadata = {
      name      = "${var.release_name}-istio-ingress"
      namespace = var.namespace

      labels = merge(
        local.common_labels,
        {
          "app.kubernetes.io/name"      = "istio-ingress"
          "app.kubernetes.io/component" = "pod-monitor"
          release                       = var.release_name
        }
      )
    }

    spec = {
      namespaceSelector = {
        matchNames = [
          var.istio_ingress_namespace
        ]
      }

      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = var.istio_ingress_app_name
        }
      }

      podMetricsEndpoints = [
        {
          portNumber = var.istio_ingress_metrics_port
          path       = var.istio_ingress_metrics_path
          scheme     = "http"

          interval      = var.istio_ingress_scrape_interval
          scrapeTimeout = var.istio_ingress_scrape_timeout
        }
      ]
    }
  }

  depends_on = [
    helm_release.this
  ]
}