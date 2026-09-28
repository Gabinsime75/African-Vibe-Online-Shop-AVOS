# =============================================================================
# AVOS Amazon Detective
#
# Creates the regional Detective behavior graph used to investigate GuardDuty
# findings and analyze relationships between AWS identities, resources,
# network activity, and API activity.
# =============================================================================

resource "aws_detective_graph" "this" {
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-detective"
    }
  )
}