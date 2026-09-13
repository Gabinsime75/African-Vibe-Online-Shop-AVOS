################################################################################
# TargetGroupBinding Metadata
################################################################################

output "name" {
  description = "Name of the TargetGroupBinding Kubernetes resource."
  value       = kubernetes_manifest.this.object.metadata.name
}

output "namespace" {
  description = "Kubernetes namespace containing the TargetGroupBinding resource."
  value       = kubernetes_manifest.this.object.metadata.namespace
}

################################################################################
# Kubernetes Service Reference
################################################################################

output "service_name" {
  description = "Name of the Kubernetes Service associated with the target group."
  value       = var.service_name
}

output "service_port" {
  description = "Kubernetes Service port associated with the target group."
  value       = var.service_port
}

################################################################################
# AWS Target Group
################################################################################

output "target_group_arn" {
  description = "ARN of the AWS target group bound to the Kubernetes Service."
  value       = var.target_group_arn
}

output "target_type" {
  description = "AWS target registration type used by the TargetGroupBinding."
  value       = var.target_type
}

################################################################################
# Resource Identification
################################################################################

output "resource_id" {
  description = "Fully qualified identifier of the TargetGroupBinding resource."
  value       = "${kubernetes_manifest.this.object.metadata.namespace}/${kubernetes_manifest.this.object.metadata.name}"
}