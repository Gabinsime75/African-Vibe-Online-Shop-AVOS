output "cluster_name" {
  description = "Name of the AVOS EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "ARN of the AVOS EKS cluster."
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "API server endpoint of the AVOS EKS cluster."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_version" {
  description = "Kubernetes version of the AVOS EKS cluster."
  value       = aws_eks_cluster.this.version
}

output "cluster_platform_version" {
  description = "Amazon EKS platform version of the AVOS cluster."
  value       = aws_eks_cluster.this.platform_version
}

output "cluster_status" {
  description = "Current status of the AVOS EKS cluster."
  value       = aws_eks_cluster.this.status
}

output "cluster_security_group_id" {
  description = "Security group created by EKS for the cluster."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_private_subnet_ids" {
  description = "Private application subnet IDs used by the EKS cluster."
  value       = data.terraform_remote_state.networking.outputs.private_application_subnet_ids
}

output "cluster_oidc_issuer" {
  description = "OpenID Connect issuer URL published by the EKS cluster."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cluster_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt Kubernetes secrets and EKS control-plane logs."
  value       = aws_kms_key.eks.arn
}

output "cluster_kms_alias" {
  description = "Alias of the KMS key used by the EKS platform."
  value       = aws_kms_alias.eks.name
}

output "control_plane_log_group_name" {
  description = "CloudWatch Logs group receiving EKS control-plane logs."
  value       = aws_cloudwatch_log_group.eks_control_plane.name
}

output "cluster_iam_role_arn" {
  description = "ARN of the IAM role used by the EKS control plane."
  value       = aws_iam_role.eks_cluster.arn
}

output "system_node_group_name" {
  description = "Name of the managed system node group."
  value       = aws_eks_node_group.system.node_group_name
}

output "system_node_group_status" {
  description = "Current status of the managed system node group."
  value       = aws_eks_node_group.system.status
}

output "system_node_role_arn" {
  description = "ARN of the IAM role used by managed system nodes."
  value       = aws_iam_role.eks_nodes.arn
}

output "system_launch_template_id" {
  description = "ID of the launch template used by the managed system node group."
  value       = aws_launch_template.system_nodes.id
}

output "managed_addon_versions" {
  description = "Installed versions of the AVOS EKS managed add-ons."

  value = {
    vpc_cni            = aws_eks_addon.vpc_cni.addon_version
    coredns            = aws_eks_addon.coredns.addon_version
    kube_proxy         = aws_eks_addon.kube_proxy.addon_version
    pod_identity_agent = aws_eks_addon.pod_identity_agent.addon_version
    aws_ebs_csi_driver = aws_eks_addon.ebs_csi.addon_version
  }
}

output "gp3_storage_class_name" {
  description = "Name of the default encrypted gp3 Kubernetes StorageClass."
  value       = kubernetes_storage_class_v1.gp3.metadata[0].name
}

output "karpenter_controller_role_arn" {
  description = "ARN of the IAM role used by the Karpenter controller."
  value       = aws_iam_role.karpenter_controller.arn
}

output "karpenter_node_role_arn" {
  description = "ARN of the IAM role used by Karpenter-provisioned nodes."
  value       = aws_iam_role.karpenter_node.arn
}

output "karpenter_instance_profile_name" {
  description = "Name of the EC2 instance profile used by Karpenter nodes."
  value       = aws_iam_instance_profile.karpenter_node.name
}

output "karpenter_interruption_queue_name" {
  description = "Name of the SQS queue used for Karpenter interruption handling."
  value       = aws_sqs_queue.karpenter_interruption.name
}

output "karpenter_interruption_queue_arn" {
  description = "ARN of the SQS queue used for Karpenter interruption handling."
  value       = aws_sqs_queue.karpenter_interruption.arn
}

output "karpenter_helm_release" {
  description = "Name and status of the Karpenter Helm release."

  value = {
    name      = helm_release.karpenter.name
    namespace = helm_release.karpenter.namespace
    version   = helm_release.karpenter.version
    status    = helm_release.karpenter.status
  }
}

output "karpenter_ec2_node_class_name" {
  description = "Name of the Karpenter EC2NodeClass used for AVOS application capacity."
  value       = "avos-dev-application"
}

output "karpenter_node_pool_name" {
  description = "Name of the Karpenter NodePool used for AVOS application capacity."
  value       = "application"
}

output "administrator_access_entry_arn" {
  description = "ARN of the EKS administrator access entry."
  value       = aws_eks_access_entry.administrator.access_entry_arn
}