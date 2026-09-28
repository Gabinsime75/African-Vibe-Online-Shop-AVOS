# =============================================================================
# AVOS AWS Organizations — Service Control Policy Attachments
#
# SCP definitions and attachments are intentionally separate. New policies
# are first attached only to Policy-Staging for controlled validation.
# =============================================================================

resource "aws_organizations_policy_attachment" "deny_leave_organization_policy_staging" {
  policy_id = aws_organizations_policy.deny_leave_organization.id
  target_id = aws_organizations_organizational_unit.top_level["policy_staging"].id
}