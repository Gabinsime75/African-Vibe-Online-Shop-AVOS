# =============================================================================
# AVOS Container Platform — Stable EKS Managed Node Group
#
# Creates the stable Amazon Linux 2023 system capacity used by Kubernetes
# system components and platform controllers.
# =============================================================================

resource "aws_launch_template" "system_nodes" {
  name_prefix = "${local.system_node_group_name}-"

  description = "Launch template for AVOS ${var.environment} EKS system nodes"

  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.system_node_disk_size_gib
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name     = "${local.system_node_group_name}-node"
        NodePool = "system"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      local.common_tags,
      {
        Name     = "${local.system_node_group_name}-volume"
        NodePool = "system"
      }
    )
  }

  tags = {
    Name    = "${local.system_node_group_name}-launch-template"
    Purpose = "EKSSystemNodes"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "system" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = local.system_node_group_name
  node_role_arn   = aws_iam_role.eks_nodes.arn

  subnet_ids = data.terraform_remote_state.networking.outputs.private_application_subnet_ids

  version        = var.kubernetes_version
  ami_type       = var.system_node_ami_type
  capacity_type  = var.system_node_capacity_type
  instance_types = var.system_node_instance_types

  scaling_config {
    min_size     = var.system_node_min_size
    desired_size = var.system_node_desired_size
    max_size     = var.system_node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.system_nodes.id
    version = aws_launch_template.system_nodes.latest_version
  }

  labels = {
    "node-pool"     = "system"
    "workload-type" = "platform"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.ecr_pull_only,
    aws_iam_role_policy_attachment.ssm_managed_instance,
    aws_eks_addon.pod_identity_agent,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy
  ]

  tags = {
    Name    = local.system_node_group_name
    Purpose = "EKSSystemCapacity"
  }

  timeouts {
    create = "45m"
    update = "60m"
    delete = "45m"
  }
}