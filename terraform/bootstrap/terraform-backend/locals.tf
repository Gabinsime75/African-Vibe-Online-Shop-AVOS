# =============================================================================
# AVOS Terraform Bootstrap — Local Values
#
# Derives consistent resource names and mandatory tags from validated inputs.
# =============================================================================

locals {
  name_prefix         = "${var.project_name}-${var.environment}"
  state_bucket_name   = "${local.name_prefix}-tfstate-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
  bootstrap_state_key = "bootstrap/terraform.tfstate"

  common_tags = merge(
    var.additional_tags,
    {
      Project     = "AVOS"
      Application = "African-Vibe-Online-Shop"
      Environment = var.environment
      Owner       = var.owner
      ManagedBy   = "Terraform"
      Repository  = "African-Vibe-Online-Shop-AVOS"
      Component   = "terraform-bootstrap"
    }
  )
}