# =============================================================================
# CloudHustler Commerce Platform - Prometheus Module Variables
# =============================================================================
# This file defines the input variables used by the Prometheus module.
#
# The module deploys the kube-prometheus-stack Helm chart and configures:
# - Prometheus Operator
# - Prometheus Server
# - Alertmanager
# - Grafana
# - kube-state-metrics
# - Prometheus Node Exporter
# - Persistent metric storage
# - Metric retention
# - Kubernetes monitoring rules
# =============================================================================

# -----------------------------------------------------------------------------
# Project Configuration
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Name of the CloudHustler Commerce Platform project."
  type        = string

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name must not be empty."
  }
}

variable "environment" {
  description = "Deployment environment for the Prometheus monitoring stack."
  type        = string

  validation {
    condition = contains(
      ["dev", "staging", "prod"],
      var.environment
    )

    error_message = "environment must be dev, staging, or prod."
  }
}

variable "tags" {
  description = "Common tags applied to supported Prometheus-related resources."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Kubernetes Namespace Configuration
# -----------------------------------------------------------------------------

variable "namespace" {
  description = "Kubernetes namespace in which the monitoring stack will be deployed."
  type        = string
  default     = "monitoring"

  validation {
    condition     = length(trimspace(var.namespace)) > 0
    error_message = "namespace must not be empty."
  }
}

variable "create_namespace" {
  description = "Determines whether the Prometheus module creates the Kubernetes namespace."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Helm Release Configuration
# -----------------------------------------------------------------------------

variable "release_name" {
  description = "Helm release name for the kube-prometheus-stack deployment."
  type        = string
  default     = "kube-prometheus-stack"

  validation {
    condition     = length(trimspace(var.release_name)) > 0
    error_message = "release_name must not be empty."
  }
}

variable "chart_repository" {
  description = "Helm repository containing the kube-prometheus-stack chart."
  type        = string
  default     = "https://prometheus-community.github.io/helm-charts"

  validation {
    condition     = can(regex("^https://", var.chart_repository))
    error_message = "chart_repository must be a valid HTTPS URL."
  }
}

variable "chart_name" {
  description = "Name of the Helm chart used to deploy the Prometheus monitoring stack."
  type        = string
  default     = "kube-prometheus-stack"

  validation {
    condition     = length(trimspace(var.chart_name)) > 0
    error_message = "chart_name must not be empty."
  }
}

variable "chart_version" {
  description = "Pinned version of the kube-prometheus-stack Helm chart."
  type        = string
  default     = "87.19.1"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.chart_version))
    error_message = "chart_version must use semantic version format, such as 87.19.1."
  }
}

variable "helm_timeout" {
  description = "Maximum number of seconds Terraform waits for the Helm release operation to complete."
  type        = number
  default     = 1200

  validation {
    condition     = var.helm_timeout >= 300
    error_message = "helm_timeout must be at least 300 seconds."
  }
}

variable "helm_wait" {
  description = "Determines whether Terraform waits for all Helm resources to become ready."
  type        = bool
  default     = true
}

variable "helm_atomic" {
  description = "Determines whether Helm rolls back changes when the installation or upgrade fails."
  type        = bool
  default     = false
}

variable "helm_cleanup_on_fail" {
  description = "Determines whether Helm removes newly created resources after a failed upgrade."
  type        = bool
  default     = false
}

variable "helm_force_update" {
  description = "Determines whether Helm forces resource updates when necessary."
  type        = bool
  default     = false
}

variable "helm_recreate_pods" {
  description = "Determines whether Helm recreates pods during an upgrade."
  type        = bool
  default     = false
}

variable "helm_dependency_update" {
  description = "Determines whether Helm updates chart dependencies before installation."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Prometheus Configuration
# -----------------------------------------------------------------------------

variable "prometheus_enabled" {
  description = "Determines whether the Prometheus server is enabled."
  type        = bool
  default     = true
}

variable "prometheus_replicas" {
  description = "Number of Prometheus server replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.prometheus_replicas >= 1
    error_message = "prometheus_replicas must be at least 1."
  }
}

