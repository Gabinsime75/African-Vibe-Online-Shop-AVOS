###############################################################
# Helm Chart
###############################################################

variable "chart_repository" {
  description = "Official Istio Helm repository."
  type        = string
  default     = "https://istio-release.storage.googleapis.com/charts"
}

variable "chart_name" {
  description = "Istio gateway Helm chart name."
  type        = string
  default     = "gateway"
}

variable "chart_version" {
  description = "Pinned Istio gateway chart version."
  type        = string
  default     = "1.30.1"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.chart_version))
    error_message = "chart_version must use semantic version format."
  }
}

variable "release_name" {
  description = "Helm release name for the Istio ingress gateway."
  type        = string
  default     = "istio-ingress"
}

variable "gateway_name" {
  description = "Name assigned to the Istio ingress gateway resources."
  type        = string
  default     = "istio-ingress"
}

variable "namespace" {
  description = "Namespace containing the Istio ingress gateway."
  type        = string
  default     = "istio-ingress"
}

variable "create_namespace" {
  description = "Whether Helm creates the gateway namespace."
  type        = bool
  default     = true
}

variable "revision" {
  description = "Istio control-plane revision used by the gateway."
  type        = string
  default     = null
  nullable    = true
}

###############################################################
# Availability and Scaling
###############################################################

variable "enable_autoscaling" {
  description = "Whether autoscaling is enabled for the ingress gateway."
  type        = bool
  default     = true
}

variable "replica_count" {
  description = "Fixed gateway replica count when autoscaling is disabled."
  type        = number
  default     = 2

  validation {
    condition     = var.replica_count >= 2
    error_message = "replica_count must be at least 2."
  }
}

variable "autoscale_min_replicas" {
  description = "Minimum number of gateway replicas."
  type        = number
  default     = 2

  validation {
    condition     = var.autoscale_min_replicas >= 2
    error_message = "autoscale_min_replicas must be at least 2."
  }
}

variable "autoscale_max_replicas" {
  description = "Maximum number of gateway replicas."
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
  description = "Target CPU utilization for gateway autoscaling."
  type        = number
  default     = 70
}

variable "autoscaling_memory_target_percentage" {
  description = "Target memory utilization for gateway autoscaling."
  type        = number
  default     = 80
}

###############################################################
# Gateway Resources
###############################################################

variable "cpu_request" {
  description = "CPU request for each ingress gateway pod."
  type        = string
  default     = "200m"
}

variable "memory_request" {
  description = "Memory request for each ingress gateway pod."
  type        = string
  default     = "256Mi"
}

variable "cpu_limit" {
  description = "CPU limit for each ingress gateway pod."
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "Memory limit for each ingress gateway pod."
  type        = string
  default     = "1024Mi"
}

###############################################################
# Pod Security
###############################################################

variable "run_as_user" {
  description = "User ID used by the gateway container."
  type        = number
  default     = 1337
}

variable "run_as_group" {
  description = "Group ID used by the gateway container."
  type        = number
  default     = 1337
}

variable "read_only_root_filesystem" {
  description = "Whether the gateway container uses a read-only root filesystem."
  type        = bool
  default     = false
}

variable "termination_grace_period_seconds" {
  description = "Time allowed for gateway connection draining during termination."
  type        = number
  default     = 30
}

###############################################################
# Pod Scheduling
###############################################################

variable "pod_disruption_budget_min_available" {
  description = "Minimum number of gateway pods that must remain available."
  type        = number
  default     = 1
}

variable "node_selector" {
  description = "Node selector used by ingress gateway pods."
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Tolerations assigned to ingress gateway pods."
  type        = list(any)
  default     = []
}

variable "affinity" {
  description = "Affinity configuration for ingress gateway pods."
  type        = any
  default     = {}
}

variable "topology_spread_constraints" {
  description = "Topology spread constraints for gateway pods."
  type        = list(any)

  default = [
    {
      maxSkew           = 1
      topologyKey       = "topology.kubernetes.io/zone"
      whenUnsatisfiable = "ScheduleAnyway"

      labelSelector = {
        matchLabels = {
          app = "istio-ingress"
        }
      }
    },
    {
      maxSkew           = 1
      topologyKey       = "kubernetes.io/hostname"
      whenUnsatisfiable = "ScheduleAnyway"

      labelSelector = {
        matchLabels = {
          app = "istio-ingress"
        }
      }
    }
  ]
}

###############################################################
# Metadata
###############################################################

variable "service_annotations" {
  description = "Annotations applied to the ClusterIP gateway Service."
  type        = map(string)
  default     = {}
}

variable "pod_annotations" {
  description = "Annotations applied to gateway pods."
  type        = map(string)
  default     = {}
}

variable "additional_labels" {
  description = "Additional labels applied to gateway resources."
  type        = map(string)

  default = {
    app   = "istio-ingress"
    istio = "ingressgateway"
  }
}

###############################################################
# Helm Behavior
###############################################################

variable "atomic" {
  description = "Whether failed Helm operations are rolled back."
  type        = bool
  default     = true
}

variable "cleanup_on_fail" {
  description = "Whether Helm removes resources created by a failed upgrade."
  type        = bool
  default     = true
}

variable "wait" {
  description = "Whether Terraform waits for gateway resources to become ready."
  type        = bool
  default     = true
}

variable "helm_timeout" {
  description = "Helm timeout in seconds."
  type        = number
  default     = 900
}

variable "max_history" {
  description = "Maximum number of Helm revisions retained."
  type        = number
  default     = 10
}

variable "additional_values" {
  description = "Additional raw YAML values applied after the module defaults."
  type        = list(string)
  default     = []
}