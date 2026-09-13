###############################################################################
# Cert-Manager IAM Policy
###############################################################################

data "aws_iam_policy_document" "cert_manager" {
  statement {
    sid    = "AllowRoute53RecordChanges"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets"
    ]

    resources = [
      var.route53_zone_arn
    ]
  }

  statement {
    sid    = "AllowRoute53ChangeInspection"
    effect = "Allow"

    actions = [
      "route53:GetChange"
    ]

    resources = [
      "arn:aws:route53:::change/*"
    ]
  }

  statement {
    sid    = "AllowRoute53ZoneDiscovery"
    effect = "Allow"

    actions = [
      "route53:ListHostedZonesByName",
      "route53:ListResourceRecordSets"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "cert_manager" {
  name        = "${local.name_prefix}-cert-manager-route53"
  description = "Allows Cert-Manager to solve Route 53 DNS-01 ACME challenges."
  policy      = data.aws_iam_policy_document.cert_manager.json

  tags = local.common_tags
}

###############################################################################
# EKS Pod Identity IAM Role
###############################################################################

data "aws_iam_policy_document" "pod_identity_assume_role" {
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

resource "aws_iam_role" "cert_manager" {
  name               = "${local.name_prefix}-cert-manager-pod-identity"
  description        = "EKS Pod Identity role for Cert-Manager."
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "cert_manager" {
  role       = aws_iam_role.cert_manager.name
  policy_arn = aws_iam_policy.cert_manager.arn
}

###############################################################################
# EKS Pod Identity Association
###############################################################################

resource "aws_eks_pod_identity_association" "cert_manager" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = local.service_account_name
  role_arn        = aws_iam_role.cert_manager.arn

  depends_on = [
    helm_release.cert_manager,
    aws_iam_role_policy_attachment.cert_manager
  ]
}