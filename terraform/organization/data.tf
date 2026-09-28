# =============================================================================
# AVOS AWS Organizations — Account and Organization Discovery
#
# Reads the active AWS account and organization, then verifies that Terraform
# is operating against the approved management boundary.
# =============================================================================

data "aws_caller_identity" "current" {
  lifecycle {
    postcondition {
      condition     = self.account_id == var.management_account_id
      error_message = "The active AWS credentials do not belong to the approved management account."
    }
  }
}

data "aws_organizations_organization" "current" {
  lifecycle {
    postcondition {
      condition     = self.id == var.expected_organization_id
      error_message = "The active AWS account does not belong to the approved AVOS organization."
    }
  }
}