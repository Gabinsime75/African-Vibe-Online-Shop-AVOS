# =============================================================================
# AVOS Terraform Bootstrap — AWS Provider Configuration
#
# Configures the AWS Region and mandatory default tags for every supported
# resource created by this bootstrap root.
# =============================================================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}