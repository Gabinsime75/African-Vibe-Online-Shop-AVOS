# =============================================================================
# AVOS IAM Identity Center — Terraform and Provider Requirements
#
# Defines the supported Terraform CLI and AWS provider version boundaries for
# the identity root.
# =============================================================================

terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0, < 7.0.0"
    }
  }
}