################################################################################
# External Secrets Operator Module Variables
#
# This file defines the configuration interface for the reusable External
# Secrets Operator module.
#
# The module installs External Secrets Operator into Amazon EKS and configures
# secure access to AWS Secrets Manager and optionally AWS Systems Manager
# Parameter Store through EKS Pod Identity.
#
# Architecture:
#
# AWS Secrets Manager / Parameter Store
#                 │
#                 ▼
#             IAM Policy
#                 │
#                 ▼
#              IAM Role
#                 │
#                 ▼
#         EKS Pod Identity
#                 │
#                 ▼
#    External Secrets Operator
#                 │
#                 ▼
#        ClusterSecretStore
#                 │
#                 ▼
#          ExternalSecret
#                 │
#                 ▼
#        Kubernetes Secret
################################################################################


################################################################################
# Platform Identification
################################################################################

variable "platform_name" {
  description = "Name of the larger platform that External Secrets Operator belongs to."
  type        = string

  validation {
    condition     = length(trimspace(var.platform_name)) > 0
    error_message = "platform_name must not be empty."
  }
}

variable "name" {
  description = "Base name used for External Secrets Operator resources."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "tags" {
  description = "Tags applied to AWS resources created by the module."
  type        = map(string)
  default     = {}
}


################################################################################
# Amazon EKS Configuration
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster where External Secrets Operator will be installed."
  type        = string

  validation {
    condition     = length(trimspace(var.cluster_name)) > 0
    error_message = "cluster_name must not be empty."
  }
}

variable "namespace" {
  description = "Kubernetes namespace where External Secrets Operator will be installed."
  type        = string
  default     = "external-secrets"

  validation {
    condition     = length(trimspace(var.namespace)) > 0
    error_message = "namespace must not be empty."
  }
}

variable "service_account_name" {
  description = "Kubernetes service account associated with the External Secrets Operator IAM role."
  type        = string
  default     = "external-secrets"

  validation {
    condition     = length(trimspace(var.service_account_name)) > 0
    error_message = "service_account_name must not be empty."
  }
}


################################################################################
# AWS Provider Configuration
################################################################################

variable "aws_region" {
  description = "AWS region containing Secrets Manager and Parameter Store resources."
  type        = string
}

variable "enable_secrets_manager" {
  description = "Whether External Secrets Operator may retrieve values from AWS Secrets Manager."
  type        = bool
  default     = true
}

variable "enable_parameter_store" {
  description = "Whether External Secrets Operator may retrieve values from AWS Systems Manager Parameter Store."
  type        = bool
  default     = false
}

variable "secrets_manager_secret_arns" {
  description = "Secrets Manager secret ARNs that External Secrets Operator is authorized to access."
  type        = list(string)
  default     = []

  validation {
    condition = (
      !var.enable_secrets_manager ||
      length(var.secrets_manager_secret_arns) > 0
    )

    error_message = "At least one Secrets Manager secret ARN must be provided when enable_secrets_manager is true."
  }
}

variable "parameter_store_parameter_arns" {
  description = "Parameter Store ARNs that External Secrets Operator is authorized to access."
  type        = list(string)
  default     = []

  validation {
    condition = (
      !var.enable_parameter_store ||
      length(var.parameter_store_parameter_arns) > 0
    )

    error_message = "At least one Parameter Store parameter ARN must be provided when enable_parameter_store is true."
  }
}

variable "kms_key_arns" {
  description = "KMS key ARNs that External Secrets Operator may use to decrypt secrets."
  type        = list(string)
  default     = []
}


################################################################################
# Secret Store Configuration
################################################################################

variable "create_cluster_secret_store" {
  description = "Whether the module should create a cluster-scoped AWS ClusterSecretStore."
  type        = bool
  default     = true
}

variable "cluster_secret_store_name" {
  description = "Name of the AWS ClusterSecretStore."
  type        = string
  default     = "aws-secrets-manager"

  validation {
    condition     = length(trimspace(var.cluster_secret_store_name)) > 0
    error_message = "cluster_secret_store_name must not be empty."
  }
}

variable "secret_store_service" {
  description = "AWS service used by the default ClusterSecretStore."
  type        = string
  default     = "SecretsManager"

  validation {
    condition = contains(
      ["SecretsManager", "ParameterStore"],
      var.secret_store_service
    )

    error_message = "secret_store_service must be either SecretsManager or ParameterStore."
  }
}

################################################################################
# Helm Chart Configuration
################################################################################

variable "helm_repository" {
  description = "Helm repository containing the External Secrets Operator chart."
  type        = string
  default     = "https://charts.external-secrets.io"

  validation {
    condition     = length(trimspace(var.helm_repository)) > 0
    error_message = "helm_repository must not be empty."
  }
}

variable "chart_name" {
  description = "Name of the External Secrets Operator Helm chart."
  type        = string
  default     = "external-secrets"

  validation {
    condition     = length(trimspace(var.chart_name)) > 0
    error_message = "chart_name must not be empty."
  }
}

