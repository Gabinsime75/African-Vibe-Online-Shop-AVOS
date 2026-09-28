# =============================================================================
# AVOS IAM Identity Center — Outputs
#
# Exposes identifiers needed for validation, documentation, and future
# Terraform roots. No credentials or sensitive user data are returned.
# =============================================================================

output "identity_center_region" {
  description = "AWS Region containing the AVOS IAM Identity Center instance."
  value       = var.identity_center_region
}

output "identity_center_instance_arn" {
  description = "ARN of the AVOS IAM Identity Center organization instance."
  value       = local.identity_center_instance_arn
}

output "identity_store_id" {
  description = "Identity Store ID associated with the AVOS Identity Center instance."
  value       = local.identity_store_id
}

output "group_ids" {
  description = "IAM Identity Center group IDs indexed by their Terraform keys."
  value = {
    for key, group in aws_identitystore_group.this :
    key => group.group_id
  }
}

output "permission_set_arns" {
  description = "IAM Identity Center permission-set ARNs indexed by their Terraform keys."
  value = {
    for key, permission_set in aws_ssoadmin_permission_set.this :
    key => permission_set.arn
  }
}

output "account_assignment_ids" {
  description = "Identity Center account-assignment IDs indexed by assignment key."
  value = {
    for key, assignment in aws_ssoadmin_account_assignment.this :
    key => assignment.id
  }
}

output "platform_admin_user" {
  description = "Initial AVOS platform administrator discovered in Identity Center."
  value = {
    user_name = data.aws_identitystore_user.platform_admin.user_name
    user_id   = data.aws_identitystore_user.platform_admin.user_id
    group_id  = aws_identitystore_group.this["platform_admins"].group_id
  }
}