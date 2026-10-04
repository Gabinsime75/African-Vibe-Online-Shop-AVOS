# =============================================================================
# AVOS Container Platform — Remote Terraform Backend
#
# The environment-specific backend values are supplied through the ignored
# backend.hcl file during terraform init.
# =============================================================================

terraform {
  backend "s3" {}
}