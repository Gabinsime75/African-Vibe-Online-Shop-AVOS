# =============================================================================
# Fluent Bit Module Outputs
# =============================================================================

output "namespace" {
  description = "Fluent Bit namespace."
  value       = var.namespace
}

output "release_name" {
  description = "Fluent Bit Helm release name."
  value       = helm_release.this.name
}

output "chart_version" {
  description = "Installed Fluent Bit chart version."
  value       = helm_release.this.version
}