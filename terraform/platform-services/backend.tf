# =============================================================================
# AVOS Platform Services — Remote Terraform Backend
#
# Environment-specific settings are supplied through the ignored backend.hcl.
# =============================================================================

terraform {
  backend "s3" {}
}
