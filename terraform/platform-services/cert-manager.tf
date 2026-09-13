###############################################################################
# Cert-Manager
###############################################################################

module "cert_manager" {
  source = "../modules/cert-manager"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  cluster_name = var.cluster_name

  namespace         = "cert-manager"
  helm_release_name = "cert-manager"
  chart_version     = "v1.21.0"

  replica_count            = 1
  webhook_replica_count    = 1
  cainjector_replica_count = 1

  domain_name     = "cloudhusller.com"
  route53_zone_id = "Z08118211LIG93KC7E5CI"
  route53_zone_arn = format(
    "arn:aws:route53:::hostedzone/%s",
    "Z08118211LIG93KC7E5CI"
  )

  create_cluster_issuers         = true
  create_staging_cluster_issuer  = true
  staging_cluster_issuer_name    = "letsencrypt-staging"
  production_cluster_issuer_name = "letsencrypt-prod"

  letsencrypt_email = "gabinsime@yahoo.com"

  tags = local.common_tags
}