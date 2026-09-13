resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/name"       = "argocd"
      "app.kubernetes.io/part-of"    = var.project_name
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
    }
  }
}

resource "helm_release" "argocd" {
  name = var.release_name

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  namespace = kubernetes_namespace_v1.argocd.metadata[0].name

  # Wait for the Argo CD components to become healthy before
  # Terraform considers the Helm release successfully deployed.
  wait    = true
  timeout = 900

  # Keep the Argo CD API server internal.
  set = [
    {
      name  = "server.service.type"
      value = var.server_service_type
    },
    # Start with a single replica in dev.
    # HA can be enabled later for staging/prod.
    {
      name  = "controller.replicas"
      value = "1"
    },
    {
      name  = "server.replicas"
      value = "1"
    },
    {
      name  = "repoServer.replicas"
      value = "1"
    }
  ]
  # SSO is intentionally deferred.
  # Native Argo CD authentication is sufficient for the initial foundation.
}