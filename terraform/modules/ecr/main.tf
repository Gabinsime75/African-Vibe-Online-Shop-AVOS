# =============================================================================
# CloudHustler Commerce Platform
# Phase 8.1.1 - Amazon ECR Foundation
#
# Purpose:
# Creates the private Amazon ECR repository used by the CI pipeline to store
# versioned application container images.
#
# GitHub Actions will build and push immutable images here. Later, GitOps
# manifests will reference these images for Argo CD deployment to Amazon EKS.
# =============================================================================

resource "aws_ecr_repository" "this" {
  name = var.repository_name

  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    var.tags,
    {
      Name = var.repository_name
    }
  )
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep the most recent 30 application images"

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}