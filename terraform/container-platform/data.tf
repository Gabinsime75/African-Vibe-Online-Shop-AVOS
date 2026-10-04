# =============================================================================
# AVOS Container Platform — Data Sources
#
# Discovers the active AWS account and partition and consumes the validated
# Phase 4 networking outputs from its independent remote Terraform state.
# =============================================================================

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket     = var.network_state_bucket
    key        = var.network_state_key
    region     = var.aws_region
    encrypt    = true
    kms_key_id = var.terraform_state_kms_key_arn
  }
}

data "aws_eks_cluster_auth" "current" {
  name = aws_eks_cluster.this.name
}