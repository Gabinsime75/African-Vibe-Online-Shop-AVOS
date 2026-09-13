################################################################################
# AWS Load Balancer Controller TargetGroupBinding
################################################################################
# This Terraform resource creates the Kubernetes custom resource:
#   apiVersion: elbv2.k8s.aws/v1beta1
#   kind: TargetGroupBinding

resource "kubernetes_manifest" "this" {
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "TargetGroupBinding"

    metadata = {
      name      = var.name
      namespace = var.namespace

      labels = merge(
        var.labels,
        {
          "app.kubernetes.io/name"       = var.name
          "app.kubernetes.io/component"  = "ingress"
          "app.kubernetes.io/managed-by" = "terraform"
        }
      )

      annotations = var.annotations
    }

    spec = {
      serviceRef = {
        name = var.service_name
        port = var.service_port
      }

      targetGroupARN = var.target_group_arn
      targetType     = var.target_type
    }
  }

  field_manager {
    name            = "terraform"
    force_conflicts = false
  }
}

#This module only binds the existing target group to the Istio Service. 
# The AWS Load Balancer Controller then manages registration and deregistration of the gateway Pod IPs.
#
# The target group health-check configuration does not belong in this module. 
#It is already managed by the ALB module in the networking root