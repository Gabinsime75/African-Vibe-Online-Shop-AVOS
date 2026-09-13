# =============================================================================
# CloudHustler Commerce Platform
# Phase 8.1.2 - GitHub OIDC Authentication
#
# Purpose:
# Establishes federated trust between GitHub Actions and AWS so workflows can
# assume a short-lived IAM role without storing long-lived AWS access keys.
# =============================================================================

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = var.tags
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    sid    = "GitHubActionsOIDC"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${var.github_owner}/${var.github_repository}:ref:refs/heads/${var.github_branch}"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_ci" {
  name = "${var.project_name}-${var.environment}-github-actions-ci"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = var.tags
}