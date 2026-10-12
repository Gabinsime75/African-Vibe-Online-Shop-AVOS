# =============================================================================
# AVOS Platform Services — Load Balancer Controller IAM and Pod Identity
# =============================================================================

data "aws_iam_policy_document" "load_balancer_controller_assume_role" {
  statement {
    sid     = "AllowAvosControllerPodIdentity"
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks-cluster-arn"
      values   = [data.aws_eks_cluster.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-namespace"
      values   = ["kube-system"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-service-account"
      values   = ["aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "load_balancer_controller" {
  name = "avos-${var.environment}-load-balancer-controller"

  description = "Pod Identity role for the AVOS AWS Load Balancer Controller."

  assume_role_policy = (
    data.aws_iam_policy_document.load_balancer_controller_assume_role.json
  )
}

resource "aws_iam_policy" "load_balancer_controller" {
  name = "avos-${var.environment}-load-balancer-controller"

  description = "Upstream AWS Load Balancer Controller v3.6.0 permissions."

  policy = file(
    "${path.module}/policies/aws-load-balancer-controller-v3.6.0.json"
  )
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller" {
  role       = aws_iam_role.load_balancer_controller.name
  policy_arn = aws_iam_policy.load_balancer_controller.arn
}

resource "aws_eks_pod_identity_association" "load_balancer_controller" {
  cluster_name    = data.aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.load_balancer_controller.arn

  depends_on = [
    aws_iam_role_policy_attachment.load_balancer_controller
  ]
}
