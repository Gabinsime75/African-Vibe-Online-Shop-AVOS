# =============================================================================
# AVOS Security — AWS Account and Organization Discovery
# =============================================================================

data "aws_caller_identity" "current" {
  lifecycle {
    postcondition {
      condition     = self.account_id == var.management_account_id
      error_message = "The active credentials do not belong to the approved AVOS management account."
    }
  }
}

data "aws_partition" "current" {}

data "aws_organizations_organization" "current" {
  lifecycle {
    postcondition {
      condition     = self.id == var.organization_id
      error_message = "The active account does not belong to the expected AWS Organization."
    }
  }
}