variable "chart_version" {
  description = "Pinned External Secrets Operator Helm chart version."
  type        = string

  validation {
    condition     = length(trimspace(var.chart_version)) > 0
    error_message = "chart_version must not be empty."
  }
}

variable "replica_count" {
  description = "Number of External Secrets Operator controller replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.replica_count >= 1
    error_message = "replica_count must be at least 1."
  }
}

variable "install_crds" {
  description = "Whether the Helm chart should install External Secrets Operator CRDs."
  type        = bool
  default     = true
}

variable "create_namespace" {
  description = "Whether Terraform should create the External Secrets Operator namespace."
  type        = bool
  default     = true
}

variable "helm_timeout" {
  description = "Maximum number of seconds Terraform waits for the Helm release to become ready."
  type        = number
  default     = 600

  validation {
    condition     = var.helm_timeout >= 60
    error_message = "helm_timeout must be at least 60 seconds."
  }
}

variable "helm_atomic" {
  description = "Whether Helm should roll back the release automatically when installation or upgrade fails."
  type        = bool
  default     = true
}

variable "helm_cleanup_on_fail" {
  description = "Whether Helm should delete resources created during a failed installation or upgrade."
  type        = bool
  default     = true
}

variable "helm_wait" {
  description = "Whether Terraform should wait for Kubernetes resources to become ready."
  type        = bool
  default     = true
}


################################################################################
# External Secrets Controller Configuration
################################################################################

variable "controller_class" {
  description = "Optional controller class used to isolate this External Secrets Operator deployment."
  type        = string
  default     = ""
}

variable "process_cluster_external_secret" {
  description = "Whether the controller should reconcile ClusterExternalSecret resources."
  type        = bool
  default     = true
}

variable "process_cluster_store" {
  description = "Whether the controller should reconcile ClusterSecretStore resources."
  type        = bool
  default     = true
}

variable "process_push_secret" {
  description = "Whether the controller should reconcile PushSecret resources."
  type        = bool
  default     = false
}

variable "concurrent" {
  description = "Maximum number of ExternalSecret reconciliation operations processed concurrently."
  type        = number
  default     = 1

  validation {
    condition     = var.concurrent >= 1
    error_message = "concurrent must be at least 1."
  }
}

variable "log_level" {
  description = "Logging verbosity for External Secrets Operator."
  type        = string
  default     = "info"

  validation {
    condition = contains(
      ["debug", "info", "warn", "error"],
      lower(var.log_level)
    )

    error_message = "log_level must be debug, info, warn, or error."
  }
}

variable "log_time_encoding" {
  description = "Timestamp encoding format used by External Secrets Operator logs."
  type        = string
  default     = "epoch"

  validation {
    condition = contains(
      ["epoch", "iso8601", "millis", "nanos", "rfc3339", "rfc3339nano"],
      lower(var.log_time_encoding)
    )

    error_message = "log_time_encoding must be epoch, iso8601, millis, nanos, rfc3339, or rfc3339nano."
  }
}


################################################################################
# Webhook Configuration
################################################################################

variable "enable_webhook" {
  description = "Whether the External Secrets admission webhook should be deployed."
  type        = bool
  default     = true
}

variable "webhook_replica_count" {
  description = "Number of External Secrets webhook replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.webhook_replica_count >= 1
    error_message = "webhook_replica_count must be at least 1."
  }
}

variable "webhook_resources" {
  description = "CPU and memory requests and limits for the External Secrets webhook."
  type = object({
    requests = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }), {})
    limits = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }), {})
  })

  default = {
    requests = {
      cpu    = "10m"
      memory = "32Mi"
    }
    limits = {
      cpu    = "100m"
      memory = "128Mi"
    }
  }
}


################################################################################
# Certificate Controller Configuration
################################################################################

variable "enable_cert_controller" {
  description = "Whether the External Secrets certificate controller should be deployed."
  type        = bool
  default     = true
}

variable "cert_controller_replica_count" {
  description = "Number of External Secrets certificate controller replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.cert_controller_replica_count >= 1
    error_message = "cert_controller_replica_count must be at least 1."
  }
}

variable "cert_controller_resources" {
  description = "CPU and memory requests and limits for the External Secrets certificate controller."
  type = object({
    requests = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }), {})
    limits = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }), {})
  })

  default = {
    requests = {
      cpu    = "10m"
      memory = "32Mi"
    }
    limits = {
      cpu    = "100m"
      memory = "128Mi"
    }
  }
}


################################################################################
# Main Controller Resource Configuration
################################################################################

variable "resources" {
  description = "CPU and memory requests and limits for the External Secrets Operator controller."
  type = object({
    requests = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }), {})
    limits = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }), {})
  })

  default = {
    requests = {
      cpu    = "25m"
      memory = "64Mi"
    }
    limits = {
      cpu    = "200m"
      memory = "256Mi"
    }
  }
}


################################################################################
# Kubernetes Labels and Annotations
################################################################################

variable "pod_labels" {
  description = "Additional labels applied to External Secrets Operator controller Pods."
  type        = map(string)
  default     = {}
}

