resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "10.10.5"

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 900
  max_history     = 5

  values = [
    file("${path.module}/values/argocd.yaml"),
    file("${path.module}/values/argocd-boundaries.json")
  ]
}
