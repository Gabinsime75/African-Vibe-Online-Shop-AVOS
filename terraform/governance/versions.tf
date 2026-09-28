# =============================================================================
# AVOS Governance — Terraform and Provider Requirements
#
# Establishes the Terraform CLI and AWS provider compatibility contract for
# the governance root.
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