variable "pod_annotations" {
  description = "Additional annotations applied to External Secrets Operator controller Pods."
  type        = map(string)
  default     = {}
}

variable "service_account_labels" {
  description = "Additional labels applied to the External Secrets Operator service account."
  type        = map(string)
  default     = {}
}

variable "service_account_annotations" {
  description = "Additional annotations applied to the External Secrets Operator service account."
  type        = map(string)
  default     = {}
}


################################################################################
# Kubernetes Scheduling Configuration
################################################################################

variable "node_selector" {
  description = "Node selector applied to External Secrets Operator controller Pods."
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Tolerations applied to External Secrets Operator controller Pods."
  type        = list(any)
  default     = []
}

variable "affinity" {
  description = "Affinity configuration applied to External Secrets Operator controller Pods."
  type        = any
  default     = {}
}

variable "topology_spread_constraints" {
  description = "Topology spread constraints applied to External Secrets Operator controller Pods."
  type        = list(any)
  default     = []
}

variable "priority_class_name" {
  description = "Kubernetes PriorityClass assigned to External Secrets Operator Pods."
  type        = string
  default     = ""
}


################################################################################
# Webhook Scheduling Configuration
################################################################################

variable "webhook_node_selector" {
  description = "Node selector applied to External Secrets webhook Pods."
  type        = map(string)
  default     = {}
}

variable "webhook_tolerations" {
  description = "Tolerations applied to External Secrets webhook Pods."
  type        = list(any)
  default     = []
}

variable "webhook_affinity" {
  description = "Affinity configuration applied to External Secrets webhook Pods."
  type        = any
  default     = {}
}


################################################################################
# Certificate Controller Scheduling Configuration
################################################################################

variable "cert_controller_node_selector" {
  description = "Node selector applied to External Secrets certificate controller Pods."
  type        = map(string)
  default     = {}
}

variable "cert_controller_tolerations" {
  description = "Tolerations applied to External Secrets certificate controller Pods."
  type        = list(any)
  default     = []
}

variable "cert_controller_affinity" {
  description = "Affinity configuration applied to External Secrets certificate controller Pods."
  type        = any
  default     = {}
}


################################################################################
# High Availability Configuration
################################################################################

variable "pod_disruption_budget_enabled" {
  description = "Whether a PodDisruptionBudget should be enabled for the main controller."
  type        = bool
  default     = false
}

variable "pod_disruption_budget_min_available" {
  description = "Minimum number of available controller Pods required by the PodDisruptionBudget."
  type        = number
  default     = 1

  validation {
    condition     = var.pod_disruption_budget_min_available >= 0
    error_message = "pod_disruption_budget_min_available must be zero or greater."
  }
}


################################################################################
# Observability Configuration
################################################################################

variable "enable_service_monitor" {
  description = "Whether a Prometheus Operator ServiceMonitor should be created."
  type        = bool
  default     = false
}

variable "service_monitor_namespace" {
  description = "Namespace in which the External Secrets ServiceMonitor should be created."
  type        = string
  default     = ""
}

variable "service_monitor_labels" {
  description = "Additional labels applied to the External Secrets ServiceMonitor."
  type        = map(string)
  default     = {}
}

variable "service_monitor_interval" {
  description = "Prometheus metric scraping interval."
  type        = string
  default     = "30s"

  validation {
    condition     = can(regex("^[0-9]+(s|m|h)$", var.service_monitor_interval))
    error_message = "service_monitor_interval must use a value such as 30s, 1m, or 1h."
  }
}

variable "service_monitor_scrape_timeout" {
  description = "Maximum amount of time Prometheus may spend scraping External Secrets metrics."
  type        = string
  default     = "10s"

  validation {
    condition     = can(regex("^[0-9]+(s|m|h)$", var.service_monitor_scrape_timeout))
    error_message = "service_monitor_scrape_timeout must use a value such as 10s, 1m, or 1h."
  }
}


################################################################################
# Metrics Service Configuration
################################################################################

variable "metrics_service_enabled" {
  description = "Whether the External Secrets metrics service should be enabled."
  type        = bool
  default     = true
}

variable "metrics_service_annotations" {
  description = "Annotations applied to the External Secrets metrics service."
  type        = map(string)
  default     = {}
}


################################################################################
# Security Configuration
################################################################################

variable "security_context" {
  description = "Container security context applied to the External Secrets Operator controller."
  type        = any

  default = {
    allowPrivilegeEscalation = false
    capabilities = {
      drop = ["ALL"]
    }
    readOnlyRootFilesystem = true
    runAsNonRoot           = true
  }
}

variable "pod_security_context" {
  description = "Pod security context applied to the External Secrets Operator controller."
  type        = any

  default = {
    runAsNonRoot = true
  }
}


################################################################################
# Deployment Customization
################################################################################

variable "additional_helm_values" {
  description = "Additional Helm values merged into the generated External Secrets Operator configuration."
  type        = map(any)
  default     = {}
}

variable "process_cluster_push_secret" {
  description = "Controls whether the operator processes ClusterPushSecret resources."
  type        = bool
  default     = false
}