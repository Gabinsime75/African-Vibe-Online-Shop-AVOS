# =============================================================================
# AVOS IAM Identity Center — Remote State Backend
#
# Backend values are supplied during terraform init from an ignored backend.hcl
# file. This keeps environment-specific values outside committed source.
# =============================================================================

terraform {
  backend "s3" {}
}