variable "prometheus_retention" {
  description = "Length of time Prometheus retains metrics."
  type        = string
  default     = "15d"

  validation {
    condition     = can(regex("^[0-9]+(h|d|w|y)$", var.prometheus_retention))
    error_message = "prometheus_retention must use a valid duration such as 24h, 15d, 4w, or 1y."
  }
}

variable "prometheus_retention_size" {
  description = "Maximum amount of disk space Prometheus may use for retained metrics."
  type        = string
  default     = "45GB"

  validation {
    condition     = can(regex("^[0-9]+(MB|GB|TB)$", var.prometheus_retention_size))
    error_message = "prometheus_retention_size must use a value such as 500MB, 45GB, or 1TB."
  }
}

variable "prometheus_scrape_interval" {
  description = "Default interval at which Prometheus scrapes configured targets."
  type        = string
  default     = "30s"

  validation {
    condition     = can(regex("^[0-9]+(s|m|h)$", var.prometheus_scrape_interval))
    error_message = "prometheus_scrape_interval must use a valid duration such as 30s, 1m, or 1h."
  }
}

variable "prometheus_evaluation_interval" {
  description = "Default interval at which Prometheus evaluates recording and alerting rules."
  type        = string
  default     = "30s"

  validation {
    condition     = can(regex("^[0-9]+(s|m|h)$", var.prometheus_evaluation_interval))
    error_message = "prometheus_evaluation_interval must use a valid duration such as 30s, 1m, or 1h."
  }
}

variable "prometheus_enable_admin_api" {
  description = "Determines whether the Prometheus administrative API is enabled."
  type        = bool
  default     = false
}

variable "prometheus_external_url" {
  description = "Optional external URL used by Prometheus when generating links."
  type        = string
  default     = ""
}

variable "prometheus_route_prefix" {
  description = "HTTP route prefix used by the Prometheus web interface."
  type        = string
  default     = "/"
}

# -----------------------------------------------------------------------------
# Prometheus Resource Configuration
# -----------------------------------------------------------------------------

variable "prometheus_cpu_request" {
  description = "CPU requested by the Prometheus server."
  type        = string
  default     = "500m"

  validation {
    condition     = length(trimspace(var.prometheus_cpu_request)) > 0
    error_message = "prometheus_cpu_request must not be empty."
  }
}

variable "prometheus_memory_request" {
  description = "Memory requested by the Prometheus server."
  type        = string
  default     = "2Gi"

  validation {
    condition     = length(trimspace(var.prometheus_memory_request)) > 0
    error_message = "prometheus_memory_request must not be empty."
  }
}

variable "prometheus_cpu_limit" {
  description = "Maximum CPU available to the Prometheus server."
  type        = string
  default     = "2"

  validation {
    condition     = length(trimspace(var.prometheus_cpu_limit)) > 0
    error_message = "prometheus_cpu_limit must not be empty."
  }
}

variable "prometheus_memory_limit" {
  description = "Maximum memory available to the Prometheus server."
  type        = string
  default     = "4Gi"

  validation {
    condition     = length(trimspace(var.prometheus_memory_limit)) > 0
    error_message = "prometheus_memory_limit must not be empty."
  }
}

# -----------------------------------------------------------------------------
# Prometheus Persistent Storage Configuration
# -----------------------------------------------------------------------------

variable "prometheus_persistence_enabled" {
  description = "Determines whether persistent storage is enabled for Prometheus."
  type        = bool
  default     = true
}

variable "prometheus_storage_class_name" {
  description = "Kubernetes StorageClass used by the Prometheus persistent volume claim."
  type        = string
  default     = "gp3"

  validation {
    condition     = length(trimspace(var.prometheus_storage_class_name)) > 0
    error_message = "prometheus_storage_class_name must not be empty."
  }
}

variable "prometheus_storage_size" {
  description = "Persistent volume size allocated to the Prometheus server."
  type        = string
  default     = "50Gi"

  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi|Ti)$", var.prometheus_storage_size))
    error_message = "prometheus_storage_size must use a Kubernetes storage value such as 50Gi."
  }
}

