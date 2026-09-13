#############################################
# 1. Security Hub Account
#############################################

resource "aws_securityhub_account" "this" {

  enable_default_standards = var.enable_default_standards

  control_finding_generator = var.control_finding_generator

  auto_enable_controls = var.auto_enable_controls

}

#############################################
# 2. AWS Foundational Security Best Practices
#############################################

resource "aws_securityhub_standards_subscription" "fsbp" {

  count = var.enable_fsbp_standard ? 1 : 0

  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"

  depends_on = [aws_securityhub_account.this]

}

#############################################
# Current Region
#############################################

data "aws_region" "current" {}