# =============================================================================
# AVOS AWS Organizations — Outputs
#
# Exposes stable identifiers required by validation and later Terraform roots.
# =============================================================================

output "top_level_organizational_unit_ids" {
  description = "Map of AVOS top-level OU logical names to AWS Organizations OU IDs."

  value = {
    for name, organizational_unit in aws_organizations_organizational_unit.top_level :
    name => organizational_unit.id
  }
}

output "workload_organizational_unit_ids" {
  description = "Map of AVOS workload environment names to AWS Organizations OU IDs."

  value = {
    for name, organizational_unit in aws_organizations_organizational_unit.workload :
    name => organizational_unit.id
  }
}

output "policy_staging_organizational_unit_id" {
  description = "AWS Organizations ID of the Policy-Staging OU."
  value       = aws_organizations_organizational_unit.top_level["policy_staging"].id
}

output "deny_leave_organization_policy_id" {
  description = "AWS Organizations policy ID of the deny-leave-organization SCP."
  value       = aws_organizations_policy.deny_leave_organization.id
}

output "deny_leave_organization_attachment_id" {
  description = "Terraform identifier for the Policy-Staging SCP attachment."
  value       = aws_organizations_policy_attachment.deny_leave_organization_policy_staging.id
}