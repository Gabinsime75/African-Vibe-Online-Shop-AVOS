# =============================================================================
# AVOS Container Platform — Local Values
#
# Derives consistent names, tags, cluster identifiers, add-on configuration,
# and node-group settings from the root input variables.
# =============================================================================

locals {
  name_prefix = "${var.project}-${var.environment}"

  cluster_name           = "${local.name_prefix}-eks"
  system_node_group_name = "${local.name_prefix}-system"

  eks_kms_alias_name     = "alias/${local.name_prefix}-eks"
  cluster_log_group_name = "/aws/eks/${local.cluster_name}/cluster"

  common_tags = merge(
    {
      Project       = upper(var.project)
      Environment   = var.environment
      ManagedBy     = "Terraform"
      Owner         = var.owner
      TerraformRoot = "container-platform"
      Workload      = "EKS"
    },
    var.additional_tags
  )

  required_addons = {
    for addon_name, addon_version in var.addon_versions :
    addon_name => {
      version = addon_version
    }
  }
}