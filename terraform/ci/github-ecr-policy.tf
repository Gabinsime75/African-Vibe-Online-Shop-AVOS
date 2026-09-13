# =============================================================================
# CloudHustler Commerce Platform
# Phase 8.1.2 - GitHub Actions ECR Permissions
#
# Purpose:
# Grants the GitHub Actions CI role the minimum permissions required to
# authenticate to Amazon ECR and push application container images.
#
# Access is restricted to the ECR repositories currently onboarded into
# the CI pipeline.
# =============================================================================

data "aws_iam_policy_document" "github_actions_ecr" {

  statement {
    sid    = "ECRAuthentication"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "PushApplicationImages"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:BatchGetImage",
      "ecr:DescribeImages"
    ]

    resources = [
      module.frontend_ecr.repository_arn,
      module.checkoutservice_ecr.repository_arn,
      module.productcatalogservice_ecr.repository_arn,
      module.shippingservice_ecr.repository_arn,
      module.currencyservice_ecr.repository_arn,
      module.paymentservice_ecr.repository_arn,
      module.cartservice_ecr.repository_arn
    ]
  }
}

resource "aws_iam_policy" "github_actions_ecr" {
  name        = "${var.project_name}-${var.environment}-github-actions-ecr"
  description = "Allows GitHub Actions CI to push frontend images to Amazon ECR."

  policy = data.aws_iam_policy_document.github_actions_ecr.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions_ci.name
  policy_arn = aws_iam_policy.github_actions_ecr.arn
}