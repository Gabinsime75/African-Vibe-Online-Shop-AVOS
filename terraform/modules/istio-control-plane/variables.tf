###############################################################
# Istio Helm Repository and Charts
###############################################################

variable "chart_repository" {
  description = "Official Istio Helm chart repository."
  type        = string
  default     = "https://istio-release.storage.googleapis.com/charts"
}

variable "chart_version" {
  description = "Pinned version used for both the Istio base and istiod charts."
  type        = string
  default     = "1.30.1"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.chart_version))
    error_message = "chart_version must use semantic version format, such as 1.30.1."
  }
}

variable "base_chart_name" {
  description = "Name of the Istio base Helm chart."
  type        = string
  default     = "base"
}

variable "istiod_chart_name" {
  description = "Name of the Istiod Helm chart."
  type        = string
  default     = "istiod"
}

variable "base_release_name" {
  description = "Helm release name for the Istio base chart."
  type        = string
  default     = "istio-base"
}

variable "istiod_release_name" {
  description = "Helm release name for the Istiod chart."
  type        = string
  default     = "istiod"
}

###############################################################
# Namespace and Installation Behavior
###############################################################

variable "namespace" {
  description = "Kubernetes namespace in which Istio control-plane components are installed."
  type        = string
  default     = "istio-system"
}

variable "create_namespace" {
  description = "Whether Helm creates the Istio namespace."
  type        = bool
  default     = true
}

variable "atomic" {
  description = "Whether failed Helm operations are rolled back automatically."
  type        = bool
  default     = true
}

variable "cleanup_on_fail" {
  description = "Whether Helm deletes newly created resources after a failed upgrade."
  type        = bool
  default     = true
}

variable "wait" {
  description = "Whether Terraform waits for Istio resources to become ready."
  type        = bool
  default     = true
}

variable "helm_timeout" {
  description = "Helm installation and upgrade timeout in seconds."
  type        = number
  default     = 900

  validation {
    condition = (
      var.helm_timeout >= 300 &&
      var.helm_timeout <= 1800
    )

    error_message = "helm_timeout must be between 300 and 1800 seconds."
  }
}

variable "max_history" {
  description = "Maximum number of Helm release revisions retained."
  type        = number
  default     = 10
}

###############################################################
# Istio Revision and Identity
###############################################################

variable "revision" {
  description = "Istio control-plane revision used for revision-based upgrades."
  type        = string
  default     = null
  nullable    = true
}

variable "root_namespace" {
  description = "Namespace containing mesh-wide Istio configuration."
  type        = string
  default     = "istio-system"
}

variable "trust_domain" {
  description = "Istio workload identity trust domain."
  type        = string
  default     = "cluster.local"
}

###############################################################
# Istiod Availability and Autoscaling
###############################################################

variable "enable_autoscaling" {
  description = "Whether Horizontal Pod Autoscaling is enabled for Istiod."
  type        = bool
  default     = true
}

variable "replica_count" {
  description = "Fixed Istiod replica count when autoscaling is disabled."
  type        = number
  default     = 2

  validation {
    condition     = var.replica_count >= 2
    error_message = "replica_count must be at least 2 for high availability."
  }
}

variable "autoscale_min_replicas" {
  description = "Minimum number of Istiod replicas."
  type        = number
  default     = 2

  validation {
    condition     = var.autoscale_min_replicas >= 2
    error_message = "autoscale_min_replicas must be at least 2."
  }
}

variable "autoscale_max_replicas" {
  description = "Maximum number of Istiod replicas."
  type        = number
  default     = 5

  validation {
    condition = (
      var.autoscale_max_replicas >=
      var.autoscale_min_replicas
    )

    error_message = "autoscale_max_replicas must be greater than or equal to autoscale_min_replicas."
  }
}

variable "autoscaling_cpu_target_percentage" {
  description = "Target average CPU utilization for Istiod autoscaling."
  type        = number
  default     = 80

  validation {
    condition = (
      var.autoscaling_cpu_target_percentage >= 1 &&
      var.autoscaling_cpu_target_percentage <= 100
    )

    error_message = "autoscaling_cpu_target_percentage must be between 1 and 100."
  }
}

###############################################################
# Istiod Resources
###############################################################

variable "istiod_cpu_request" {
  description = "CPU request for each Istiod pod."
  type        = string
  default     = "500m"
}

variable "istiod_memory_request" {
  description = "Memory request for each Istiod pod."
  type        = string
  default     = "2048Mi"
}

