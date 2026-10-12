# =============================================================================
# AVOS Phase 6.7 — ALB Target Group to Istio Gateway
# =============================================================================

resource "kubernetes_manifest" "istio_target_group_binding" {
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "TargetGroupBinding"

    metadata = {
      name      = "avos-ingress"
      namespace = "istio-ingress"
    }

    spec = {
      targetGroupARN = "arn:aws:elasticloadbalancing:us-east-2:396913735153:targetgroup/avos-dev-istio/a371195a4260063f"
      targetType     = "ip"
      vpcID          = data.aws_vpc.this.id

      serviceRef = {
        name = "avos-ingress"
        port = 80
      }
    }
  }

  depends_on = [
    helm_release.load_balancer_controller,
    helm_release.istio_ingress_gateway
  ]
}
