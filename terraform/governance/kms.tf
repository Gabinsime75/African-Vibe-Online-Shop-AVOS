###############################################################
# Governance KMS Key
###############################################################

module "governance_kms" {

  source = "../modules/kms"

  description = "Customer-managed KMS key for Governance services."

  alias = local.governance_kms_key_alias

  enable_key_rotation = true

  deletion_window_in_days = 30

  tags = local.common_tags

}