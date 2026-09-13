################################################################################
# ExternalDNS Helm Deployment: This file deploys ExternalDNS into the Kubernetes cluster using the official Helm chart.
# Responsibilities:
# 1. Creates the ExternalDNS namespace.
# 2. Deploys the official ExternalDNS Helm chart.
# 3. Creates the Kubernetes ServiceAccount.
# 4. Configures the ServiceAccount for EKS Pod Identity.
# 5. Watches Kubernetes Services.
# 6. Watches Kubernetes Ingress resources.
# 7. Watches Istio Gateways.
# 8. Watches Istio VirtualServices.
# 9. Synchronizes DNS records with Route53.
# 10. Creates TXT ownership records.
# 11. Configures logging.
# 12. Applies production resource limits.

# Overall flow:
# Kubernetes Resources
#        │
#        ▼
#    ExternalDNS
#        │
#        ▼
#  EKS Pod Identity
#        │
#        ▼
#     IAM Role
#        │
#        ▼
#     Route53 API
#        │
#        ▼
# DNS Records Created / Updated Automatically
################################################################################


################################################################################
# Kubernetes Namespace
################################################################################

resource "kubernetes_namespace" "this" {

  metadata {

    name = var.namespace

    labels = local.kubernetes_labels
  }
}


################################################################################
# ExternalDNS Helm Release
################################################################################

resource "helm_release" "this" {

  name             = var.name
  namespace        = kubernetes_namespace.this.metadata[0].name
  repository       = var.helm_repository
  chart            = var.chart_name
  version          = var.chart_version
  create_namespace = false

  timeout         = 600
  wait            = true
  cleanup_on_fail = true
  atomic          = true

  values = [

    yamlencode(
      merge(
        local.helm_values,
        var.additional_helm_values
      )
    )
  ]

  depends_on = [

    kubernetes_namespace.this,
    aws_eks_pod_identity_association.this
  ]
}