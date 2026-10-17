output "image_updater_role_arn" {
  description = "Read-only ECR role used by Image Updater through Pod Identity."
  value       = aws_iam_role.image_updater.arn
}

output "image_updater_pod_identity_association_id" {
  description = "Pod Identity association for the Image Updater ServiceAccount."
  value       = aws_eks_pod_identity_association.image_updater.association_id
}

output "image_updater_chart_version" {
  description = "Pinned Image Updater Helm chart version."
  value       = helm_release.image_updater.version
}
