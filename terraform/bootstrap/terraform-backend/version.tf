# =============================================================================
# AVOS Terraform Bootstrap — Version Requirements
#
# Defines the supported Terraform CLI and AWS provider versions for the
# independent AVOS remote-state bootstrap root.
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