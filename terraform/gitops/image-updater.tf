resource "helm_release" "image_updater" {
  name       = "argocd-image-updater"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-image-updater"
  version    = "1.3.2"

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 900
  max_history     = 5

  values = [
    file("${path.module}/values/image-updater.yaml"),
    yamlencode({
      podAnnotations = {
        "avos.dev/rbac-renderer-sha256" = filesha256("${path.module}/scripts/image-updater-postrender.py")
      }
    })
  ]

  postrender {
    binary_path = "python"
    args        = [abspath("${path.module}/scripts/image-updater-postrender.py")]
  }

  depends_on = [
    helm_release.argocd,
    aws_eks_pod_identity_association.image_updater
  ]
}
