# =============================================================================
# CloudHustler Commerce Platform - Prometheus and Grafana Helm Release
# =============================================================================
# This file deploys and configures the CloudHustler Commerce Platform
# monitoring stack using the kube-prometheus-stack Helm chart.
#
# The Helm release installs and configures:
# - Prometheus Operator and Custom Resource Definitions
# - Prometheus server
# - Alertmanager
# - Grafana
# - kube-state-metrics
# - Prometheus Node Exporter
# - Kubernetes recording and alerting rules
# - Persistent storage for Prometheus, Alertmanager, and Grafana
# =============================================================================

# -----------------------------------------------------------------------------
# Prometheus Persistent Storage
# -----------------------------------------------------------------------------

locals {
  prometheus_storage_spec = var.prometheus_persistence_enabled ? {
    volumeClaimTemplate = {
      spec = {
        storageClassName = var.prometheus_storage_class_name
        accessModes      = var.prometheus_storage_access_modes

        resources = {
          requests = {
            storage = var.prometheus_storage_size
          }
        }
      }
    }
  } : {}
}

# -----------------------------------------------------------------------------
# Alertmanager Persistent Storage
# -----------------------------------------------------------------------------

locals {
  alertmanager_storage_spec = var.alertmanager_persistence_enabled ? {
    storage = {
      volumeClaimTemplate = {
        spec = {
          storageClassName = var.alertmanager_storage_class_name
          accessModes      = ["ReadWriteOnce"]

          resources = {
            requests = {
              storage = var.alertmanager_storage_size
            }
          }
        }
      }
    }
  } : {}
}

# -----------------------------------------------------------------------------
# Prometheus Helm Values
# -----------------------------------------------------------------------------

