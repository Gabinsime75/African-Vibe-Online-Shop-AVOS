# =============================================================================
# AVOS IAM Identity Center — AWS Account Assignments
#
# Assigns approved group-based permission sets to approved AWS accounts.
# Direct user assignments are intentionally prohibited by design.
# =============================================================================

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = local.initial_account_assignments

  instance_arn       = local.identity_center_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_key].arn

  principal_id   = aws_identitystore_group.this[each.value.group_key].group_id
  principal_type = "GROUP"

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"

  depends_on = [
    aws_ssoadmin_managed_policy_attachment.this
  ]
}