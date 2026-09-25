# =============================================================================
# AVOS IAM Identity Center — Group Memberships
#
# Manages workforce authorization through group membership. Direct user-to-
# account assignments are intentionally avoided.
# =============================================================================

resource "aws_identitystore_group_membership" "platform_admin" {
  identity_store_id = local.identity_store_id

  group_id  = aws_identitystore_group.this["platform_admins"].group_id
  member_id = data.aws_identitystore_user.platform_admin.user_id
}