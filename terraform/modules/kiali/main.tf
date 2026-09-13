# =============================================================================
# CloudHustler Commerce Platform
# Kiali Terraform Module
#
# This file deploys Kiali using the official Kiali Server Helm chart.
#
# Kiali provides the observability and management interface for the Istio
# service mesh. It connects to the existing Prometheus and Grafana services
# to visualize service-to-service traffic, request rates, latency, errors,
# mesh health, mTLS status, and Istio configuration.
#
# The module:
# - Reuses the existing istio-system namespace by default
# - Deploys the Kiali Server Helm chart
# - Connects Kiali to Prometheus
# - Connects Kiali to Grafana
# - Configures Istio namespace discovery
# - Exposes Kiali internally through a ClusterIP Service
# - Enables Prometheus metrics for Kiali itself
# =============================================================================

# -----------------------------------------------------------------------------
# Kiali Namespace
#
# The istio-system namespace is normally created by the Istio control-plane
# module. Namespace creation remains optional so this module can also support
# a dedicated Kiali namespace in other environments.
# -----------------------------------------------------------------------------

resource "kubernetes_namespace_v1" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace

    labels = merge(
      {
        "app.kubernetes.io/name"       = "kiali"
        "app.kubernetes.io/component"  = "service-mesh-observability"
        "app.kubernetes.io/part-of"    = var.project_name
        "app.kubernetes.io/managed-by" = "terraform"
        "environment"                  = var.environment
      },
      var.namespace_labels
    )
  }
}

# -----------------------------------------------------------------------------
# Kiali Helm Release
# -----------------------------------------------------------------------------

resource "helm_release" "this" {
  name       = var.release_name
  namespace  = var.namespace
  repository = var.chart_repository
  chart      = var.chart_name
  version    = var.chart_version

  create_namespace = false

  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  wait            = true
  timeout         = var.timeout

  values = [
    yamlencode({
      # -----------------------------------------------------------------------
      # Authentication
      #
      # Anonymous authentication is suitable only for the current internal
      # development environment. Production should use OpenID, OAuth, or
      # another supported identity provider.
      # -----------------------------------------------------------------------

      auth = {
        strategy = var.auth_strategy
      }

      # -----------------------------------------------------------------------
      # Deployment Configuration
      # -----------------------------------------------------------------------

      deployment = {
        instance_name = var.instance_name

        replicas = var.replica_count

        accessible_namespaces = var.accessible_namespaces

        resources = {
          requests = {
            cpu    = var.cpu_request
            memory = var.memory_request
          }

          limits = {
            cpu    = var.cpu_limit
            memory = var.memory_limit
          }
        }

        node_selector = var.node_selector
        tolerations   = var.tolerations
        affinity      = var.affinity

        pod_labels = {
          "app.kubernetes.io/part-of" = var.project_name
          "environment"               = var.environment
        }
      }

      # -----------------------------------------------------------------------
      # Istio Configuration
      # -----------------------------------------------------------------------

      istio_namespace = var.istio_namespace

      # -----------------------------------------------------------------------
      # External Services
      #
      # Kiali uses Prometheus as its primary metrics source. Grafana integration
      # provides direct links from Kiali metric views to the existing Grafana
      # deployment.
      # -----------------------------------------------------------------------

      external_services = {
        prometheus = {
          enabled = true
          url     = var.prometheus_url
        }

        grafana = {
          enabled        = var.grafana_enabled
          in_cluster_url = var.grafana_in_cluster_url
          url            = var.grafana_external_url
        }

        tracing = {
          enabled = var.tracing_enabled
        }
      }

      # -----------------------------------------------------------------------
      # Kubernetes API Access
      # -----------------------------------------------------------------------

      kubernetes_config = {
        cluster_name = var.cluster_name
      }

      # -----------------------------------------------------------------------
      # Server Configuration
      # -----------------------------------------------------------------------

      server = {
        port     = var.server_port
        web_root = var.web_root

        metrics_enabled = var.metrics_enabled
        metrics_port    = var.metrics_port

        observability = {
          metrics = {
            enabled = var.metrics_enabled
          }
        }
      }

      # -----------------------------------------------------------------------
      # Kubernetes Service
      #
      # Kiali remains internal to the cluster during the initial deployment.
      # External access can later be provided through Istio Gateway and
      # VirtualService resources.
      # -----------------------------------------------------------------------

      service = {
        type = var.service_type

        annotations = var.service_annotations
      }

      # -----------------------------------------------------------------------
      # Ingress
      #
      # Direct Kubernetes Ingress is disabled because Istio is the platform
      # ingress and service-mesh routing layer.
      # -----------------------------------------------------------------------

      ingress = {
        enabled = false
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.this
  ]
}