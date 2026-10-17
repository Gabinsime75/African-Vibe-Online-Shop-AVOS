locals {
  gitops_repository_url = "https://github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS.git"
}

resource "kubernetes_manifest" "bootstrap_project" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"

    metadata = {
      name      = "avos-bootstrap"
      namespace = kubernetes_namespace_v1.argocd.metadata[0].name

      labels = {
        "app.kubernetes.io/part-of"    = "avos"
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }

    spec = {
      description = "Administrative bootstrap for AVOS GitOps configuration"

      sourceRepos = [
        local.gitops_repository_url
      ]

      destinations = [
        {
          server    = "https://kubernetes.default.svc"
          namespace = kubernetes_namespace_v1.argocd.metadata[0].name
        }
      ]

      clusterResourceWhitelist = []

      clusterResourceBlacklist = [
        {
          group = "*"
          kind  = "*"
        }
      ]

      namespaceResourceWhitelist = [
        {
          group = "argoproj.io"
          kind  = "AppProject"
        },
        {
          group = "argoproj.io"
          kind  = "Application"
        },
        {
          group = "argoproj.io"
          kind  = "ApplicationSet"
        },
        {
          group = "argocd-image-updater.argoproj.io"
          kind  = "ImageUpdater"
        }
      ]
    }
  }

  depends_on = [
    helm_release.argocd
  ]
}

resource "kubernetes_manifest" "root_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = "avos-root"
      namespace = kubernetes_namespace_v1.argocd.metadata[0].name

      labels = {
        "app.kubernetes.io/part-of"    = "avos"
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }

    spec = {
      project = "avos-bootstrap"

      source = {
        repoURL        = local.gitops_repository_url
        targetRevision = "main"
        path           = "gitops/argocd/root"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = kubernetes_namespace_v1.argocd.metadata[0].name
      }

      syncPolicy = {
        syncOptions = [
          "PruneLast=true",
          "FailOnSharedResource=true"
        ]
      }
    }
  }

  depends_on = [
    kubernetes_manifest.bootstrap_project
  ]
}
