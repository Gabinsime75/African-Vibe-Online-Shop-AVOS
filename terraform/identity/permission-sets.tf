# =============================================================================
# AVOS IAM Identity Center — Permission Sets
#
# Creates reusable access templates. Managed policies and AWS account
# assignments are declared separately to keep responsibilities explicit.
# =============================================================================

resource "aws_ssoadmin_permission_set" "this" {
  for_each = local.permission_sets

  instance_arn     = local.identity_center_instance_arn
  name             = each.value.name
  description      = each.value.description
  session_duration = each.value.session_duration

  tags = merge(
    local.common_tags,
    {
      Name = each.value.name
    }
  )
}