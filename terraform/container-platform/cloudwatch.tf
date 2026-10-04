# =============================================================================
# AVOS Container Platform — EKS Control-Plane Logs
#
# Creates the encrypted CloudWatch Logs group used by the EKS API server,
# audit, authenticator, controller manager, and scheduler logs.
# =============================================================================

resource "aws_cloudwatch_log_group" "eks_control_plane" {
  name = local.cluster_log_group_name

  retention_in_days = var.cluster_log_retention_days
  kms_key_id        = aws_kms_key.eks.arn
  log_group_class   = "STANDARD"

  tags = {
    Name    = "${local.cluster_name}-control-plane"
    Purpose = "EKSControlPlaneLogs"
  }
}