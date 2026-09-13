################################################################################
# ExternalDNS Module: Deploys ExternalDNS using Helm and authorizes it to manage DNS records inside the configured CloudHustler Route 53 hosted zone.
################################################################################
module "external_dns" {
  source = "../modules/external-dns"

  ##############################################################################
  # Platform Identification
  ##############################################################################

  platform_name = var.project_name

  ##############################################################################
  # EKS Cluster Configuration
  ##############################################################################

  cluster_name = var.cluster_name

  name = "${var.project_name}-${var.environment}-external-dns"

  namespace = var.external_dns_namespace

  service_account_name = var.external_dns_service_account_name


  ##############################################################################
  # Route 53 Configuration
  ##############################################################################

  hosted_zone_id = var.route53_hosted_zone_id

  domain_filters = var.external_dns_domain_filters

  aws_zone_type = var.external_dns_aws_zone_type


  ##############################################################################
  # DNS Synchronization Configuration
  ##############################################################################

  sources = var.external_dns_sources

  policy = var.external_dns_policy

  registry = var.external_dns_registry

  txt_owner_id = var.external_dns_txt_owner_id

  txt_prefix = var.external_dns_txt_prefix

  interval = var.external_dns_interval

  trigger_loop_on_event = var.external_dns_trigger_loop_on_event

  aws_batch_change_size = var.external_dns_aws_batch_change_size


  ##############################################################################
  # Helm Configuration
  ##############################################################################

  helm_repository = var.external_dns_helm_repository

  chart_name = var.external_dns_chart_name

  chart_version = var.external_dns_chart_version

  replica_count = var.external_dns_replica_count


  ##############################################################################
  # Logging and Observability
  ##############################################################################

  log_level = var.external_dns_log_level

  log_format = var.external_dns_log_format

  enable_service_monitor = var.external_dns_enable_service_monitor

  service_monitor_namespace = var.external_dns_service_monitor_namespace


  ##############################################################################
  # Kubernetes Scheduling and Resource Configuration
  ##############################################################################

  resources = var.external_dns_resources

  pod_labels = var.external_dns_pod_labels

  pod_annotations = var.external_dns_pod_annotations

  node_selector = var.external_dns_node_selector

  tolerations = var.external_dns_tolerations

  affinity = var.external_dns_affinity

  priority_class_name = var.external_dns_priority_class_name


  ##############################################################################
  # Extensibility
  ##############################################################################

  additional_helm_values = var.external_dns_additional_helm_values


  ##############################################################################
  # Standard AWS Tags
  ##############################################################################

  tags = local.common_tags
}