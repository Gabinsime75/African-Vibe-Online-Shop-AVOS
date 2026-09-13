resource "aws_iam_role" "node_group" {
  for_each = var.node_groups

  name = "${local.cluster_name}-${each.key}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name      = "${local.cluster_name}-${each.key}-node-role"
      NodeGroup = each.key
    }
  )
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  for_each = var.node_groups

  role       = aws_iam_role.node_group[each.key].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  for_each = var.node_groups

  role       = aws_iam_role.node_group[each.key].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_readonly_policy" {
  for_each = var.node_groups

  role       = aws_iam_role.node_group[each.key].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_ssm_policy" {
  for_each = var.node_groups

  role       = aws_iam_role.node_group[each.key].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.cluster_name}-${each.key}"
  node_role_arn   = aws_iam_role.node_group[each.key].arn
  subnet_ids      = each.value.subnet_ids

  ami_type        = each.value.ami_type
  capacity_type   = each.value.capacity_type
  disk_size       = each.value.disk_size
  instance_types  = each.value.instance_types
  release_version = try(each.value.release_version, null)
  version         = try(each.value.kubernetes_version, var.kubernetes_version)

  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }

  update_config {
    max_unavailable = each.value.max_unavailable
  }

  dynamic "remote_access" {
    for_each = try(each.value.ec2_ssh_key, null) != null ? [1] : []

    content {
      ec2_ssh_key               = each.value.ec2_ssh_key
      source_security_group_ids = try(each.value.source_security_group_ids, [])
    }
  }

  labels = try(each.value.labels, null)

  tags = merge(
    local.common_tags,
    try(each.value.tags, {}),
    {
      Name      = "${local.cluster_name}-${each.key}"
      NodeGroup = each.key
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_readonly_policy,
    aws_iam_role_policy_attachment.node_ssm_policy
  ]

  lifecycle {
    create_before_destroy = true
  }
}