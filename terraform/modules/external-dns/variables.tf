variable "cluster_name" {
  description = "Name of the EKS cluster where ExternalDNS will be deployed."
  type        = string

  validation {
    condition     = length(trimspace(var.cluster_name)) > 0
    error_message = "cluster_name must not be empty."
  }
}

variable "name" {
  description = "Name used for the ExternalDNS Helm release and AWS resources."
  type        = string
  default     = "external-dns"

  validation {
    condition = can(regex(
      "^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$",
      var.name
    ))
    error_message = "name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "namespace" {
  description = "Kubernetes namespace in which ExternalDNS will be deployed."
  type        = string
  default     = "external-dns"

  validation {
    condition = can(regex(
      "^[a-z0-9]([-a-z0-9]*[a-z0-9])?$",
      var.namespace
    ))
    error_message = "namespace must be a valid Kubernetes namespace name."
  }
}

variable "service_account_name" {
  description = "Kubernetes service account associated with the ExternalDNS IAM role."
  type        = string
  default     = "external-dns"

  validation {
    condition = can(regex(
      "^[a-z0-9]([-a-z0-9]*[a-z0-9])?$",
      var.service_account_name
    ))
    error_message = "service_account_name must be a valid Kubernetes service account name."
  }
}

variable "hosted_zone_id" {
  description = "Route 53 hosted zone ID that ExternalDNS is permitted to manage."
  type        = string

  validation {
    condition     = can(regex("^Z[A-Z0-9]+$", var.hosted_zone_id))
    error_message = "hosted_zone_id must be a valid Route 53 hosted zone ID beginning with Z."
  }
}

variable "domain_filters" {
  description = "DNS domains that ExternalDNS is allowed to manage."
  type        = list(string)

  validation {
    condition = (
      length(var.domain_filters) > 0 &&
      alltrue([
        for domain in var.domain_filters :
        length(trimspace(domain)) > 0
      ])
    )

    error_message = "domain_filters must contain at least one non-empty domain."
  }
}

variable "sources" {
  description = "Kubernetes resource types watched by ExternalDNS for DNS endpoints."
  type        = list(string)

  default = [
    "service",
    "ingress",
    "istio-gateway",
    "istio-virtualservice"
  ]

  validation {
    condition = alltrue([
      for source in var.sources :
      contains([
        "service",
        "ingress",
        "istio-gateway",
        "istio-virtualservice",
        "gateway-httproute",
        "gateway-grpcroute",
        "crd"
      ], source)
    ])

    error_message = "sources contains an unsupported ExternalDNS source."
  }
}

variable "policy" {
  description = "DNS synchronization policy. Use sync to create and delete managed records, or upsert-only to prevent deletion."
  type        = string
  default     = "sync"

  validation {
    condition     = contains(["sync", "upsert-only"], var.policy)
    error_message = "policy must be either sync or upsert-only."
  }
}

variable "registry" {
  description = "Registry used by ExternalDNS to track ownership of DNS records."
  type        = string
  default     = "txt"

  validation {
    condition     = contains(["txt", "noop", "aws-sd"], var.registry)
    error_message = "registry must be txt, noop, or aws-sd."
  }
}

variable "txt_owner_id" {
  description = "Unique identifier recorded in TXT records to establish ExternalDNS ownership."
  type        = string

  validation {
    condition     = length(trimspace(var.txt_owner_id)) > 0
    error_message = "txt_owner_id must not be empty."
  }
}

variable "txt_prefix" {
  description = "Optional prefix added to ExternalDNS ownership TXT records."
  type        = string
  default     = ""
}

variable "aws_zone_type" {
  description = "Type of Route 53 hosted zone ExternalDNS may manage."
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private"], var.aws_zone_type)
    error_message = "aws_zone_type must be public or private."
  }
}

variable "aws_batch_change_size" {
  description = "Maximum number of Route 53 record changes submitted in a single batch."
  type        = number
  default     = 1000

  validation {
    condition = (
      var.aws_batch_change_size >= 1 &&
      var.aws_batch_change_size <= 1000
    )

    error_message = "aws_batch_change_size must be between 1 and 1000."
  }
}

variable "interval" {
  description = "Interval between ExternalDNS reconciliation cycles."
  type        = string
  default     = "1m"

  validation {
    condition     = can(regex("^[0-9]+(s|m|h)$", var.interval))
    error_message = "interval must use a duration such as 30s, 1m, or 1h."
  }
}

variable "trigger_loop_on_event" {
  description = "Trigger reconciliation when watched Kubernetes resources change."
  type        = bool
  default     = true
}

variable "log_level" {
  description = "ExternalDNS logging level."
  type        = string
  default     = "info"

  validation {
    condition = contains([
      "panic",
      "debug",
      "info",
      "warning",
      "error",
      "fatal"
    ], var.log_level)

    error_message = "log_level must be panic, debug, info, warning, error, or fatal."
  }
}

variable "log_format" {
  description = "ExternalDNS log output format."
  type        = string
  default     = "json"

  validation {
    condition     = contains(["text", "json"], var.log_format)
    error_message = "log_format must be text or json."
  }
}

variable "helm_repository" {
  description = "ExternalDNS Helm chart repository."
  type        = string
  default     = "https://kubernetes-sigs.github.io/external-dns/"
}

variable "chart_name" {
  description = "Name of the ExternalDNS Helm chart."
  type        = string
  default     = "external-dns"
}

variable "chart_version" {
  description = "Pinned version of the ExternalDNS Helm chart."
  type        = string
  default     = "1.21.1"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.chart_version))
    error_message = "chart_version must be a semantic version such as 1.21.1."
  }
}

variable "replica_count" {
  description = "Number of ExternalDNS replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.replica_count >= 1
    error_message = "replica_count must be at least 1."
  }
}

variable "resources" {
  description = "CPU and memory requests and limits assigned to ExternalDNS."
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })

  default = {
    requests = {
      cpu    = "50m"
      memory = "64Mi"
    }

    limits = {
      cpu    = "200m"
      memory = "256Mi"
    }
  }
}

variable "pod_labels" {
  description = "Additional labels applied to ExternalDNS Pods."
  type        = map(string)
  default     = {}
}

variable "pod_annotations" {
  description = "Additional annotations applied to ExternalDNS Pods."
  type        = map(string)
  default     = {}
}

variable "node_selector" {
  description = "Node selector used to schedule ExternalDNS Pods."
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Kubernetes tolerations applied to ExternalDNS Pods."
  type        = list(any)
  default     = []
}

variable "affinity" {
  description = "Kubernetes affinity configuration applied to ExternalDNS Pods."
  type        = any
  default     = {}
}

variable "priority_class_name" {
  description = "Optional Kubernetes PriorityClass assigned to ExternalDNS."
  type        = string
  default     = ""
}

variable "enable_service_monitor" {
  description = "Whether to create a Prometheus ServiceMonitor for ExternalDNS."
  type        = bool
  default     = false
}

variable "service_monitor_namespace" {
  description = "Namespace in which the ExternalDNS ServiceMonitor is created."
  type        = string
  default     = ""
}

variable "additional_helm_values" {
  description = "Additional values merged into the ExternalDNS Helm release."
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "Tags applied to AWS resources created by the module."
  type        = map(string)
  default     = {}
}

variable "platform_name" {
  description = "Name of the larger platform that ExternalDNS is part of."
  type        = string

  validation {
    condition     = length(trimspace(var.platform_name)) > 0
    error_message = "platform_name must not be empty."
  }
}