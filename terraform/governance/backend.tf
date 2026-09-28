# =============================================================================
# AVOS Governance — Remote State Backend
#
# Backend values are supplied through the ignored backend.hcl file during
# terraform init. Partial configuration prevents account-specific values from
# being committed to the repository.
# =============================================================================

terraform {
  backend "s3" {}
}