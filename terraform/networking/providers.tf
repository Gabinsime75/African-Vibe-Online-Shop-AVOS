# =============================================================================
# AVOS Network Foundation — AWS Provider Configuration
#
# Configures the AWS deployment Region, account guardrail, and default tags
# inherited by supported resources in this Terraform root.
# =============================================================================

provider "aws" {
  region = var.aws_region

  allowed_account_ids = [
    var.aws_account_id
  ]

  default_tags {
    tags = local.common_tags
  }
}