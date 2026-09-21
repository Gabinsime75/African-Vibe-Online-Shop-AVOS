# =============================================================================
# AVOS Terraform Bootstrap — Remote State Backend
#
# Declares a partial S3 backend. Environment-specific values are supplied from
# an ignored backend.hcl file during terraform init.
# =============================================================================

terraform {
  backend "s3" {}
}