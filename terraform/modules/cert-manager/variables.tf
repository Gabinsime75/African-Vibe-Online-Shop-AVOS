###############################################################################
# General
###############################################################################

variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "aws_region" {
  description = "AWS region hosting the EKS cluster."
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "tags" {
  description = "Tags applied to AWS resources."
  type        = map(string)
  default     = {}
}

###############################################################################
# Helm
###############################################################################

variable "namespace" {
  description = "Kubernetes namespace for cert-manager."
  type        = string
  default     = "cert-manager"
}

variable "helm_release_name" {
  description = "Helm release name."
  type        = string
  default     = "cert-manager"
}

variable "chart_version" {
  description = "Cert-Manager Helm chart version."
  type        = string
  default     = "v1.21.0"
}

variable "replica_count" {
  description = "Number of cert-manager controller replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.replica_count >= 1
    error_message = "replica_count must be at least 1."
  }
}

variable "webhook_replica_count" {
  description = "Number of cert-manager webhook replicas."
  type        = number
  default     = 1
}

variable "cainjector_replica_count" {
  description = "Number of cert-manager CA injector replicas."
  type        = number
  default     = 1
}

###############################################################################
# Route 53
###############################################################################

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID used for DNS-01 validation."
  type        = string
}

variable "route53_zone_arn" {
  description = "ARN of the Route 53 hosted zone used for DNS-01 validation."
  type        = string
}

###############################################################################
# ClusterIssuer
###############################################################################

variable "create_cluster_issuers" {
  description = "Whether to create Let's Encrypt staging and production ClusterIssuers."
  type        = bool
  default     = true
}

variable "letsencrypt_email" {
  description = "Email address used for Let's Encrypt registration and expiration notices."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.letsencrypt_email))
    error_message = "letsencrypt_email must be a valid email address."
  }
}

variable "production_cluster_issuer_name" {
  description = "Name of the Let's Encrypt production ClusterIssuer."
  type        = string
  default     = "letsencrypt-prod"
}

variable "staging_cluster_issuer_name" {
  description = "Name of the Let's Encrypt staging ClusterIssuer."
  type        = string
  default     = "letsencrypt-staging"
}

variable "create_staging_cluster_issuer" {
  description = "Whether to create the Let's Encrypt staging ClusterIssuer."
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Primary DNS domain managed by Cert-Manager."
  type        = string
}