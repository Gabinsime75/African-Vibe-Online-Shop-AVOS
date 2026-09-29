# =============================================================================
# AVOS Network Foundation — Terraform and Provider Requirements
#
# Defines the Terraform CLI compatibility range and the provider dependencies
# required by the AVOS network root.
# =============================================================================

terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}