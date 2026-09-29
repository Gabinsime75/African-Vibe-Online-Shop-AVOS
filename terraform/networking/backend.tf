# =============================================================================
# AVOS Network Foundation — Remote State Backend
#
# Declares the S3 backend. Environment-specific backend values are supplied
# during terraform init through an ignored backend.hcl file.
# =============================================================================

terraform {
  backend "s3" {}
}