module "argocd" {
  source = "../modules/argocd"

  namespace     = "argocd"
  release_name  = "argocd"
  chart_version = "10.4.0"

  environment  = var.environment
  project_name = "cloudhusller-commerce-platform"

  # Keep the Argo CD server internal during the foundation phase.
  server_service_type = "ClusterIP"
}