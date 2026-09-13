# =============================================================================
# CloudHustler Commerce Platform
# Loki Terraform Module
#
# This file creates the Kubernetes namespace and deploys Grafana Loki using
# the official Helm chart. Loki provides centralized storage and querying for
# Kubernetes container logs collected by Fluent Bit.
#
# Deployment model:
# - SingleBinary Loki deployment
# - One development replica
# - Filesystem storage backed by an EBS persistent volume
# - Internal ClusterIP gateway
# - Prometheus ServiceMonitor integration
# - Loki Canary for continuous write and query validation
# =============================================================================

# -----------------------------------------------------------------------------
# Loki Namespace
# -----------------------------------------------------------------------------

resource "kubernetes_namespace_v1" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace

    labels = merge(
      {
        "app.kubernetes.io/name"       = "loki"
        "app.kubernetes.io/component"  = "logging"
        "app.kubernetes.io/part-of"    = var.project_name
        "app.kubernetes.io/managed-by" = "terraform"
        environment                    = var.environment
      },
      var.namespace_labels
    )
  }
}

# -----------------------------------------------------------------------------
# Loki Helm Release
# -----------------------------------------------------------------------------

resource "helm_release" "this" {
  name       = var.release_name
  namespace  = var.namespace
  repository = var.chart_repository
  chart      = var.chart_name
  version    = var.chart_version

  create_namespace = false

  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  wait            = true
  timeout         = var.timeout

  values = [
    yamlencode({
      # -----------------------------------------------------------------------
      # Deployment Mode
      # -----------------------------------------------------------------------

      deploymentMode = "SingleBinary"

      # -----------------------------------------------------------------------
      # Loki Configuration
      # -----------------------------------------------------------------------

      loki = {
        auth_enabled = false

        commonConfig = {
          replication_factor = 1
        }

        schemaConfig = {
          configs = [
            {
              from         = var.schema_start_date
              store        = "tsdb"
              object_store = "filesystem"
              schema       = "v13"

              index = {
                prefix = "loki_index_"
                period = "24h"
              }
            }
          ]
        }

        storage = {
          type = "filesystem"
        }

        limits_config = {
          allow_structured_metadata   = true
          retention_period            = var.retention_period
          ingestion_rate_mb           = var.ingestion_rate_mb
          ingestion_burst_size_mb     = var.ingestion_burst_size_mb
          max_query_parallelism       = var.max_query_parallelism
          max_query_series            = var.max_query_series
          reject_old_samples          = true
          reject_old_samples_max_age  = var.reject_old_samples_max_age
          per_stream_rate_limit       = var.per_stream_rate_limit
          per_stream_rate_limit_burst = var.per_stream_rate_limit_burst
        }

        compactor = {
          working_directory      = "/var/loki/compactor"
          compaction_interval    = var.compaction_interval
          retention_enabled      = true
          retention_delete_delay = var.retention_delete_delay
          delete_request_store   = "filesystem"
        }

        analytics = {
          reporting_enabled = false
        }
      }

      # -----------------------------------------------------------------------
      # Single Binary Loki Workload
      # -----------------------------------------------------------------------

      singleBinary = {
        replicas = var.replica_count

        persistence = {
          enabled      = true
          storageClass = var.storage_class_name
          size         = var.storage_size
          accessModes  = ["ReadWriteOnce"]
        }

        resources = {
          requests = {
            cpu    = var.cpu_request
            memory = var.memory_request
          }

          limits = {
            cpu    = var.cpu_limit
            memory = var.memory_limit
          }
        }

        nodeSelector = var.node_selector
        tolerations  = var.tolerations

        affinity = var.affinity

        podLabels = {
          "app.kubernetes.io/part-of" = var.project_name
          environment                 = var.environment
        }
      }

      # -----------------------------------------------------------------------
      # Disable Simple Scalable Deployment Components
      # -----------------------------------------------------------------------

      read = {
        replicas = 0
      }

      write = {
        replicas = 0
      }

      backend = {
        replicas = 0
      }

      # -----------------------------------------------------------------------
      # Loki Gateway
      # -----------------------------------------------------------------------

      gateway = {
        enabled  = true
        replicas = 1

        service = {
          type = "ClusterIP"
          port = 80
        }

        resources = {
          requests = {
            cpu    = var.gateway_cpu_request
            memory = var.gateway_memory_request
          }

          limits = {
            cpu    = var.gateway_cpu_limit
            memory = var.gateway_memory_limit
          }
        }
      }

      # -----------------------------------------------------------------------
      # Caching
      #
      # Disabled for the current development deployment to reduce pod count,
      # memory consumption, and operational complexity.
      # -----------------------------------------------------------------------

      chunksCache = {
        enabled = false
      }

      resultsCache = {
        enabled = false
      }

      # -----------------------------------------------------------------------
      # Embedded Object Storage
      #
      # MinIO is not required because this development deployment uses the
      # filesystem stored on an EBS-backed persistent volume.
      # -----------------------------------------------------------------------

      minio = {
        enabled = false
      }

      # -----------------------------------------------------------------------
      # Prometheus Monitoring
      # -----------------------------------------------------------------------

      monitoring = {
        serviceMonitor = {
          enabled = var.service_monitor_enabled

          labels = {
            release = var.prometheus_release_name
          }

          interval = var.service_monitor_interval
        }

        selfMonitoring = {
          enabled = false
        }
      }

      # -----------------------------------------------------------------------
      # Loki Canary
      #
      # The canary continuously writes and queries test log entries to confirm
      # the complete Loki ingestion and query path remains functional.
      # -----------------------------------------------------------------------

      lokiCanary = {
        enabled = var.loki_canary_enabled

        resources = {
          requests = {
            cpu    = var.canary_cpu_request
            memory = var.canary_memory_request
          }

          limits = {
            cpu    = var.canary_cpu_limit
            memory = var.canary_memory_limit
          }
        }
      }

      # -----------------------------------------------------------------------
      # Helm Test Pod
      # -----------------------------------------------------------------------

      test = {
        enabled = false
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.this
  ]
}