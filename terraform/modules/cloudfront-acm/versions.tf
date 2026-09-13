# =============================================================================
# CloudHustler Commerce Platform
# Module: CloudFront ACM
# Terraform and Provider Requirements
#
# Purpose:
# Declares the Terraform and AWS provider requirements used by the CloudFront
# ACM module. The root module passes the aliased us-east-1 AWS provider to this
# child module because CloudFront viewer certificates must be created there.
# =============================================================================

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}