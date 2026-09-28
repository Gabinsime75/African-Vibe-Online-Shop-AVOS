# =============================================================================
# AVOS Security — Amazon GuardDuty
#
# Enables foundational regional threat detection. Additional GuardDuty
# protection plans are managed separately after detector creation.
# =============================================================================

resource "aws_guardduty_detector" "this" {
  enable                       = true
  finding_publishing_frequency = var.guardduty_finding_publishing_frequency

  tags = {
    Name           = "${local.name_prefix}-guardduty"
    SecurityDomain = "ThreatDetection"
  }
}

# =============================================================================
# Amazon GuardDuty Optional Protection Plans
#
# Each map entry becomes a separately managed detector feature. This lets
# Terraform detect drift and allows individual features to be changed without
# replacing the GuardDuty detector.
# =============================================================================

resource "aws_guardduty_detector_feature" "this" {
  for_each = local.guardduty_detector_features

  detector_id = aws_guardduty_detector.this.id
  name        = each.key
  status      = each.value

  dynamic "additional_configuration" {
    for_each = each.key == "RUNTIME_MONITORING" ? local.guardduty_runtime_agent_features : {}

    content {
      name   = additional_configuration.key
      status = additional_configuration.value
    }
  }
}