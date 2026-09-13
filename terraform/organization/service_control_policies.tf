
# Deny Root User Actions SCP
resource "aws_organizations_policy" "deny_root_user" {
  name        = "DenyRootUserActions"
  description = "Prevents the AWS account root user from performing administrative actions."
  type        = "SERVICE_CONTROL_POLICY"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyRootUser"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = "arn:aws:iam::*:root"
          }
        }
      }
    ]
  })
}


# Deny CloudTrail Deletion SCP
resource "aws_organizations_policy" "deny_cloudtrail_deletion" {
  name        = "DenyCloudTrailDeletion"
  description = "Prevents CloudTrail trails from being deleted or modified."
  type        = "SERVICE_CONTROL_POLICY"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ProtectCloudTrail"
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging",
          "cloudtrail:UpdateTrail"
        ]

        Resource = "*"
      }
    ]
  })
}


# Deny Leaving Organization SCP
resource "aws_organizations_policy" "deny_leave_organization" {
  name        = "DenyLeaveOrganization"
  description = "Prevents member accounts from leaving the AWS Organization."
  type        = "SERVICE_CONTROL_POLICY"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyLeaveOrganization"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      }
    ]
  })
}


# Restrict AWS Regions SCP
resource "aws_organizations_policy" "restrict_regions" {
  name        = "RestrictAWSRegions"
  description = "Restricts resource creation outside approved AWS Regions."
  type        = "SERVICE_CONTROL_POLICY"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyUnsupportedRegions"
        Effect = "Deny"

        NotAction = [
          "iam:*",
          "organizations:*",
          "route53:*",
          "cloudfront:*",
          "support:*"
        ]

        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = [
              "us-east-1",
              "us-east-2"
            ]
          }
        }
      }
    ]
  })
}


# Require Encrypted EBS Volumes SCP
resource "aws_organizations_policy" "require_ebs_encryption" {

  name        = "RequireEBSEncryption"
  description = "Prevents creation of unencrypted EBS volumes."
  type        = "SERVICE_CONTROL_POLICY"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {

        Sid    = "RequireEncryptedEBS"
        Effect = "Deny"

        Action = [
          "ec2:CreateVolume",
          "ec2:RunInstances"
        ]

        Resource = "*"
        Condition = {
          Bool = {
            "ec2:Encrypted" = "false"
          }
        }
      }
    ]
  })
}