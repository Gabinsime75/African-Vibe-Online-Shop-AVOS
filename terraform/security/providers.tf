# =============================================================================
# AVOS Security — AWS Provider Configuration
#
# Restricts the security root to the approved management account and applies
# mandatory AVOS tags to supported resources.
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