variable "istiod_cpu_limit" {
  description = "CPU limit for each Istiod pod."
  type        = string
  default     = "2000m"
}

variable "istiod_memory_limit" {
  description = "Memory limit for each Istiod pod."
  type        = string
  default     = "4096Mi"
}

###############################################################
# Sidecar Proxy Resources
###############################################################

variable "proxy_cpu_request" {
  description = "Default CPU request for injected Istio sidecar proxies."
  type        = string
  default     = "100m"
}

variable "proxy_memory_request" {
  description = "Default memory request for injected Istio sidecar proxies."
  type        = string
  default     = "128Mi"
}

variable "proxy_cpu_limit" {
  description = "Default CPU limit for injected Istio sidecar proxies."
  type        = string
  default     = "2000m"
}

variable "proxy_memory_limit" {
  description = "Default memory limit for injected Istio sidecar proxies."
  type        = string
  default     = "1024Mi"
}

###############################################################
# Mesh Features
###############################################################

variable "enable_sidecar_injection" {
  description = "Whether automatic sidecar injection support is enabled globally."
  type        = bool
  default     = true
}

variable "enable_gateway_api" {
  description = "Whether Kubernetes Gateway API support is enabled."
  type        = bool
  default     = true
}

variable "enable_gateway_api_status" {
  description = "Whether Istio updates Kubernetes Gateway API status resources."
  type        = bool
  default     = true
}

variable "enable_native_sidecars" {
  description = "Whether Kubernetes native sidecar container support is enabled."
  type        = bool
  default     = true
}

variable "enable_status" {
  description = "Whether Istio status reporting is enabled."
  type        = bool
  default     = true
}

variable "enable_config_analysis" {
  description = "Whether Istiod performs configuration analysis."
  type        = bool
  default     = true
}

variable "enable_ip_autoallocate" {
  description = "Whether Istio automatically allocates IPs for eligible service entries."
  type        = bool
  default     = false
}

variable "enable_telemetry" {
  description = "Whether Istio telemetry functionality is enabled."
  type        = bool
  default     = true
}

variable "enable_tracing" {
  description = "Whether distributed tracing is enabled in the mesh."
  type        = bool
  default     = true
}

variable "tracing_sampling_percentage" {
  description = "Percentage of requests sampled for distributed tracing."
  type        = number
  default     = 1.0

  validation {
    condition = (
      var.tracing_sampling_percentage >= 0 &&
      var.tracing_sampling_percentage <= 100
    )

    error_message = "tracing_sampling_percentage must be between 0 and 100."
  }
}

variable "enable_access_logging" {
  description = "Whether Envoy access logs are written to standard output."
  type        = bool
  default     = true
}

variable "access_log_encoding" {
  description = "Encoding used for Envoy access logs."
  type        = string
  default     = "JSON"

  validation {
    condition = contains(
      ["TEXT", "JSON"],
      var.access_log_encoding
    )

    error_message = "access_log_encoding must be TEXT or JSON."
  }
}

variable "hold_application_until_proxy_starts" {
  description = "Whether application containers wait for the Istio proxy to start."
  type        = bool
  default     = true
}

variable "termination_drain_duration" {
  description = "Time allowed for the proxy to drain connections during termination."
  type        = string
  default     = "30s"
}

variable "outbound_traffic_policy_mode" {
  description = "Controls whether workloads can access destinations not declared in the mesh registry."
  type        = string
  default     = "REGISTRY_ONLY"

  validation {
    condition = contains(
      ["ALLOW_ANY", "REGISTRY_ONLY"],
      var.outbound_traffic_policy_mode
    )

    error_message = "outbound_traffic_policy_mode must be ALLOW_ANY or REGISTRY_ONLY."
  }
}

###############################################################
# Images
###############################################################

variable "image_hub" {
  description = "Optional custom Istio image registry."
  type        = string
  default     = null
}

variable "image_tag" {
  description = "Optional custom Istio image tag."
  type        = string
  default     = null
}

###############################################################
# Additional Configuration
###############################################################

variable "proxy_metadata" {
  description = "Additional metadata supplied to Istio proxies."
  type        = map(string)
  default     = {}
}

variable "additional_pilot_environment" {
  description = "Additional environment variables supplied to Istiod."
  type        = map(string)
  default     = {}
}

variable "additional_base_values" {
  description = "Additional raw YAML values passed to the Istio base chart."
  type        = list(string)
  default     = []
}

variable "additional_istiod_values" {
  description = "Additional raw YAML values merged after the module's default Istiod values."
  type        = list(string)
  default     = []
}