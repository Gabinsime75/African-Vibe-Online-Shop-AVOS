###############################################################
# Istio Ingress Gateway Values
###############################################################

locals {
  gateway_default_values = merge(
    {
      name = var.gateway_name

      replicaCount = var.enable_autoscaling ? null : var.replica_count

      autoscaling = {
        enabled     = var.enable_autoscaling
        minReplicas = var.autoscale_min_replicas
        maxReplicas = var.autoscale_max_replicas

        targetCPUUtilizationPercentage = (
          var.autoscaling_cpu_target_percentage
        )

        targetMemoryUtilizationPercentage = (
          var.autoscaling_memory_target_percentage
        )
      }

      service = {
        type = "ClusterIP"

        ports = [
          {
            name       = "status-port"
            port       = 15021
            protocol   = "TCP"
            targetPort = 15021
          },
          {
            name       = "http2"
            port       = 80
            protocol   = "TCP"
            targetPort = 8080
          },
          {
            name       = "https"
            port       = 443
            protocol   = "TCP"
            targetPort = 8443
          }
        ]

        annotations = var.service_annotations
      }

      resources = {
        requests = {
          cpu    = var.cpu_request
          memory = var.memory_request
        }

        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }

      podDisruptionBudget = {
        minAvailable = var.pod_disruption_budget_min_available
      }

      securityContext = {
        runAsNonRoot = true
        runAsUser    = var.run_as_user
        runAsGroup   = var.run_as_group

        capabilities = {
          drop = ["ALL"]
        }
      }

      containerSecurityContext = {
        allowPrivilegeEscalation = false
        privileged               = false
        readOnlyRootFilesystem   = var.read_only_root_filesystem
        runAsNonRoot             = true

        capabilities = {
          drop = ["ALL"]
        }
      }

      podAnnotations = var.pod_annotations

      labels = merge(
        {
          app   = var.gateway_name
          istio = "ingressgateway"
        },
        var.additional_labels
      )

      affinity                  = var.affinity
      topologySpreadConstraints = var.topology_spread_constraints
      tolerations               = var.tolerations
      nodeSelector              = var.node_selector

      terminationGracePeriodSeconds = (
        var.termination_grace_period_seconds
      )
    },
    var.revision != null && trimspace(var.revision) != "" ? {
      revision = var.revision
    } : {}
  )

  gateway_values = concat(
    [
      yamlencode(local.gateway_default_values)
    ],
    var.additional_values
  )
}

###############################################################
# Istio Ingress Gateway
###############################################################

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

  max_history = var.max_history

  values = local.gateway_values
}