variable "prometheus_storage_access_modes" {
  description = "Access modes assigned to the Prometheus persistent volume claim."
  type        = list(string)
  default     = ["ReadWriteOnce"]

  validation {
    condition = alltrue([
      for access_mode in var.prometheus_storage_access_modes :
      contains(
        ["ReadWriteOnce", "ReadOnlyMany", "ReadWriteMany", "ReadWriteOncePod"],
        access_mode
      )
    ])

    error_message = "prometheus_storage_access_modes contains an unsupported Kubernetes access mode."
  }
}

# -----------------------------------------------------------------------------
# Prometheus Service Discovery Configuration
# -----------------------------------------------------------------------------

variable "service_monitor_selector_nil_uses_helm_values" {
  description = "Determines whether an empty ServiceMonitor selector uses the Helm release labels."
  type        = bool
  default     = false
}

variable "pod_monitor_selector_nil_uses_helm_values" {
  description = "Determines whether an empty PodMonitor selector uses the Helm release labels."
  type        = bool
  default     = false
}

variable "rule_selector_nil_uses_helm_values" {
  description = "Determines whether an empty PrometheusRule selector uses the Helm release labels."
  type        = bool
  default     = false
}

variable "service_monitor_namespace_selector" {
  description = "Namespace labels used to select ServiceMonitor resources. An empty map allows discovery across all namespaces."
  type        = map(string)
  default     = {}
}

variable "pod_monitor_namespace_selector" {
  description = "Namespace labels used to select PodMonitor resources. An empty map allows discovery across all namespaces."
  type        = map(string)
  default     = {}
}

variable "rule_namespace_selector" {
  description = "Namespace labels used to select PrometheusRule resources. An empty map allows discovery across all namespaces."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Prometheus Operator Configuration
# -----------------------------------------------------------------------------

variable "prometheus_operator_enabled" {
  description = "Determines whether the Prometheus Operator is enabled."
  type        = bool
  default     = true
}

variable "prometheus_operator_cpu_request" {
  description = "CPU requested by the Prometheus Operator."
  type        = string
  default     = "100m"
}

variable "prometheus_operator_memory_request" {
  description = "Memory requested by the Prometheus Operator."
  type        = string
  default     = "128Mi"
}

variable "prometheus_operator_cpu_limit" {
  description = "Maximum CPU available to the Prometheus Operator."
  type        = string
  default     = "500m"
}

variable "prometheus_operator_memory_limit" {
  description = "Maximum memory available to the Prometheus Operator."
  type        = string
  default     = "512Mi"
}

# -----------------------------------------------------------------------------
# Alertmanager Configuration
# -----------------------------------------------------------------------------

variable "alertmanager_enabled" {
  description = "Determines whether Alertmanager is enabled."
  type        = bool
  default     = true
}

variable "alertmanager_replicas" {
  description = "Number of Alertmanager replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.alertmanager_replicas >= 1
    error_message = "alertmanager_replicas must be at least 1 when Alertmanager is enabled."
  }
}

variable "alertmanager_cpu_request" {
  description = "CPU requested by Alertmanager."
  type        = string
  default     = "100m"
}

variable "alertmanager_memory_request" {
  description = "Memory requested by Alertmanager."
  type        = string
  default     = "128Mi"
}

variable "alertmanager_cpu_limit" {
  description = "Maximum CPU available to Alertmanager."
  type        = string
  default     = "500m"
}

variable "alertmanager_memory_limit" {
  description = "Maximum memory available to Alertmanager."
  type        = string
  default     = "512Mi"
}

variable "alertmanager_persistence_enabled" {
  description = "Determines whether persistent storage is enabled for Alertmanager."
  type        = bool
  default     = true
}

variable "alertmanager_storage_class_name" {
  description = "Kubernetes StorageClass used by the Alertmanager persistent volume claim."
  type        = string
  default     = "gp3"
}

variable "alertmanager_storage_size" {
  description = "Persistent volume size allocated to Alertmanager."
  type        = string
  default     = "10Gi"

  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi|Ti)$", var.alertmanager_storage_size))
    error_message = "alertmanager_storage_size must use a Kubernetes storage value such as 10Gi."
  }
}

