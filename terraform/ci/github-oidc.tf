locals {
  github_oidc_host = "token.actions.githubusercontent.com"

  github_subject_prefix = "repo:Gabinsime75@115108532/African-Vibe-Online-Shop-AVOS@1368914543"

  trusted_branches = var.enable_validation_branch ? [
    "main",
    "phase-7-ci-supply-chain"
  ] : ["main"]

  trusted_subjects = [
    for branch in local.trusted_branches :
    "${local.github_subject_prefix}:ref:refs/heads/${branch}"
  ]
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://${local.github_oidc_host}"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name = "avos-github-actions"
  }
}

data "aws_iam_policy_document" "github_ci_trust" {
  statement {
    sid     = "AVOSGitHubBranchAuthentication"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_host}:sub"
      values   = local.trusted_subjects
    }
  }
}

resource "aws_iam_role" "github_ci" {
  name                 = "avos-dev-github-ci"
  description          = "AVOS GitHub Actions CI authentication through OIDC"
  assume_role_policy   = data.aws_iam_policy_document.github_ci_trust.json
  max_session_duration = 3600

  tags = {
    Name = "avos-dev-github-ci"
  }
}
