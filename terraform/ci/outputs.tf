output "frontend_ecr_repository_name" {
  description = "Frontend ECR repository name."
  value       = module.frontend_ecr.repository_name
}

output "frontend_ecr_repository_url" {
  description = "Frontend ECR repository URL."
  value       = module.frontend_ecr.repository_url
}

output "frontend_ecr_repository_arn" {
  description = "Frontend ECR repository ARN."
  value       = module.frontend_ecr.repository_arn
}

output "github_actions_role_arn" {
  description = "IAM role assumed by GitHub Actions through OIDC."
  value       = aws_iam_role.github_actions_ci.arn
}

output "github_oidc_provider_arn" {
  description = "GitHub Actions IAM OIDC provider ARN."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "cartservice_ecr_repository_name" {
  description = "CartService ECR repository name."
  value       = module.cartservice_ecr.repository_name
}

output "cartservice_ecr_repository_url" {
  description = "CartService ECR repository URL."
  value       = module.cartservice_ecr.repository_url
}

output "cartservice_ecr_repository_arn" {
  description = "CartService ECR repository ARN."
  value       = module.cartservice_ecr.repository_arn
}