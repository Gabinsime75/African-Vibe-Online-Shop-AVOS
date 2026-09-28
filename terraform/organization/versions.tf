# =============================================================================
# AVOS AWS Organizations — Terraform and Provider Requirements
#
# Defines the Terraform CLI and provider versions supported by this root.
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