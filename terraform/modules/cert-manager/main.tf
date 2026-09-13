###############################################################################
# Local Values
###############################################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  service_account_name = "cert-manager"

  common_labels = {
    "app.kubernetes.io/managed-by" = "Terraform"
    "app.kubernetes.io/part-of"    = var.project_name
    environment                    = var.environment
  }

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "cert-manager"
    },
    var.tags
  )
}