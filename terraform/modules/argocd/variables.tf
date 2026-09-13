variable "namespace" {
  description = "Kubernetes namespace where Argo CD will be installed."
  type        = string
  default     = "argocd"
}

variable "release_name" {
  description = "Helm release name for Argo CD."
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Pinned Argo CD Helm chart version."
  type        = string
  default     = "10.4.0"
}

variable "server_service_type" {
  description = "Kubernetes Service type used by the Argo CD API server."
  type        = string
  default     = "ClusterIP"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "project_name" {
  description = "CloudHustler project identifier used for labels."
  type        = string
}