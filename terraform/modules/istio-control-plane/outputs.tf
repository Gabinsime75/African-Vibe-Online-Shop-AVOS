###############################################################
# Istio Base Outputs
###############################################################

output "base_release_name" {
  description = "Name of the Istio base Helm release."
  value       = helm_release.base.name
}

output "base_release_namespace" {
  description = "Namespace containing the Istio base release."
  value       = helm_release.base.namespace
}

output "base_release_status" {
  description = "Status of the Istio base Helm release."
  value       = helm_release.base.status
}

###############################################################
# Istiod Outputs
###############################################################

output "istiod_release_name" {
  description = "Name of the Istiod Helm release."
  value       = helm_release.istiod.name
}

output "istiod_release_namespace" {
  description = "Namespace containing Istiod."
  value       = helm_release.istiod.namespace
}

output "istiod_release_status" {
  description = "Status of the Istiod Helm release."
  value       = helm_release.istiod.status
}

output "chart_version" {
  description = "Istio chart version installed by the module."
  value       = var.chart_version
}

output "revision" {
  description = "Istio control-plane revision."
  value       = var.revision
}

output "namespace" {
  description = "Namespace containing the Istio control plane."
  value       = var.namespace
}