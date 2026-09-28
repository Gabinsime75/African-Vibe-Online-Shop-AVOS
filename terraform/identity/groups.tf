# =============================================================================
# AVOS IAM Identity Center — Workforce Groups
#
# Creates role-based groups in the built-in Identity Center directory. AWS
# account access is granted separately through group-based assignments.
# =============================================================================

resource "aws_identitystore_group" "this" {
  for_each = local.identity_groups

  identity_store_id = local.identity_store_id
  display_name      = each.value.display_name
  description       = each.value.description
}