# =============================================================================
# AVOS IAM Identity Center — Existing Workforce Users
#
# Discovers console-created workforce users. Terraform does not create or
# delete human identities; it manages their authorization relationships.
# =============================================================================

data "aws_identitystore_user" "platform_admin" {
  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = var.platform_admin_user_name
    }
  }

  lifecycle {
    postcondition {
      condition     = self.user_name == var.platform_admin_user_name
      error_message = "The discovered platform administrator does not match the configured username."
    }
  }
}