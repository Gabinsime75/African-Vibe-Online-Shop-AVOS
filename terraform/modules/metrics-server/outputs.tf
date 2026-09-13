output "release_name" {
  description = "Metrics Server Helm release name."
  value       = helm_release.this.name
}

output "release_namespace" {
  description = "Namespace containing Metrics Server."
  value       = helm_release.this.namespace
}

output "release_status" {
  description = "Metrics Server Helm release status."
  value       = helm_release.this.status
}

output "chart_version" {
  description = "Installed Metrics Server chart version."
  value       = helm_release.this.version
}

output "service_account_name" {
  description = "Metrics Server service account name."
  value       = var.service_account_name
}