data "aws_iam_policy_document" "karpenter_node_assume_role" {
  statement {
    sid     = "AllowEC2AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "karpenter_node" {
  name               = "${local.name_prefix}-karpenter-node-role"
  assume_role_policy = data.aws_iam_policy_document.karpenter_node_assume_role.json

  tags = {
    Name    = "${local.name_prefix}-karpenter-node-role"
    Purpose = "KarpenterWorkerNodes"
  }
}

resource "aws_iam_role_policy_attachment" "karpenter_node_worker" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ecr" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ssm" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "karpenter_node" {
  name = "${local.name_prefix}-karpenter-node"
  role = aws_iam_role.karpenter_node.name

  tags = {
    Name    = "${local.name_prefix}-karpenter-node"
    Purpose = "KarpenterWorkerNodes"
  }
}

resource "aws_eks_access_entry" "karpenter_node" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.karpenter_node.arn
  type          = "EC2_LINUX"

  tags = {
    Name       = "${local.name_prefix}-karpenter-node"
    AccessType = "KarpenterWorkerNode"
  }

  depends_on = [
    aws_iam_role_policy_attachment.karpenter_node_worker,
    aws_iam_role_policy_attachment.karpenter_node_ecr
  ]
}