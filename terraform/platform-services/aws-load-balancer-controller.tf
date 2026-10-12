# =============================================================================
# AVOS Platform Services — AWS Load Balancer Controller Helm Release
# =============================================================================

resource "helm_release" "load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "3.6.0"

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  values = [
    yamlencode({
      clusterName = data.aws_eks_cluster.this.name
      region      = var.aws_region
      vpcId       = data.aws_vpc.this.id

      replicaCount = 2

      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
      }

      nodeSelector = {
        "eks.amazonaws.com/nodegroup" = "avos-dev-system"
      }

      priorityClassName = "system-cluster-critical"

      resources = {
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }

      podDisruptionBudget = {
        maxUnavailable = 1
      }

      topologySpreadConstraints = local.controller_topology_spread.load_balancer_controller

      enableServiceMutatorWebhook = false

      controllerConfig = {
        featureGates = {
          ALBGatewayAPI = false
          NLBGatewayAPI = false
        }
      }

      enableShield = false
      enableWaf    = false
      enableWafv2  = false

      defaultTags = {
        Project     = "AVOS"
        Environment = var.environment
        ManagedBy   = "AWSLoadBalancerController"
      }
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.load_balancer_controller,
    aws_eks_pod_identity_association.load_balancer_controller
  ]
}
