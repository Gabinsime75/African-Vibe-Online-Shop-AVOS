output "namespace" {
  description = "Namespace where Argo CD is installed."
  value       = kubernetes_namespace_v1.argocd.metadata[0].name
}

output "release_name" {
  description = "Argo CD Helm release name."
  value       = helm_release.argocd.name
}

output "chart_version" {
  description = "Installed Argo CD Helm chart version."
  value       = helm_release.argocd.version
}