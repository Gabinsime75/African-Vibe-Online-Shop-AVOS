# =============================================================================
# AVOS Security Hub
#
# Enables AWS Security Hub CSPM in the AVOS home Region. Security standards
# are not enabled implicitly; they are managed separately through explicit
# Terraform resources.
# =============================================================================

resource "aws_securityhub_account" "this" {
  enable_default_standards  = false
  auto_enable_controls      = true
  control_finding_generator = "SECURITY_CONTROL"
}

# =============================================================================
# Security Hub Standards Subscriptions
#
# Each selected standard is independently managed through Terraform.
# =============================================================================

resource "aws_securityhub_standards_subscription" "this" {
  for_each = local.securityhub_standards

  standards_arn = each.value

  depends_on = [
    aws_securityhub_account.this
  ]
}