# -----------------------------------------------------------------------------
# Kubernetes Monitoring Components
# -----------------------------------------------------------------------------

variable "default_rules_enabled" {
  description = "Determines whether the default Kubernetes alerting and recording rules are enabled."
  type        = bool
  default     = true
}

variable "kube_state_metrics_enabled" {
  description = "Determines whether kube-state-metrics is enabled."
  type        = bool
  default     = true
}

variable "node_exporter_enabled" {
  description = "Determines whether Prometheus Node Exporter is enabled."
  type        = bool
  default     = true
}

variable "kube_api_server_monitoring_enabled" {
  description = "Determines whether Kubernetes API server monitoring is enabled."
  type        = bool
  default     = true
}

variable "kubelet_monitoring_enabled" {
  description = "Determines whether kubelet monitoring is enabled."
  type        = bool
  default     = true
}

variable "core_dns_monitoring_enabled" {
  description = "Determines whether CoreDNS monitoring is enabled."
  type        = bool
  default     = true
}

variable "kube_controller_manager_monitoring_enabled" {
  description = "Determines whether Kubernetes controller manager monitoring is enabled."
  type        = bool
  default     = false
}

variable "kube_scheduler_monitoring_enabled" {
  description = "Determines whether Kubernetes scheduler monitoring is enabled."
  type        = bool
  default     = false
}

variable "kube_proxy_monitoring_enabled" {
  description = "Determines whether kube-proxy monitoring is enabled."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Component Resource Configuration
# -----------------------------------------------------------------------------

variable "kube_state_metrics_cpu_request" {
  description = "CPU requested by kube-state-metrics."
  type        = string
  default     = "50m"
}

variable "kube_state_metrics_memory_request" {
  description = "Memory requested by kube-state-metrics."
  type        = string
  default     = "128Mi"
}

variable "kube_state_metrics_cpu_limit" {
  description = "Maximum CPU available to kube-state-metrics."
  type        = string
  default     = "250m"
}

variable "kube_state_metrics_memory_limit" {
  description = "Maximum memory available to kube-state-metrics."
  type        = string
  default     = "256Mi"
}

variable "node_exporter_cpu_request" {
  description = "CPU requested by Prometheus Node Exporter."
  type        = string
  default     = "50m"
}

variable "node_exporter_memory_request" {
  description = "Memory requested by Prometheus Node Exporter."
  type        = string
  default     = "64Mi"
}

variable "node_exporter_cpu_limit" {
  description = "Maximum CPU available to Prometheus Node Exporter."
  type        = string
  default     = "200m"
}

variable "node_exporter_memory_limit" {
  description = "Maximum memory available to Prometheus Node Exporter."
  type        = string
  default     = "128Mi"
}

# =============================================================================
# Grafana Phase 2 Configuration
# =============================================================================
# The following variables configure Grafana as the visualization layer for the
# CloudHustler Commerce Platform monitoring stack.
#
# Grafana is deployed through the kube-prometheus-stack Helm chart and uses
# Prometheus as its default metrics data source.
# =============================================================================

# -----------------------------------------------------------------------------
# Grafana Deployment
# -----------------------------------------------------------------------------

variable "grafana_enabled" {
  description = "Controls whether Grafana is deployed as part of the monitoring stack."
  type        = bool
  default     = true
}

variable "grafana_replicas" {
  description = "Number of Grafana replicas to deploy."
  type        = number
  default     = 1

  validation {
    condition     = var.grafana_replicas >= 1
    error_message = "grafana_replicas must be at least 1."
  }
}

# -----------------------------------------------------------------------------
# Grafana Administrative Credentials
# -----------------------------------------------------------------------------

variable "grafana_admin_user" {
  description = "Grafana administrator username stored in the Kubernetes Secret."
  type        = string
  default     = "admin"

  validation {
    condition     = length(trimspace(var.grafana_admin_user)) > 0
    error_message = "grafana_admin_user cannot be empty."
  }
}

variable "grafana_admin_password" {
  description = "Grafana administrator password stored in the Kubernetes Secret."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.grafana_admin_password) >= 12
    error_message = "grafana_admin_password must contain at least 12 characters."
  }
}

