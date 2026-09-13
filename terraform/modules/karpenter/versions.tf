# =============================================================================
# CloudHustler Commerce Platform
# Karpenter Module Provider Requirements
# =============================================================================
# Defines the Terraform and provider versions required by the Karpenter module.
# =============================================================================

terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    helm = {
      source = "hashicorp/helm"
    }
  }
}