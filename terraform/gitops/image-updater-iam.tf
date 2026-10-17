locals {
  image_updater_service_account = "argocd-image-updater"

  image_updater_services = [
    "adservice",
    "cartservice",
    "checkoutservice",
    "currencyservice",
    "emailservice",
    "frontend",
    "loadgenerator",
    "paymentservice",
    "productcatalogservice",
    "recommendationservice",
    "shippingservice",
    "shoppingassistantservice"
  ]
}

data "aws_iam_policy_document" "image_updater_trust" {
  statement {
    sid    = "AVOSImageUpdaterPodIdentity"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-namespace"
      values   = [kubernetes_namespace_v1.argocd.metadata[0].name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-service-account"
      values   = [local.image_updater_service_account]
    }
  }
}

resource "aws_iam_role" "image_updater" {
  name                 = "avos-dev-image-updater"
  description          = "Read-only AVOS ECR access for Argo CD Image Updater"
  assume_role_policy   = data.aws_iam_policy_document.image_updater_trust.json
  max_session_duration = 3600
}

data "aws_iam_policy_document" "image_updater_ecr" {
  statement {
    sid       = "AuthenticateToECR"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ReadAVOSImages"
    effect = "Allow"

    actions = [
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer"
    ]

    resources = [
      for service in local.image_updater_services :
      "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/avos/dev/${service}"
    ]
  }
}

resource "aws_iam_role_policy" "image_updater_ecr" {
  name   = "avos-dev-image-updater-ecr-read"
  role   = aws_iam_role.image_updater.id
  policy = data.aws_iam_policy_document.image_updater_ecr.json
}

resource "aws_eks_pod_identity_association" "image_updater" {
  cluster_name    = var.cluster_name
  namespace       = kubernetes_namespace_v1.argocd.metadata[0].name
  service_account = local.image_updater_service_account
  role_arn        = aws_iam_role.image_updater.arn

  depends_on = [
    aws_iam_role_policy.image_updater_ecr
  ]
}
