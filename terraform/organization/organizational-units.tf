# =============================================================================
# AVOS AWS Organizations — Organizational Units
#
# Creates the approved six top-level OUs and the three environment OUs nested
# beneath Workloads. This configuration does not create or move AWS accounts.
# =============================================================================

resource "aws_organizations_organizational_unit" "top_level" {
  for_each = local.top_level_ous

  name      = each.value.name
  parent_id = data.aws_organizations_organization.current.roots[0].id

  tags = merge(
    local.common_tags,
    {
      Name    = each.value.name
      Purpose = each.value.purpose
      Level   = "Top-Level"
    }
  )

  lifecycle {
    precondition {
      condition = toset([
        for ou in values(local.top_level_ous) : ou.name
        ]) == toset([
        "Security",
        "Infrastructure",
        "Workloads",
        "Sandbox",
        "Policy-Staging",
        "Suspended"
      ])

      error_message = "The top-level OU hierarchy differs from the approved ADR-002 model."
    }
  }
}

resource "aws_organizations_organizational_unit" "workload" {
  for_each = local.workload_ous

  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.top_level["workloads"].id

  tags = merge(
    local.common_tags,
    {
      Name    = each.value.name
      Purpose = each.value.purpose
      Level   = "Workload-Environment"
    }
  )

  lifecycle {
    precondition {
      condition = toset([
        for ou in values(local.workload_ous) : ou.name
        ]) == toset([
        "Development",
        "Staging",
        "Production"
      ])

      error_message = "The workload OU hierarchy differs from the approved ADR-002 model."
    }
  }
}