# -----------------------------------------------------------------------------
# Grafana Persistent Storage
# -----------------------------------------------------------------------------

variable "grafana_persistence_enabled" {
  description = "Controls whether Grafana uses persistent storage."
  type        = bool
  default     = true
}

variable "grafana_storage_class_name" {
  description = "Kubernetes StorageClass used by the Grafana persistent volume."
  type        = string
  default     = "gp3"

  validation {
    condition     = length(trimspace(var.grafana_storage_class_name)) > 0
    error_message = "grafana_storage_class_name cannot be empty."
  }
}

variable "grafana_storage_access_modes" {
  description = "Access modes requested by the Grafana persistent volume claim."
  type        = list(string)
  default     = ["ReadWriteOnce"]

  validation {
    condition     = length(var.grafana_storage_access_modes) > 0
    error_message = "grafana_storage_access_modes must contain at least one access mode."
  }
}

variable "grafana_storage_size" {
  description = "Persistent volume capacity requested for Grafana."
  type        = string
  default     = "10Gi"

  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi|Ti)$", var.grafana_storage_size))
    error_message = "grafana_storage_size must use a Kubernetes quantity such as 10Gi."
  }
}

# -----------------------------------------------------------------------------
# Grafana Service and Access
# -----------------------------------------------------------------------------

variable "grafana_service_type" {
  description = "Kubernetes Service type used to expose Grafana."
  type        = string
  default     = "ClusterIP"

  validation {
    condition = contains(
      ["ClusterIP", "NodePort", "LoadBalancer"],
      var.grafana_service_type
    )

    error_message = "grafana_service_type must be ClusterIP, NodePort, or LoadBalancer."
  }
}

variable "grafana_service_port" {
  description = "Port exposed by the Grafana Kubernetes Service."
  type        = number
  default     = 80

  validation {
    condition = (
      var.grafana_service_port >= 1 &&
      var.grafana_service_port <= 65535
    )

    error_message = "grafana_service_port must be between 1 and 65535."
  }
}

variable "grafana_ingress_enabled" {
  description = "Controls whether the Grafana Helm subchart creates a Kubernetes Ingress."
  type        = bool
  default     = false
}

