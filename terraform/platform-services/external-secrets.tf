################################################################################
# External Secrets Operator
#
# This module deploys the External Secrets Operator into the Amazon EKS cluster.
# It integrates Kubernetes with AWS Secrets Manager using Amazon EKS Pod
# Identity, allowing workloads to consume secrets without storing AWS
# credentials inside the cluster.
################################################################################

module "external_secrets" {

  source = "../modules/external-secrets"

  ##############################################################################
  # Platform
  ##############################################################################

  platform_name = var.project_name

  name = "external-secrets"

  tags = local.common_tags

  ##############################################################################
  # EKS
  ##############################################################################

  cluster_name = var.cluster_name

  namespace = "external-secrets"

  service_account_name = "external-secrets"

  ##############################################################################
  # AWS
  ##############################################################################

  aws_region = var.aws_region

  enable_secrets_manager = true

  enable_parameter_store = false

  secrets_manager_secret_arns = [
    "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:cloudhustler/dev/*"
  ]

  parameter_store_parameter_arns = []

  kms_key_arns = []

  ##############################################################################
  # Cluster Secret Store
  ##############################################################################

  create_cluster_secret_store = true

  cluster_secret_store_name = "aws-secrets-manager"

  secret_store_service = "SecretsManager"

  ##############################################################################
  # Helm
  ##############################################################################

  chart_version = "2.4.1"

  replica_count = 1

  create_namespace = true

  helm_atomic = true

  helm_cleanup_on_fail = true

  helm_wait = true

  helm_timeout = 600

  ##############################################################################
  # Controller
  ##############################################################################

  controller_class = ""

  process_cluster_external_secret = true

  process_cluster_store = true

  process_push_secret = false

  process_cluster_push_secret = false

  concurrent = 1

  log_level = "info"

  log_time_encoding = "epoch"

  ##############################################################################
  # Webhook
  ##############################################################################

  enable_webhook = true

  webhook_replica_count = 1

  ##############################################################################
  # Certificate Controller
  ##############################################################################

  enable_cert_controller = true

  cert_controller_replica_count = 1

  ##############################################################################
  # Monitoring
  ##############################################################################

  enable_service_monitor = false

  metrics_service_enabled = true

  ##############################################################################
  # Availability
  ##############################################################################

  pod_disruption_budget_enabled = false
}