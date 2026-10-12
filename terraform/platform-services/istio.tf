# =============================================================================
# AVOS Phase 6.5 — Istio Control Plane and Ingress Gateway
# =============================================================================

locals {
  istio_chart_version = "1.30.5"
  istio_repository    = "https://istio-release.storage.googleapis.com/charts"

  istio_node_selector = {
    "eks.amazonaws.com/nodegroup" = "avos-dev-system"
  }
}

resource "kubernetes_namespace_v1" "istio_system" {
  metadata {
    name = "istio-system"

    labels = {
      "app.kubernetes.io/part-of" = "avos-platform"
      "istio-injection"           = "disabled"
    }
  }
}

resource "kubernetes_namespace_v1" "istio_ingress" {
  metadata {
    name = "istio-ingress"

    labels = {
      "app.kubernetes.io/part-of" = "avos-platform"
    }
  }
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  namespace  = kubernetes_namespace_v1.istio_system.metadata[0].name
  repository = local.istio_repository
  chart      = "base"
  version    = local.istio_chart_version

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  values = [
    yamlencode({
      defaultRevision           = "default"
      topologySpreadConstraints = local.istio_topology_spread.istiod
      global = {
        priorityClassName = "system-cluster-critical"
      }
    })
  ]
}

resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = kubernetes_namespace_v1.istio_system.metadata[0].name
  repository = local.istio_repository
  chart      = "istiod"
  version    = local.istio_chart_version

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  values = [
    yamlencode({
      replicaCount     = 2
      autoscaleEnabled = false
      nodeSelector     = local.istio_node_selector

      topologySpreadConstraints = local.istio_topology_spread.istiod

      global = {
        priorityClassName = "system-cluster-critical"
      }

      resources = {
        requests = {
          cpu    = "250m"
          memory = "512Mi"
        }
        limits = {
          cpu    = "1000m"
          memory = "1Gi"
        }
      }

      meshConfig = {
        accessLogFile = "/dev/stdout"
      }
    })
  ]

  depends_on = [
    helm_release.istio_base
  ]
}

resource "helm_release" "istio_ingress_gateway" {
  name       = "avos-ingress"
  namespace  = kubernetes_namespace_v1.istio_ingress.metadata[0].name
  repository = local.istio_repository
  chart      = "gateway"
  version    = local.istio_chart_version

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  values = [
    yamlencode({
      replicaCount              = 2
      nodeSelector              = local.istio_node_selector
      topologySpreadConstraints = local.istio_topology_spread.ingress
      priorityClassName         = "system-cluster-critical"

      autoscaling = {
        enabled = false
      }

      labels = {
        "gateway.networking.k8s.io/gateway-name" = "avos-gateway"
      }

      service = {
        type = "ClusterIP"

        ports = [
          {
            name       = "status-port"
            port       = 15021
            targetPort = 15021
            protocol   = "TCP"
          },
          {
            name       = "http2"
            port       = 80
            targetPort = 80
            protocol   = "TCP"
          },
          {
            name       = "https"
            port       = 443
            targetPort = 443
            protocol   = "TCP"
          }
        ]
      }

      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
    })
  ]

  depends_on = [
    helm_release.istiod
  ]
}
