###############################################################
# Metrics Server Helm Release
###############################################################

locals {
  metrics_server_set_values = concat(
    [
      {
        name  = "replicas"
        value = tostring(var.replica_count)
      },
      {
        name  = "apiService.create"
        value = tostring(var.create_api_service)
      },
      {
        name  = "rbac.create"
        value = tostring(var.create_rbac)
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
        name  = "metrics.enabled"
        value = tostring(var.enable_metrics_endpoint)
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

  set    = local.metrics_server_set_values
  values = var.values
}