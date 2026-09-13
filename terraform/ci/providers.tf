# =============================================================================
# CloudHustler Commerce Platform
# Phase 8 - CI Infrastructure
# AWS Provider
# =============================================================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}