locals {
  prometheus_helm_values = {
    # -------------------------------------------------------------------------
    # Global Chart Configuration
    # -------------------------------------------------------------------------

    commonLabels = local.common_labels

    crds = {
      enabled = true
    }

    # -------------------------------------------------------------------------
    # Default Kubernetes Monitoring Rules
    # -------------------------------------------------------------------------

    defaultRules = {
      create = var.default_rules_enabled
    }

    # -------------------------------------------------------------------------
    # Grafana
    # -------------------------------------------------------------------------

    grafana = {
      enabled  = var.grafana_enabled
      replicas = var.grafana_replicas

      admin = {
        existingSecret = (
          var.grafana_enabled
          ? kubernetes_secret_v1.grafana_admin[0].metadata[0].name
          : null
        )

        userKey     = "admin-user"
        passwordKey = "admin-password"
      }

      persistence = {
        enabled          = var.grafana_persistence_enabled
        type             = "pvc"
        storageClassName = var.grafana_storage_class_name
        accessModes      = var.grafana_storage_access_modes
        size             = var.grafana_storage_size
      }

      service = {
        type = var.grafana_service_type
        port = var.grafana_service_port
      }

      ingress = {
        enabled = var.grafana_ingress_enabled
      }

      defaultDashboardsEnabled = (
        var.grafana_default_dashboards_enabled
      )

      defaultDashboardsTimezone = (
        var.grafana_default_dashboards_timezone
      )

      sidecar = {
        dashboards = {
          enabled = var.grafana_sidecar_dashboards_enabled
        }

        datasources = {
          enabled = var.grafana_sidecar_datasources_enabled
        }
      }

      "grafana.ini" = {
        server = {
          root_url = var.grafana_root_url
        }

        users = {
          allow_sign_up        = var.grafana_allow_sign_up
          auto_assign_org_role = var.grafana_user_auto_assign_org_role
        }

        "auth.anonymous" = {
          enabled = var.grafana_anonymous_access_enabled
        }

        security = {
          disable_initial_admin_creation = (
            var.grafana_disable_initial_admin_creation
          )
        }
      }

      resources = {
        requests = {
          cpu    = var.grafana_cpu_request
          memory = var.grafana_memory_request
        }

        limits = {
          cpu    = var.grafana_cpu_limit
          memory = var.grafana_memory_limit
        }
      }
    }

    # -------------------------------------------------------------------------
    # Prometheus Operator
    # -------------------------------------------------------------------------

    prometheusOperator = {
      enabled = var.prometheus_operator_enabled

      resources = {
        requests = {
          cpu    = var.prometheus_operator_cpu_request
          memory = var.prometheus_operator_memory_request
        }

        limits = {
          cpu    = var.prometheus_operator_cpu_limit
          memory = var.prometheus_operator_memory_limit
        }
      }
    }

    # -------------------------------------------------------------------------
    # Prometheus Server
    # -------------------------------------------------------------------------

    prometheus = {
      enabled = var.prometheus_enabled

      prometheusSpec = merge(
        {
          replicas           = var.prometheus_replicas
          retention          = var.prometheus_retention
          retentionSize      = var.prometheus_retention_size
          scrapeInterval     = var.prometheus_scrape_interval
          evaluationInterval = var.prometheus_evaluation_interval
          enableAdminAPI     = var.prometheus_enable_admin_api
          routePrefix        = var.prometheus_route_prefix

          resources = {
            requests = {
              cpu    = var.prometheus_cpu_request
              memory = var.prometheus_memory_request
            }

            limits = {
              cpu    = var.prometheus_cpu_limit
              memory = var.prometheus_memory_limit
            }
          }

          serviceMonitorSelectorNilUsesHelmValues = (
            var.service_monitor_selector_nil_uses_helm_values
          )

          podMonitorSelectorNilUsesHelmValues = (
            var.pod_monitor_selector_nil_uses_helm_values
          )

          ruleSelectorNilUsesHelmValues = (
            var.rule_selector_nil_uses_helm_values
          )

          serviceMonitorSelector = {}
          podMonitorSelector     = {}
          ruleSelector           = {}

          serviceMonitorNamespaceSelector = {
            matchLabels = var.service_monitor_namespace_selector
          }

          podMonitorNamespaceSelector = {
            matchLabels = var.pod_monitor_namespace_selector
          }

          ruleNamespaceSelector = {
            matchLabels = var.rule_namespace_selector
          }

          storageSpec = local.prometheus_storage_spec
        },
        length(trimspace(var.prometheus_external_url)) > 0 ? {
          externalUrl = var.prometheus_external_url
        } : {}
      )
    }

    # -------------------------------------------------------------------------
    # Alertmanager
    # -------------------------------------------------------------------------

    alertmanager = {
      enabled = var.alertmanager_enabled

      alertmanagerSpec = merge(
        {
          replicas = var.alertmanager_replicas

          resources = {
            requests = {
              cpu    = var.alertmanager_cpu_request
              memory = var.alertmanager_memory_request
            }

            limits = {
              cpu    = var.alertmanager_cpu_limit
              memory = var.alertmanager_memory_limit
            }
          }
        },
        local.alertmanager_storage_spec
      )
    }

    # -------------------------------------------------------------------------
    # kube-state-metrics
    # -------------------------------------------------------------------------

    kubeStateMetrics = {
      enabled = var.kube_state_metrics_enabled
    }

    "kube-state-metrics" = {
      resources = {
        requests = {
          cpu    = var.kube_state_metrics_cpu_request
          memory = var.kube_state_metrics_memory_request
        }

        limits = {
          cpu    = var.kube_state_metrics_cpu_limit
          memory = var.kube_state_metrics_memory_limit
        }
      }
    }

    # -------------------------------------------------------------------------
    # Prometheus Node Exporter
    # -------------------------------------------------------------------------

    nodeExporter = {
      enabled = var.node_exporter_enabled
    }

    "prometheus-node-exporter" = {
      resources = {
        requests = {
          cpu    = var.node_exporter_cpu_request
          memory = var.node_exporter_memory_request
        }

        limits = {
          cpu    = var.node_exporter_cpu_limit
          memory = var.node_exporter_memory_limit
        }
      }
    }

    # -------------------------------------------------------------------------
    # Kubernetes Control Plane Monitoring
    # -------------------------------------------------------------------------

    kubeApiServer = {
      enabled = var.kube_api_server_monitoring_enabled
    }

    kubelet = {
      enabled = var.kubelet_monitoring_enabled
    }

    coreDns = {
      enabled = var.core_dns_monitoring_enabled
    }

    kubeControllerManager = {
      enabled = var.kube_controller_manager_monitoring_enabled
    }

    kubeScheduler = {
      enabled = var.kube_scheduler_monitoring_enabled
    }

    kubeProxy = {
      enabled = var.kube_proxy_monitoring_enabled
    }

    # -------------------------------------------------------------------------
    # Amazon EKS Component Exclusions
    # -------------------------------------------------------------------------
    # Amazon EKS manages the etcd control-plane component and does not expose
    # it as a customer-managed workload. Direct etcd monitoring is disabled.

    kubeEtcd = {
      enabled = false
    }
  }
}

# -----------------------------------------------------------------------------
# kube-prometheus-stack Helm Release
# -----------------------------------------------------------------------------

resource "helm_release" "this" {
  name       = var.release_name
  namespace  = var.namespace
  repository = var.chart_repository
  chart      = var.chart_name
  version    = var.chart_version

  create_namespace = false

  values = [
    yamlencode(local.prometheus_helm_values)
  ]

  timeout           = var.helm_timeout
  wait              = var.helm_wait
  atomic            = var.helm_atomic
  cleanup_on_fail   = var.helm_cleanup_on_fail
  force_update      = var.helm_force_update
  recreate_pods     = var.helm_recreate_pods
  dependency_update = var.helm_dependency_update

  depends_on = [
    kubernetes_namespace.this,
    kubernetes_secret_v1.grafana_admin
  ]
}