# =============================================================================
# CloudHustler Commerce Platform
# Grafana Dashboards Module Outputs
#
# This file exports the dashboard ConfigMap names, discovered dashboard files,
# namespace, Grafana sidecar discovery settings, and dashboard count for
# validation and platform-level outputs.
# =============================================================================

# -----------------------------------------------------------------------------
# Dashboard Discovery Outputs
# -----------------------------------------------------------------------------

output "dashboard_files" {
  description = "Dashboard JSON files discovered by the module."
  value       = sort(tolist(local.dashboard_files))
}

output "dashboard_names" {
  description = "Logical dashboard names derived from the JSON filenames."
  value = sort([
    for dashboard_name in values(local.dashboard_names) :
    dashboard_name
  ])
}

output "dashboard_count" {
  description = "Number of Grafana dashboards managed by the module."
  value       = length(local.dashboard_files)
}

# -----------------------------------------------------------------------------
# ConfigMap Outputs
# -----------------------------------------------------------------------------

output "configmap_names" {
  description = "Names of the Kubernetes ConfigMaps containing Grafana dashboards."
  value = sort([
    for configmap in kubernetes_config_map_v1.dashboard :
    configmap.metadata[0].name
  ])
}

output "configmap_ids" {
  description = "Kubernetes resource IDs of the Grafana dashboard ConfigMaps."
  value = {
    for dashboard_file, configmap in kubernetes_config_map_v1.dashboard :
    dashboard_file => configmap.id
  }
}

# -----------------------------------------------------------------------------
# Namespace Outputs
# -----------------------------------------------------------------------------

output "namespace" {
  description = "Kubernetes namespace containing the dashboard ConfigMaps."
  value       = var.namespace
}

# -----------------------------------------------------------------------------
# Grafana Sidecar Outputs
# -----------------------------------------------------------------------------

output "sidecar_label" {
  description = "ConfigMap label watched by the Grafana dashboard sidecar."
  value       = var.sidecar_label
}

output "sidecar_label_value" {
  description = "Value assigned to the Grafana dashboard discovery label."
  value       = var.sidecar_label_value
}

# -----------------------------------------------------------------------------
# Dashboard Organization Outputs
# -----------------------------------------------------------------------------

output "dashboard_folder" {
  description = "Logical Grafana folder configured for the dashboards."
  value       = var.dashboard_folder
}

output "configmap_name_prefix" {
  description = "Prefix used for the Grafana dashboard ConfigMaps."
  value       = var.configmap_name_prefix
}