# =============================================================================
# AVOS Governance — CloudTrail
#
# Creates the account-scoped, multi-Region trail that records management-plane
# activity across the AVOS management account.
# =============================================================================

resource "aws_cloudtrail" "management" {
  name = local.cloudtrail_name

  s3_bucket_name = aws_s3_bucket.audit_logs.id
  kms_key_id     = aws_kms_key.audit_logs.arn

  enable_logging                = true
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = false

  event_selector {
    include_management_events = true
    read_write_type           = "All"
  }

  depends_on = [
    aws_kms_key.audit_logs,
    aws_s3_bucket_policy.audit_logs,
    aws_s3_bucket_server_side_encryption_configuration.audit_logs,
    aws_s3_bucket_versioning.audit_logs
  ]

  tags = {
    Name           = local.cloudtrail_name
    DataClass      = "AuditEvidence"
    SecurityDomain = "Governance"
  }
}