###############################################################
# AWS Load Balancer Controller Pod Identity IAM Role
###############################################################
# Helm is the AWS-recommended installation approach for the controller. Supplying clusterName, 
# region, and vpcId also prevents dependency on EC2 instance metadata for discovering those values.

# This module does not create an Ingress, Kubernetes LoadBalancer Service, or ALB. Installing the 
# controller alone does not create another load balancer.

resource "aws_iam_role" "this" {
  count = var.create_pod_identity_role ? 1 : 0

  name = var.iam_role_name
  path = var.iam_path

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowEksPodIdentity"
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name      = var.iam_role_name
      Component = "aws-load-balancer-controller"
    }
  )
}

###############################################################
# IAM Policy Attachment
###############################################################

resource "aws_iam_role_policy_attachment" "this" {
  count = var.create_pod_identity_role ? 1 : 0

  role = aws_iam_role.this[0].name

  policy_arn = var.create_iam_policy ? (
    aws_iam_policy.this[0].arn
  ) : var.existing_iam_policy_arn
}

###############################################################
# EKS Pod Identity Association
###############################################################

resource "aws_eks_pod_identity_association" "this" {
  count = var.create_pod_identity_association ? 1 : 0

  cluster_name = var.cluster_name
  namespace    = var.namespace

  service_account = var.service_account_name

  role_arn = var.create_pod_identity_role ? (
    aws_iam_role.this[0].arn
  ) : var.existing_pod_identity_role_arn

  tags = merge(
    var.tags,
    {
      Name      = "${var.cluster_name}-aws-load-balancer-controller"
      Component = "aws-load-balancer-controller"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.this
  ]
}