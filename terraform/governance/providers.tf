# =============================================================================
# AVOS Governance — AWS Provider Configuration
#
# Restricts this root to the approved management account and applies mandatory
# tags to supported AWS resources.
# =============================================================================

provider "aws" {
  region = var.aws_region

  allowed_account_ids = [
    var.management_account_id
  ]

  default_tags {
    tags = local.common_tags
  }
}