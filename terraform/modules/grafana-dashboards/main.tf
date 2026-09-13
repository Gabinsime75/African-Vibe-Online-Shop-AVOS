# =============================================================================
# CloudHustler Commerce Platform
# Grafana Dashboards Terraform Module
#
# This file provisions Grafana dashboards as Kubernetes ConfigMaps.
#
# The Grafana dashboard sidecar deployed by kube-prometheus-stack watches for
# ConfigMaps containing the configured dashboard label. When a matching
# ConfigMap is created, the sidecar reads the embedded JSON file and imports
# the dashboard automatically into Grafana.
#
# Each dashboard is stored in a separate ConfigMap to:
# - Avoid the Kubernetes ConfigMap size limit
# - Isolate dashboard updates
# - Simplify troubleshooting
# - Keep dashboard JSON separate from Terraform code
# =============================================================================

# -----------------------------------------------------------------------------
# Dashboard Files
#
# Discover every JSON dashboard stored under the dashboards directory.
# -----------------------------------------------------------------------------

locals {
  dashboard_files = fileset(
    "${path.module}/dashboards",
    "*.json"
  )

  dashboard_names = {
    for dashboard_file in local.dashboard_files :
    dashboard_file => trimsuffix(
      basename(dashboard_file),
      ".json"
    )
  }
}

# -----------------------------------------------------------------------------
# Grafana Dashboard ConfigMaps
#
# One ConfigMap is created for each JSON dashboard file.
#
# The default Grafana Helm chart dashboard sidecar watches for ConfigMaps
# labeled with:
#
#   grafana_dashboard = "1"
#
# The JSON filename becomes the dashboard file mounted into the Grafana
# dashboard provisioning directory.
# -----------------------------------------------------------------------------

resource "kubernetes_config_map_v1" "dashboard" {
  for_each = local.dashboard_names

  metadata {
    name      = "${var.configmap_name_prefix}-${each.value}"
    namespace = var.namespace

    labels = merge(
      {
        (var.sidecar_label) = var.sidecar_label_value

        "app.kubernetes.io/name"       = "grafana-dashboard"
        "app.kubernetes.io/component"  = "observability"
        "app.kubernetes.io/part-of"    = var.project_name
        "app.kubernetes.io/managed-by" = "terraform"
        "environment"                  = var.environment
        "cloudhusller.com/dashboard"   = each.value
      },
      var.additional_labels
    )

    annotations = merge(
      {
        "cloudhusller.com/dashboard-source" = each.key
        "cloudhusller.com/dashboard-folder" = var.dashboard_folder
      },
      var.additional_annotations
    )
  }

  data = {
    basename(each.key) = file(
      "${path.module}/dashboards/${each.key}"
    )
  }
}