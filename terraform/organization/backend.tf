# =============================================================================
# AVOS AWS Organizations — Remote State Backend
#
# Declares an S3 backend. Environment-specific values are supplied through
# backend.hcl, which remains outside source control.
# =============================================================================

terraform {
  backend "s3" {}
}