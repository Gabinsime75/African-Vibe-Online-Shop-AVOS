# =============================================================================
# CloudHustler Commerce Platform
# Phase 8.1.1 - Amazon ECR Foundation
#
# Purpose:
# Creates the application container registries used by the GitHub Actions
# continuous integration pipeline.
#
# Frontend was the initial pilot application. The remaining Go services are
# now being onboarded to the validated reusable CI pattern.
# =============================================================================

module "frontend_ecr" {
  source = "../modules/ecr"

  repository_name = "${var.project_name}-${var.environment}/frontend"

  tags = var.tags
}

module "checkoutservice_ecr" {
  source = "../modules/ecr"

  repository_name = "${var.project_name}-${var.environment}/checkoutservice"

  tags = var.tags
}

module "productcatalogservice_ecr" {
  source = "../modules/ecr"

  repository_name = "${var.project_name}-${var.environment}/productcatalogservice"

  tags = var.tags
}

module "shippingservice_ecr" {
  source = "../modules/ecr"

  repository_name = "${var.project_name}-${var.environment}/shippingservice"

  tags = var.tags
}

module "currencyservice_ecr" {
  source = "../modules/ecr"

  repository_name = "${var.project_name}-${var.environment}/currencyservice"

  tags = var.tags
}

module "paymentservice_ecr" {
  source = "../modules/ecr"

  repository_name = "${var.project_name}-${var.environment}/paymentservice"

  tags = var.tags
}

module "cartservice_ecr" {
  source = "../modules/ecr"

  repository_name = "${var.project_name}-${var.environment}/cartservice"

  tags = var.tags
}