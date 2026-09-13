#############################################
# Deny Root User Actions
#############################################

resource "aws_organizations_policy_attachment" "deny_root_user" {

  policy_id = aws_organizations_policy.deny_root_user.id
  target_id = data.aws_organizations_organization.this.roots[0].id

}

#############################################
# Deny CloudTrail Deletion
#############################################

resource "aws_organizations_policy_attachment" "deny_cloudtrail_deletion" {

  count = var.create_security_ou ? 1 : 0

  policy_id = aws_organizations_policy.deny_cloudtrail_deletion.id
  target_id = aws_organizations_organizational_unit.security[0].id

}

#############################################
# Deny Leaving Organization
#############################################

resource "aws_organizations_policy_attachment" "deny_leave_organization" {

  policy_id = aws_organizations_policy.deny_leave_organization.id
  target_id = data.aws_organizations_organization.this.roots[0].id

}

#############################################
# Restrict AWS Regions
#############################################

resource "aws_organizations_policy_attachment" "restrict_regions_nonproduction" {

  count = var.create_nonproduction_ou ? 1 : 0

  policy_id = aws_organizations_policy.restrict_regions.id
  target_id = aws_organizations_organizational_unit.nonproduction[0].id

}

resource "aws_organizations_policy_attachment" "restrict_regions_production" {

  count = var.create_production_ou ? 1 : 0

  policy_id = aws_organizations_policy.restrict_regions.id
  target_id = aws_organizations_organizational_unit.production[0].id

}

#############################################
# Require EBS Encryption
#############################################

resource "aws_organizations_policy_attachment" "require_ebs_encryption_nonproduction" {

  count = var.create_nonproduction_ou ? 1 : 0

  policy_id = aws_organizations_policy.require_ebs_encryption.id
  target_id = aws_organizations_organizational_unit.nonproduction[0].id

}

resource "aws_organizations_policy_attachment" "require_ebs_encryption_production" {

  count = var.create_production_ou ? 1 : 0

  policy_id = aws_organizations_policy.require_ebs_encryption.id
  target_id = aws_organizations_organizational_unit.production[0].id

}