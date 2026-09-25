# =============================================================================
# AVOS IAM Identity Center — AWS-Managed Policy Attachments
#
# Attaches approved AWS-managed IAM policies to the AVOS permission sets.
# Account assignments are managed separately.
# =============================================================================

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = {
    for attachment in flatten([
      for permission_set_key, permission_set in local.permission_sets : [
        for managed_policy_arn in permission_set.managed_policy_arns : {
          key                = "${permission_set_key}:${managed_policy_arn}"
          permission_set_key = permission_set_key
          managed_policy_arn = managed_policy_arn
        }
      ]
    ]) : attachment.key => attachment
  }

  instance_arn       = local.identity_center_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_key].arn
  managed_policy_arn = each.value.managed_policy_arn
}