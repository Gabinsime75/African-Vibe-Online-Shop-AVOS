#############################################
# AWS Organization
#############################################

output "organization_id" {

  description = "The ID of the AWS Organization."
  value       = data.aws_organizations_organization.this.id

}

output "organization_arn" {

  description = "The ARN of the AWS Organization."
  value       = data.aws_organizations_organization.this.arn

}

output "organization_root_id" {

  description = "The ID of the Organization Root."
  value       = data.aws_organizations_organization.this.roots[0].id

}

#############################################
# Organizational Units
#############################################

output "security_ou_id" {

  description = "The ID of the Security Organizational Unit."
  value       = var.create_security_ou ? aws_organizations_organizational_unit.security[0].id : null

}

output "infrastructure_ou_id" {

  description = "The ID of the Infrastructure Organizational Unit."
  value       = var.create_infrastructure_ou ? aws_organizations_organizational_unit.infrastructure[0].id : null

}

output "shared_services_ou_id" {

  description = "The ID of the Shared Services Organizational Unit."
  value       = var.create_shared_services_ou ? aws_organizations_organizational_unit.shared_services[0].id : null

}

output "logging_ou_id" {

  description = "The ID of the Logging Organizational Unit."
  value       = var.create_logging_ou ? aws_organizations_organizational_unit.logging[0].id : null

}

output "nonproduction_ou_id" {

  description = "The ID of the NonProduction Organizational Unit."
  value       = var.create_nonproduction_ou ? aws_organizations_organizational_unit.nonproduction[0].id : null

}

output "development_ou_id" {

  description = "The ID of the Development Organizational Unit."
  value       = var.create_development_ou ? aws_organizations_organizational_unit.development[0].id : null

}

output "testing_ou_id" {

  description = "The ID of the Testing Organizational Unit."
  value       = var.create_testing_ou ? aws_organizations_organizational_unit.testing[0].id : null

}

output "staging_ou_id" {

  description = "The ID of the Staging Organizational Unit."
  value       = var.create_staging_ou ? aws_organizations_organizational_unit.staging[0].id : null

}

output "production_ou_id" {

  description = "The ID of the Production Organizational Unit."
  value       = var.create_production_ou ? aws_organizations_organizational_unit.production[0].id : null

}

output "suspended_ou_id" {

  description = "The ID of the Suspended Organizational Unit."
  value       = var.create_suspended_ou ? aws_organizations_organizational_unit.suspended[0].id : null

}

#############################################
# Service Control Policies
#############################################

output "deny_root_user_policy_id" {

  description = "The ID of the Deny Root User Actions SCP."
  value       = aws_organizations_policy.deny_root_user.id

}

output "deny_cloudtrail_deletion_policy_id" {

  description = "The ID of the Deny CloudTrail Deletion SCP."
  value       = aws_organizations_policy.deny_cloudtrail_deletion.id

}

output "deny_leave_organization_policy_id" {

  description = "The ID of the Deny Leave Organization SCP."
  value       = aws_organizations_policy.deny_leave_organization.id

}

output "restrict_regions_policy_id" {

  description = "The ID of the Restrict AWS Regions SCP."
  value       = aws_organizations_policy.restrict_regions.id

}

output "require_ebs_encryption_policy_id" {

  description = "The ID of the Require EBS Encryption SCP."
  value       = aws_organizations_policy.require_ebs_encryption.id

}