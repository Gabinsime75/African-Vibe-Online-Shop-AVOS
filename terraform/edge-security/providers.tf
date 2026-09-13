# =============================================================================
# CloudHustler Commerce Platform
# Phase 7 - Edge & Security
# AWS Providers
#
# Purpose:
# Configures the AWS providers used by the Edge & Security Terraform root.
#
# The default provider targets us-east-2, which is the primary AWS region for
# the CloudHustler Commerce Platform.
#
# A secondary aliased provider targets us-east-1 for CloudFront-specific
# resources that require that region, such as the CloudFront ACM certificate
# and CloudFront-scoped WAF resources in later Phase 7 steps.
# =============================================================================

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = var.tags
  }
}