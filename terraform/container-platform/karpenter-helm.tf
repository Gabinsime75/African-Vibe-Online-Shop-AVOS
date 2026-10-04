resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = "kube-system"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_version

  atomic          = true
  cleanup_on_fail = true
  timeout         = 600
  wait            = true

  set {
    name  = "settings.clusterName"
    value = aws_eks_cluster.this.name
  }

  set {
    name  = "settings.interruptionQueue"
    value = aws_sqs_queue.karpenter_interruption.name
  }

  set {
    name  = "serviceAccount.name"
    value = "karpenter"
  }

  set {
    name  = "replicas"
    value = "2"
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "250m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "512Mi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "1Gi"
  }

  set {
    name  = "nodeSelector.node-pool"
    value = "system"
  }

  depends_on = [
    aws_eks_node_group.system,
    aws_eks_pod_identity_association.karpenter,
    aws_sqs_queue_policy.karpenter_interruption
  ]
}