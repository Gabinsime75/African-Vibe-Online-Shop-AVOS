output "github_oidc_provider_arn" {
  description = "IAM identity provider used for GitHub Actions."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_ci_role_arn" {
  description = "IAM role assumed by authorized AVOS CI runs."
  value       = aws_iam_role.github_ci.arn
}

output "trusted_github_subjects" {
  description = "Exact GitHub subjects allowed to assume the CI role."
  value       = local.trusted_subjects
}
