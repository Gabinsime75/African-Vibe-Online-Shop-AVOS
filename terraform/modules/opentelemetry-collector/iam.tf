# =============================================================================
# CloudHustler Commerce Platform
# OpenTelemetry Collector IAM Configuration
#
# This file creates the optional AWS IAM resources required when the
# OpenTelemetry Collector exports distributed traces to AWS X-Ray.
#
# The configuration creates:
# - An IAM role trusted by Amazon EKS Pod Identity
# - A least-privilege AWS X-Ray write policy
# - A policy attachment for the Collector IAM role
# - An EKS Pod Identity association connecting the Kubernetes service account
#   to the IAM role
#
# No IAM resources are created when AWS X-Ray integration is disabled.
# =============================================================================

# -----------------------------------------------------------------------------
# EKS Pod Identity Trust Policy
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "pod_identity_assume_role" {
  count = var.aws_xray_enabled ? 1 : 0

  statement {
    sid    = "AllowEksPodIdentity"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

# -----------------------------------------------------------------------------
# OpenTelemetry Collector IAM Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "this" {
  count = var.aws_xray_enabled ? 1 : 0

  name               = var.iam_role_name
  description        = "IAM role used by the OpenTelemetry Collector to export traces to AWS X-Ray."
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume_role[0].json

  permissions_boundary = var.permissions_boundary_arn

  tags = merge(
    {
      Name                               = var.iam_role_name
      Environment                        = var.environment
      Project                            = var.project_name
      Service                            = "opentelemetry-collector"
      "app.kubernetes.io/name"           = "opentelemetry-collector"
      "app.kubernetes.io/component"      = "observability"
      "app.kubernetes.io/managed-by"     = "terraform"
      "cloudhusller.com/aws-integration" = "xray"
    },
    var.iam_tags
  )
}

# -----------------------------------------------------------------------------
# AWS X-Ray Permissions Policy
#
# The Collector requires permission to upload trace segment documents and
# Collector telemetry records to AWS X-Ray.
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "xray" {
  count = var.aws_xray_enabled ? 1 : 0

  statement {
    sid    = "AllowXRayTraceExport"
    effect = "Allow"

    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]

    resources = [
      "*"
    ]
  }
}

# -----------------------------------------------------------------------------
# AWS X-Ray IAM Policy
# -----------------------------------------------------------------------------

resource "aws_iam_policy" "xray" {
  count = var.aws_xray_enabled ? 1 : 0

  name        = var.iam_policy_name
  description = "Allows the OpenTelemetry Collector to export distributed traces to AWS X-Ray."
  policy      = data.aws_iam_policy_document.xray[0].json

  tags = merge(
    {
      Name                           = var.iam_policy_name
      Environment                    = var.environment
      Project                        = var.project_name
      Service                        = "opentelemetry-collector"
      "app.kubernetes.io/managed-by" = "terraform"
    },
    var.iam_tags
  )
}

# -----------------------------------------------------------------------------
# IAM Policy Attachment
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "xray" {
  count = var.aws_xray_enabled ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.xray[0].arn
}

# -----------------------------------------------------------------------------
# EKS Pod Identity Association
#
# This association maps the OpenTelemetry Collector Kubernetes service account
# to the IAM role. The Collector receives short-lived AWS credentials without
# storing static access keys in Kubernetes.
# -----------------------------------------------------------------------------

resource "aws_eks_pod_identity_association" "this" {
  count = var.aws_xray_enabled ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account_name
  role_arn        = aws_iam_role.this[0].arn

  tags = merge(
    {
      Name                           = "${var.release_name}-xray-pod-identity"
      Environment                    = var.environment
      Project                        = var.project_name
      Service                        = "opentelemetry-collector"
      "app.kubernetes.io/managed-by" = "terraform"
    },
    var.iam_tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.xray
  ]
}