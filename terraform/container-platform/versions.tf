# =============================================================================
# AVOS Container Platform — Terraform and Provider Requirements
#
# Defines the Terraform CLI and AWS provider versions supported by the AVOS
# EKS container-platform root.
# =============================================================================

terraform {
  required_version = ">= 1.11, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }
}