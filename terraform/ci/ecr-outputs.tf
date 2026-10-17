output "ecr_repository_urls" {
  description = "Service-specific AVOS ECR publication destinations."
  value = {
    for service, repository in aws_ecr_repository.service :
    service => repository.repository_url
  }
}

output "ecr_repository_arns" {
  description = "Service-specific AVOS ECR repository ARNs."
  value = {
    for service, repository in aws_ecr_repository.service :
    service => repository.arn
  }
}

output "ecr_kms_key_arn" {
  description = "Customer-managed key encrypting AVOS container images."
  value       = aws_kms_key.ecr.arn
}
