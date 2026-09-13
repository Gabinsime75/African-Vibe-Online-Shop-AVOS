resource "aws_kms_key" "eks" {
  count = var.create_kms_key ? 1 : 0

  description             = "KMS key for EKS secrets encryption for ${local.cluster_name}"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = var.kms_enable_key_rotation
  multi_region            = var.kms_multi_region

  tags = merge(
    local.common_tags,
    {
      Name = "${local.cluster_name}-eks-kms"
    }
  )
}

resource "aws_kms_alias" "eks" {
  count = var.create_kms_key ? 1 : 0

  name          = "alias/${local.cluster_name}-eks"
  target_key_id = aws_kms_key.eks[0].key_id
}