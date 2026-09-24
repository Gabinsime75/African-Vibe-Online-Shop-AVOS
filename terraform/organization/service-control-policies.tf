# =============================================================================
# AVOS AWS Organizations — Service Control Policies
#
# Defines preventive organization guardrails. Policies are created separately
# from their attachments so each enforcement decision can be reviewed safely.
# =============================================================================

resource "aws_organizations_policy" "deny_leave_organization" {
  name        = "AVOS-Deny-Leave-Organization"
  description = "Prevents member accounts from leaving the AVOS AWS Organization."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "DenyLeavingOrganization"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name    = "AVOS-Deny-Leave-Organization"
      Purpose = "Organization membership protection"
    }
  )
}