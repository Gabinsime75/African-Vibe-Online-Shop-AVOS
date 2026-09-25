# =============================================================================
# AVOS IAM Identity Center — Existing AWS Data
#
# Discovers the current AWS account and the console-enabled IAM Identity Center
# organization instance. Postconditions prevent operation against unexpected
# accounts or Identity Center instances.
# =============================================================================

data "aws_caller_identity" "current" {
  lifecycle {
    postcondition {
      condition     = self.account_id == var.management_account_id
      error_message = "The active AWS credentials do not belong to the approved AVOS management account."
    }
  }
}

data "aws_ssoadmin_instances" "current" {
  lifecycle {
    postcondition {
      condition     = length(self.arns) == 1
      error_message = "Exactly one IAM Identity Center instance must be visible in the configured Region."
    }

    postcondition {
      condition     = contains(self.arns, var.expected_identity_center_instance_arn)
      error_message = "The discovered IAM Identity Center instance ARN does not match the approved AVOS instance."
    }

    postcondition {
      condition     = contains(self.identity_store_ids, var.expected_identity_store_id)
      error_message = "The discovered identity store ID does not match the approved AVOS identity store."
    }
  }
}