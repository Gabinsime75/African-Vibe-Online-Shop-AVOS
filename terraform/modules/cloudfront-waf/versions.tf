# =============================================================================
# CloudHustler Commerce Platform
# Phase 7.7 - CloudFront WAF
#
# Purpose:
# Defines the Terraform and AWS provider requirements for the CloudFront WAF
# module.
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}