# =============================================================================
# AVOS Security — Derived Names and Common Tags
# =============================================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  access_analyzer_name = "${local.name_prefix}-external-access-analyzer"

  mandatory_tags = {
    Project     = upper(var.project_name)
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
    Repository  = var.repository_name
    Phase       = "3"
    Component   = "Security"
  }

  common_tags = merge(
    var.additional_tags,
    local.mandatory_tags
  )
}

# =============================================================================
# Amazon GuardDuty Feature Baseline
#
# These settings place the supported optional GuardDuty protection plans under
# Terraform management. Foundational data sources such as CloudTrail events,
# DNS logs, and VPC Flow Logs are managed automatically by the detector.
#
# Runtime Monitoring remains disabled until the AVOS EKS/ECS/EC2 workloads
# exist and the GuardDuty security agent deployment is designed.
# =============================================================================

locals {
  guardduty_detector_features = {
    S3_DATA_EVENTS         = "ENABLED"
    EKS_AUDIT_LOGS         = "ENABLED"
    EBS_MALWARE_PROTECTION = "ENABLED"
    RDS_LOGIN_EVENTS       = "ENABLED"
    LAMBDA_NETWORK_LOGS    = "ENABLED"
    RUNTIME_MONITORING     = "DISABLED"
  }

  guardduty_runtime_agent_features = {
    EC2_AGENT_MANAGEMENT         = "DISABLED"
    ECS_FARGATE_AGENT_MANAGEMENT = "DISABLED"
    EKS_ADDON_MANAGEMENT         = "DISABLED"
  }
}

# =============================================================================
# Security Hub Compliance Standards
#
# Standards are explicitly selected so Terraform—not AWS defaults—controls the
# AVOS compliance baseline.
# =============================================================================

locals {
  securityhub_standards = {
    aws_foundational_security_best_practices = "arn:${data.aws_partition.current.partition}:securityhub:${var.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0"

    cis_aws_foundations_benchmark = "arn:${data.aws_partition.current.partition}:securityhub:${var.aws_region}::standards/cis-aws-foundations-benchmark/v/3.0.0"
  }
}