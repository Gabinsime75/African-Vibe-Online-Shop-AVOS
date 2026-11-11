# AVOS Identity Center restoration — existing-resource imports.
# Preserve existing access; review the plan before applying.

import {
  to = aws_identitystore_group.this["platform_admins"]
  id = "d-9a675ff325/617bb5b0-3001-7001-8d49-a01f9696ab8c"
}

import {
  to = aws_identitystore_group.this["security_auditors"]
  id = "d-9a675ff325/91fbd560-30d1-70d9-c69b-e600ac94dbc2"
}

import {
  to = aws_identitystore_group.this["developers"]
  id = "d-9a675ff325/a12bd550-20d1-7035-36cf-c5d323d510cd"
}

import {
  to = aws_identitystore_group.this["read_only"]
  id = "d-9a675ff325/313b35b0-a061-701f-23bb-5ac72bcafcd0"
}

import {
  to = aws_ssoadmin_permission_set.this["administrator"]
  id = "arn:aws:sso:::permissionSet/ssoins-66841b5fc329f2ea/ps-09271a2b9668edd7,arn:aws:sso:::instance/ssoins-66841b5fc329f2ea"
}

import {
  to = aws_ssoadmin_managed_policy_attachment.this["administrator:arn:aws:iam::aws:policy/AdministratorAccess"]
  id = "arn:aws:iam::aws:policy/AdministratorAccess,arn:aws:sso:::permissionSet/ssoins-66841b5fc329f2ea/ps-09271a2b9668edd7,arn:aws:sso:::instance/ssoins-66841b5fc329f2ea"
}

import {
  to = aws_ssoadmin_permission_set.this["security_audit"]
  id = "arn:aws:sso:::permissionSet/ssoins-66841b5fc329f2ea/ps-76765e15db192f49,arn:aws:sso:::instance/ssoins-66841b5fc329f2ea"
}

import {
  to = aws_ssoadmin_managed_policy_attachment.this["security_audit:arn:aws:iam::aws:policy/SecurityAudit"]
  id = "arn:aws:iam::aws:policy/SecurityAudit,arn:aws:sso:::permissionSet/ssoins-66841b5fc329f2ea/ps-76765e15db192f49,arn:aws:sso:::instance/ssoins-66841b5fc329f2ea"
}

import {
  to = aws_ssoadmin_permission_set.this["developer"]
  id = "arn:aws:sso:::permissionSet/ssoins-66841b5fc329f2ea/ps-7314a84c7c89ee86,arn:aws:sso:::instance/ssoins-66841b5fc329f2ea"
}

import {
  to = aws_ssoadmin_managed_policy_attachment.this["developer:arn:aws:iam::aws:policy/PowerUserAccess"]
  id = "arn:aws:iam::aws:policy/PowerUserAccess,arn:aws:sso:::permissionSet/ssoins-66841b5fc329f2ea/ps-7314a84c7c89ee86,arn:aws:sso:::instance/ssoins-66841b5fc329f2ea"
}

import {
  to = aws_ssoadmin_permission_set.this["read_only"]
  id = "arn:aws:sso:::permissionSet/ssoins-66841b5fc329f2ea/ps-f2135cc5041418d5,arn:aws:sso:::instance/ssoins-66841b5fc329f2ea"
}

import {
  to = aws_ssoadmin_managed_policy_attachment.this["read_only:arn:aws:iam::aws:policy/ReadOnlyAccess"]
  id = "arn:aws:iam::aws:policy/ReadOnlyAccess,arn:aws:sso:::permissionSet/ssoins-66841b5fc329f2ea/ps-f2135cc5041418d5,arn:aws:sso:::instance/ssoins-66841b5fc329f2ea"
}

import {
  to = aws_ssoadmin_account_assignment.this["platform_admins_management"]
  id = "617bb5b0-3001-7001-8d49-a01f9696ab8c,GROUP,396913735153,AWS_ACCOUNT,arn:aws:sso:::permissionSet/ssoins-66841b5fc329f2ea/ps-09271a2b9668edd7,arn:aws:sso:::instance/ssoins-66841b5fc329f2ea"
}

import {
  to = aws_ssoadmin_account_assignment.this["security_auditors_management"]
  id = "91fbd560-30d1-70d9-c69b-e600ac94dbc2,GROUP,396913735153,AWS_ACCOUNT,arn:aws:sso:::permissionSet/ssoins-66841b5fc329f2ea/ps-76765e15db192f49,arn:aws:sso:::instance/ssoins-66841b5fc329f2ea"
}

import {
  to = aws_identitystore_group_membership.platform_admin
  id = "d-9a675ff325/31fb4510-5001-70ab-e420-72d78155c6f5"
}
