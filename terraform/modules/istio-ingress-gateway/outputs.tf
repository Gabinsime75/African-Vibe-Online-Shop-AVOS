output "release_name" {
  description = "Istio ingress gateway Helm release name."
  value       = helm_release.this.name
}

output "release_namespace" {
  description = "Namespace containing the Istio ingress gateway."
  value       = helm_release.this.namespace
}

output "release_status" {
  description = "Istio ingress gateway Helm release status."
  value       = helm_release.this.status
}

output "chart_version" {
  description = "Installed Istio gateway chart version."
  value       = helm_release.this.version
}

output "gateway_name" {
  description = "Name of the Istio ingress gateway."
  value       = var.gateway_name
}

output "service_name" {
  description = "Expected Kubernetes Service name for the gateway."
  value       = var.gateway_name
}

output "service_type" {
  description = "Kubernetes Service type used by the gateway."
  value       = "ClusterIP"
}

output "http_service_port" {
  description = "HTTP Service port exposed by the gateway."
  value       = 80
}

output "https_service_port" {
  description = "HTTPS Service port exposed by the gateway."
  value       = 443
}

output "status_service_port" {
  description = "Gateway readiness and status Service port."
  value       = 15021
}