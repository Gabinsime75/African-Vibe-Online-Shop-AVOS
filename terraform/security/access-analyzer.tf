# =============================================================================
# AVOS IAM Access Analyzer
#
# Detects resource-based policies that grant public or cross-account access
# outside the AVOS management account's zone of trust.
# =============================================================================

resource "aws_accessanalyzer_analyzer" "external_access" {
  analyzer_name = "${local.name_prefix}-external-access"
  type          = "ACCOUNT"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-external-access"
    }
  )
}