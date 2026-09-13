# =============================================================================
# CloudHustler Commerce Platform
# Karpenter Helm Deployment
# =============================================================================
# Installs Karpenter into the existing EKS cluster.
#
# Karpenter runs on the stable EKS managed system node group and dynamically
# provisions additional EC2 worker nodes for unschedulable workloads.
# =============================================================================

# -----------------------------------------------------------------------------
# Karpenter Helm Release
# -----------------------------------------------------------------------------

resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = var.namespace
  create_namespace = false

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.chart_version

  wait          = true
  wait_for_jobs = true
  timeout       = 900

  atomic          = true
  cleanup_on_fail = true

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = var.service_account_name
      }

      settings = {
        clusterName       = var.cluster_name
        clusterEndpoint   = var.cluster_endpoint
        interruptionQueue = module.karpenter_aws.queue_name
      }

      replicas = var.controller_replicas

      controller = {
        resources = {
          requests = {
            cpu    = var.controller_cpu_request
            memory = var.controller_memory_request
          }

          limits = {
            cpu    = var.controller_cpu_limit
            memory = var.controller_memory_limit
          }
        }
      }

      podDisruptionBudget = {
        name           = "karpenter"
        maxUnavailable = 1
      }
    })
  ]

  depends_on = [
    module.karpenter_aws
  ]
}