###############################################################
# AWS Load Balancer Controller Helm Release
###############################################################

locals {
  aws_load_balancer_controller_set_values = concat(
    [
      {
        name  = "clusterName"
        value = var.cluster_name
      },
      {
        name  = "region"
        value = var.aws_region
      },
      {
        name  = "vpcId"
        value = var.vpc_id
      },
      {
        name  = "serviceAccount.create"
        value = tostring(var.create_service_account)
      },
      {
        name  = "serviceAccount.name"
        value = var.service_account_name
      },
      {
        name  = "replicaCount"
        value = tostring(var.replica_count)
      },
      {
        name  = "ingressClassConfig.default"
        value = "false"
      },
      {
        name  = "enableServiceMutatorWebhook"
        value = tostring(var.enable_service_mutator_webhook)
      }
    ],
    [
      for name, value in var.additional_set_values : {
        name  = name
        value = value
      }
    ]
  )
}

resource "helm_release" "this" {
  name       = var.release_name
  namespace  = var.namespace
  repository = var.chart_repository
  chart      = var.chart_name
  version    = var.chart_version

  create_namespace = var.create_namespace

  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.helm_timeout
  wait            = var.wait

  set = local.aws_load_balancer_controller_set_values

  values = var.values

  depends_on = [
    aws_eks_pod_identity_association.this
  ]
}