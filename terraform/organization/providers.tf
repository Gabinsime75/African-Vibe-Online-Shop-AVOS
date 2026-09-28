# =============================================================================
# AVOS AWS Organizations — AWS Provider Configuration
#
# Configures the AWS provider for organization management and restricts this
# Terraform root to the approved AWS Organizations management account.
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