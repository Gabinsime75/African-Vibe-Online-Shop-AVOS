# =============================================================================
# AVOS IAM Identity Center — AWS Provider Configuration
#
# Configures the Identity Center managing Region, restricts execution to the
# approved AWS Organizations management account, and applies standard tags.
# =============================================================================

provider "aws" {
  region = var.identity_center_region

  allowed_account_ids = [
    var.management_account_id
  ]

  default_tags {
    tags = local.common_tags
  }
}