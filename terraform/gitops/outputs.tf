output "argocd_namespace" {
  description = "Namespace containing the AVOS GitOps controllers."
  value       = kubernetes_namespace_v1.argocd.metadata[0].name
}

output "argocd_server_service" {
  description = "ClusterIP service used for initial administrative access."
  value       = "argocd-server"
}

output "argocd_chart_version" {
  description = "Pinned Argo CD Helm chart version."
  value       = helm_release.argocd.version
}
