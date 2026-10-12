# =============================================================================
# AVOS Phase 6.9 — Platform Controller Resilience
# =============================================================================

resource "kubernetes_pod_disruption_budget_v1" "istio_ingress" {
  metadata {
    name      = "avos-ingress"
    namespace = kubernetes_namespace_v1.istio_ingress.metadata[0].name

    labels = {
      "app.kubernetes.io/part-of" = "avos-platform"
    }
  }

  spec {
    min_available = "1"

    selector {
      match_labels = {
        app = "avos-ingress"
      }
    }
  }

  depends_on = [
    helm_release.istio_ingress_gateway
  ]
}

locals {
  cert_manager_disruption_budgets = {
    controller = {
      name      = "avos-cert-manager-controller"
      component = "controller"
      pod_name  = "cert-manager"
    }
    cainjector = {
      name      = "avos-cert-manager-cainjector"
      component = "cainjector"
      pod_name  = "cainjector"
    }
    webhook = {
      name      = "avos-cert-manager-webhook"
      component = "webhook"
      pod_name  = "webhook"
    }
  }
}

resource "kubernetes_pod_disruption_budget_v1" "cert_manager" {
  for_each = local.cert_manager_disruption_budgets

  metadata {
    name      = each.value.name
    namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name

    labels = {
      "app.kubernetes.io/part-of" = "avos-platform"
    }
  }

  spec {
    min_available = "1"

    selector {
      match_labels = {
        "app.kubernetes.io/component" = each.value.component
        "app.kubernetes.io/instance"  = "cert-manager"
        "app.kubernetes.io/name"      = each.value.pod_name
      }
    }
  }

  depends_on = [
    helm_release.cert_manager
  ]
}

resource "kubernetes_pod_disruption_budget_v1" "external_secrets_webhook" {
  metadata {
    name      = "avos-external-secrets-webhook"
    namespace = kubernetes_namespace_v1.external_secrets.metadata[0].name

    labels = {
      "app.kubernetes.io/part-of" = "avos-platform"
    }
  }

  spec {
    min_available = "1"

    selector {
      match_labels = {
        "app.kubernetes.io/instance" = "external-secrets"
        "app.kubernetes.io/name"     = "external-secrets-webhook"
      }
    }
  }

  depends_on = [
    helm_release.external_secrets
  ]
}

locals {
  controller_spread_selectors = {
    cert_manager_controller = {
      "app.kubernetes.io/instance"  = "cert-manager"
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "cert-manager"
    }
    cert_manager_cainjector = {
      "app.kubernetes.io/instance"  = "cert-manager"
      "app.kubernetes.io/component" = "cainjector"
      "app.kubernetes.io/name"      = "cainjector"
    }
    cert_manager_webhook = {
      "app.kubernetes.io/instance"  = "cert-manager"
      "app.kubernetes.io/component" = "webhook"
      "app.kubernetes.io/name"      = "webhook"
    }
    external_secrets_controller = {
      "app.kubernetes.io/instance" = "external-secrets"
      "app.kubernetes.io/name"     = "external-secrets"
    }
    external_secrets_webhook = {
      "app.kubernetes.io/instance" = "external-secrets"
      "app.kubernetes.io/name"     = "external-secrets-webhook"
    }
    load_balancer_controller = {
      "app.kubernetes.io/instance" = "aws-load-balancer-controller"
      "app.kubernetes.io/name"     = "aws-load-balancer-controller"
    }
  }

  controller_topology_spread = {
    for name, selector in local.controller_spread_selectors :
    name => [
      for topology in [
        "kubernetes.io/hostname",
        "topology.kubernetes.io/zone"
        ] : {
        maxSkew           = 1
        topologyKey       = topology
        whenUnsatisfiable = "ScheduleAnyway"
        matchLabelKeys    = ["pod-template-hash"]

        labelSelector = {
          matchLabels = selector
        }
      }
    ]
  }
}

locals {
  istio_spread_selectors = {
    istiod = {
      istio = "pilot"
    }
    ingress = {
      app   = "avos-ingress"
      istio = "avos-ingress"
    }
  }

  istio_topology_spread = {
    for name, selector in local.istio_spread_selectors :
    name => [
      for topology in [
        "kubernetes.io/hostname",
        "topology.kubernetes.io/zone"
        ] : {
        maxSkew           = 1
        topologyKey       = topology
        whenUnsatisfiable = "ScheduleAnyway"
        matchLabelKeys    = ["pod-template-hash"]

        labelSelector = {
          matchLabels = selector
        }
      }
    ]
  }
}
