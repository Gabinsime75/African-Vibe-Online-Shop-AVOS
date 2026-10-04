# =============================================================================
# AVOS Container Platform — EKS Managed Node IAM Role
#
# Creates the IAM role assumed by EC2 instances in the stable EKS managed node
# group. Nodes can register with EKS, pull images from ECR, and use SSM for
# approved administrative troubleshooting.
# =============================================================================

data "aws_iam_policy_document" "eks_nodes_assume_role" {
  statement {
    sid    = "AllowEC2AssumeRole"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "eks_nodes" {
  name = "${local.cluster_name}-node-role"

  description = "IAM role assumed by AVOS ${var.environment} EKS managed nodes"

  assume_role_policy = data.aws_iam_policy_document.eks_nodes_assume_role.json

  tags = {
    Name    = "${local.cluster_name}-node-role"
    Purpose = "EKSManagedNodes"
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_pull_only" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}