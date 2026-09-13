# ###############################################################
# # AWS Load Balancer Controller
# ###############################################################

# module "aws_load_balancer_controller" {
#   source = "../modules/aws-load-balancer-controller"

#   #############################################################
#   # Cluster Configuration
#   #############################################################

#   cluster_name = var.cluster_name
#   aws_region   = var.aws_region
#   vpc_id       = var.vpc_id

#   #############################################################
#   # Existing Target Groups
#   #############################################################

#   target_group_arns = [
#     var.istio_ingress_target_group_arn
#   ]

#   #############################################################
#   # IAM
#   #############################################################

#   create_iam_policy = true

#   iam_policy_name = "${local.name_prefix}-lbc-tgb-policy"

#   create_pod_identity_role = true

#   iam_role_name = "${local.name_prefix}-lbc-pod-identity-role"

#   create_pod_identity_association = true

#   #############################################################
#   # Kubernetes Service Account
#   #############################################################

#   namespace = var.aws_load_balancer_controller_namespace

#   service_account_name = (
#     var.aws_load_balancer_controller_service_account_name
#   )

#   create_service_account = true

#   #############################################################
#   # Helm
#   #############################################################

#   release_name  = var.aws_load_balancer_controller_release_name
#   chart_version = var.aws_load_balancer_controller_chart_version

#   replica_count = var.aws_load_balancer_controller_replica_count

#   enable_service_mutator_webhook = false

#   atomic          = true
#   cleanup_on_fail = true
#   wait            = true
#   helm_timeout    = var.aws_load_balancer_controller_helm_timeout

#   tags = local.common_tags
# }

module "aws_load_balancer_controller" {
  source = "../modules/aws-load-balancer-controller"

  cluster_name = var.cluster_name
  aws_region   = var.aws_region
  vpc_id       = var.vpc_id

  target_group_arns = [
    var.istio_ingress_target_group_arn
  ]

  create_iam_policy = true
  iam_policy_name   = "${local.name_prefix}-lbc-tgb-policy"

  create_pod_identity_role = true
  iam_role_name            = "${local.name_prefix}-lbc-pod-identity-role"

  create_pod_identity_association = true

  namespace              = var.aws_load_balancer_controller_namespace
  service_account_name   = var.aws_load_balancer_controller_service_account_name
  create_service_account = true

  release_name = var.aws_load_balancer_controller_release_name

  chart_repository = "https://aws.github.io/eks-charts"
  chart_name       = "aws-load-balancer-controller"
  chart_version    = var.aws_load_balancer_controller_chart_version

  replica_count = var.aws_load_balancer_controller_replica_count

  enable_service_mutator_webhook = false

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  helm_timeout    = var.aws_load_balancer_controller_helm_timeout

  tags = local.common_tags
}

###############################################################
# Metrics Server
###############################################################

module "metrics_server" {
  source = "../modules/metrics-server"

  namespace = var.metrics_server_namespace

  release_name  = var.metrics_server_release_name
  chart_version = var.metrics_server_chart_version

  replica_count = var.metrics_server_replica_count

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  helm_timeout    = var.metrics_server_helm_timeout

  depends_on = [
    module.aws_load_balancer_controller
  ]
}

###############################################################
# Istio Control Plane
###############################################################

module "istio_control_plane" {
  source = "../modules/istio-control-plane"

  chart_version = var.istio_chart_version
  namespace     = var.istio_namespace
  revision      = null

  enable_autoscaling     = true
  autoscale_min_replicas = var.istiod_autoscale_min_replicas
  autoscale_max_replicas = var.istiod_autoscale_max_replicas

  autoscaling_cpu_target_percentage = (
    var.istiod_autoscaling_cpu_target_percentage
  )

  istiod_cpu_request    = var.istiod_cpu_request
  istiod_memory_request = var.istiod_memory_request
  istiod_cpu_limit      = var.istiod_cpu_limit
  istiod_memory_limit   = var.istiod_memory_limit

  enable_gateway_api     = true
  enable_native_sidecars = true

  enable_tracing              = true
  tracing_sampling_percentage = var.istio_tracing_sampling_percentage

  enable_access_logging = true
  access_log_encoding   = "JSON"

  outbound_traffic_policy_mode = (
    var.istio_outbound_traffic_policy_mode
  )

  depends_on = [
    module.metrics_server
  ]
}

###############################################################
# Istio Ingress Gateway
###############################################################

module "istio_ingress_gateway" {
  source = "../modules/istio-ingress-gateway"

  chart_version = var.istio_chart_version

  release_name = var.istio_ingress_gateway_release_name
  gateway_name = var.istio_ingress_gateway_name
  namespace    = var.istio_ingress_gateway_namespace

  revision = null

  enable_autoscaling     = true
  autoscale_min_replicas = var.istio_ingress_autoscale_min_replicas
  autoscale_max_replicas = var.istio_ingress_autoscale_max_replicas

  autoscaling_cpu_target_percentage = (
    var.istio_ingress_autoscaling_cpu_target_percentage
  )

  autoscaling_memory_target_percentage = (
    var.istio_ingress_autoscaling_memory_target_percentage
  )

  cpu_request    = var.istio_ingress_cpu_request
  memory_request = var.istio_ingress_memory_request
  cpu_limit      = var.istio_ingress_cpu_limit
  memory_limit   = var.istio_ingress_memory_limit

  # Temporary troubleshooting settings
  atomic          = true
  cleanup_on_fail = true
  wait            = true
  helm_timeout    = 900

  depends_on = [
    module.istio_control_plane
  ]
}