# =============================================================================
# AVOS Platform Services — Load Balancer Controller Outputs
# =============================================================================

output "load_balancer_controller_role_arn" {
  description = "Dedicated IAM role used through EKS Pod Identity."
  value       = aws_iam_role.load_balancer_controller.arn
}

output "load_balancer_controller_pod_identity_association_id" {
  description = "Pod Identity association for the controller service account."
  value       = aws_eks_pod_identity_association.load_balancer_controller.association_id
}

output "load_balancer_controller_release" {
  description = "AWS Load Balancer Controller Helm release details."

  value = {
    name      = helm_release.load_balancer_controller.name
    namespace = helm_release.load_balancer_controller.namespace
    version   = helm_release.load_balancer_controller.version
    status    = helm_release.load_balancer_controller.status
  }
}
