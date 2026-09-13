###############################################################
# EKS Access Entries
###############################################################

resource "aws_eks_access_entry" "this" {
  for_each = var.access_entries

  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = each.value.principal_arn
  kubernetes_groups = try(each.value.kubernetes_groups, null)
  type              = try(each.value.type, "STANDARD")

  tags = merge(
    local.common_tags,
    {
      Name = "${local.cluster_name}-${each.key}-access-entry"
    }
  )

  depends_on = [
    aws_eks_cluster.this
  ]
}

###############################################################
# EKS Access Policy Associations
###############################################################

resource "aws_eks_access_policy_association" "this" {
  for_each = {
    for pair in flatten([
      for access_entry_key, access_entry in var.access_entries : [
        for policy_key, policy in try(access_entry.policy_associations, {}) : {
          key           = "${access_entry_key}-${policy_key}"
          principal_arn = access_entry.principal_arn
          policy_arn    = policy.policy_arn
          access_scope  = policy.access_scope
        }
      ]
    ]) : pair.key => pair
  }

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.access_scope.type
    namespaces = try(each.value.access_scope.namespaces, null)
  }

  depends_on = [
    aws_eks_access_entry.this
  ]
}