variable "grafana_root_url" {
  description = "Externally accessible Grafana URL. Leave empty while using port forwarding."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Grafana Dashboard Provisioning
# -----------------------------------------------------------------------------

variable "grafana_default_dashboards_enabled" {
  description = "Controls whether kube-prometheus-stack Kubernetes dashboards are provisioned."
  type        = bool
  default     = true
}

variable "grafana_default_dashboards_timezone" {
  description = "Timezone used by the default Kubernetes Grafana dashboards."
  type        = string
  default     = "browser"

  validation {
    condition     = length(trimspace(var.grafana_default_dashboards_timezone)) > 0
    error_message = "grafana_default_dashboards_timezone cannot be empty."
  }
}

variable "grafana_sidecar_dashboards_enabled" {
  description = "Enables the Grafana sidecar that discovers dashboard ConfigMaps."
  type        = bool
  default     = true
}

variable "grafana_sidecar_datasources_enabled" {
  description = "Enables the Grafana sidecar that discovers datasource ConfigMaps."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Grafana Security Configuration
# -----------------------------------------------------------------------------

variable "grafana_disable_initial_admin_creation" {
  description = "Disables creation of the initial Grafana administrator account."
  type        = bool
  default     = false
}

variable "grafana_allow_sign_up" {
  description = "Controls whether anonymous users may register Grafana accounts."
  type        = bool
  default     = false
}

variable "grafana_anonymous_access_enabled" {
  description = "Controls whether Grafana permits anonymous access."
  type        = bool
  default     = false
}

variable "grafana_user_auto_assign_org_role" {
  description = "Default organization role assigned to automatically created Grafana users."
  type        = string
  default     = "Viewer"

  validation {
    condition = contains(
      ["Viewer", "Editor", "Admin"],
      var.grafana_user_auto_assign_org_role
    )

    error_message = "grafana_user_auto_assign_org_role must be Viewer, Editor, or Admin."
  }
}

# -----------------------------------------------------------------------------
# Grafana Resource Allocation
# -----------------------------------------------------------------------------

variable "grafana_cpu_request" {
  description = "CPU requested by the Grafana container."
  type        = string
  default     = "100m"
}

variable "grafana_memory_request" {
  description = "Memory requested by the Grafana container."
  type        = string
  default     = "256Mi"
}

variable "grafana_cpu_limit" {
  description = "Maximum CPU available to the Grafana container."
  type        = string
  default     = "500m"
}

variable "grafana_memory_limit" {
  description = "Maximum memory available to the Grafana container."
  type        = string
  default     = "512Mi"
}

# =============================================================================
# Istio Monitoring
# =============================================================================

variable "istiod_service_monitor_enabled" {
  description = "Controls whether the Istiod ServiceMonitor is created."
  type        = bool
  default     = true
}

variable "istio_namespace" {
  description = "Kubernetes namespace containing the Istio control plane."
  type        = string
  default     = "istio-system"

  validation {
    condition     = length(trimspace(var.istio_namespace)) > 0
    error_message = "istio_namespace must not be empty."
  }
}

variable "istio_revision" {
  description = "Istio control-plane revision selected by the ServiceMonitor."
  type        = string
  default     = "default"
  nullable    = false

  validation {
    condition     = length(trimspace(var.istio_revision)) > 0
    error_message = "istio_revision must not be empty."
  }
}

variable "istiod_metrics_port_name" {
  description = "Name of the Istiod Kubernetes Service port exposing Prometheus metrics."
  type        = string
  default     = "http-monitoring"
}

variable "istiod_metrics_path" {
  description = "HTTP path used to scrape Istiod Prometheus metrics."
  type        = string
  default     = "/metrics"
}

variable "istiod_scrape_interval" {
  description = "Interval at which Prometheus scrapes Istiod metrics."
  type        = string
  default     = "30s"
}

variable "istiod_scrape_timeout" {
  description = "Maximum duration allowed for each Istiod metrics scrape."
  type        = string
  default     = "10s"
}

# =============================================================================
# Istio Ingress Gateway Monitoring
# =============================================================================

variable "istio_ingress_pod_monitor_enabled" {
  description = "Controls whether the Istio ingress gateway PodMonitor is created."
  type        = bool
  default     = true
}

variable "istio_ingress_namespace" {
  description = "Kubernetes namespace containing the Istio ingress gateway."
  type        = string
  default     = "istio-ingress"
  nullable    = false

  validation {
    condition     = length(trimspace(var.istio_ingress_namespace)) > 0
    error_message = "istio_ingress_namespace must not be empty."
  }
}

variable "istio_ingress_app_name" {
  description = "Application label used to select the Istio ingress gateway pods."
  type        = string
  default     = "istio-ingress"
  nullable    = false

  validation {
    condition     = length(trimspace(var.istio_ingress_app_name)) > 0
    error_message = "istio_ingress_app_name must not be empty."
  }
}

variable "istio_ingress_metrics_port" {
  description = "Container port exposing Istio ingress gateway Envoy metrics."
  type        = number
  default     = 15090

  validation {
    condition     = var.istio_ingress_metrics_port > 0 && var.istio_ingress_metrics_port <= 65535
    error_message = "istio_ingress_metrics_port must be a valid TCP port."
  }
}

variable "istio_ingress_metrics_path" {
  description = "HTTP path exposing Istio ingress gateway Prometheus metrics."
  type        = string
  default     = "/stats/prometheus"
  nullable    = false
}

variable "istio_ingress_scrape_interval" {
  description = "Interval at which Prometheus scrapes Istio ingress gateway metrics."
  type        = string
  default     = "30s"
  nullable    = false
}

variable "istio_ingress_scrape_timeout" {
  description = "Maximum duration allowed for each ingress gateway scrape."
  type        = string
  default     = "10s"
  nullable    = false
}

variable "istio_ingress_metrics_port_name" {
  description = "Named container port exposing Istio ingress Envoy metrics."
  type        = string
  default     = "http-envoy-prom"
  nullable    = false
}