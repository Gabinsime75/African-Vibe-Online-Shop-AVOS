# =============================================================================
# CloudHustler Commerce Platform
# OpenTelemetry Collector Terraform Module
#
# This file deploys the OpenTelemetry Collector using the official Helm chart.
#
# The Collector provides a vendor-neutral telemetry pipeline for application
# metrics and distributed traces. Applications send OTLP telemetry to the
# Collector, which enriches, batches, and exports the data to platform
# observability backends.
#
# Current responsibilities:
# - Receive OTLP over gRPC and HTTP
# - Enrich telemetry with Kubernetes metadata
# - Protect the Collector with memory limiting and batching
# - Expose application metrics for Prometheus scraping
# - Export traces to AWS X-Ray when enabled
# - Expose Collector health and internal metrics
# - Expose Collector internal telemetry on port 8888
# - Expose OTLP pipeline metrics through Prometheus exporter on port 8889
#
# Fluent Bit remains responsible for Kubernetes container log collection.
# =============================================================================

# -----------------------------------------------------------------------------
# Collector Configuration
# -----------------------------------------------------------------------------

locals {

  # ---------------------------------------------------------------------------
  # OpenTelemetry Metrics Ports
  #
  # 8888:
  #   Collector internal operational telemetry such as:
  #   - otelcol_receiver_*
  #   - otelcol_processor_*
  #   - otelcol_exporter_*
  #   - otelcol_process_*
  #
  # 8889:
  #   Metrics received through the Collector metrics pipeline and exported
  #   using the Prometheus exporter.
  # ---------------------------------------------------------------------------

  collector_internal_metrics_port = 8888

  # ---------------------------------------------------------------------------
  # Trace Exporters
  #
  # AWS X-Ray is enabled when configured. The debug exporter remains available
  # for development validation when X-Ray export is disabled.
  # ---------------------------------------------------------------------------

  trace_exporters = merge(
    var.aws_xray_enabled ? {
      awsxray = {
        region             = var.aws_region
        indexed_attributes = var.aws_xray_indexed_attributes
      }
    } : {},
    var.aws_xray_enabled ? {} : {
      debug = {
        verbosity = var.debug_exporter_verbosity
      }
    }
  )

  trace_exporter_names = var.aws_xray_enabled ? ["awsxray"] : ["debug"]

  # ---------------------------------------------------------------------------
  # Collector Pipeline Configuration
  # ---------------------------------------------------------------------------

  collector_config = {

    # -------------------------------------------------------------------------
    # Extensions
    # -------------------------------------------------------------------------

    extensions = {
      health_check = {
        endpoint = "0.0.0.0:${var.health_check_port}"
      }

      zpages = {
        endpoint = "0.0.0.0:${var.zpages_port}"
      }
    }

    # -------------------------------------------------------------------------
    # Receivers
    # -------------------------------------------------------------------------

    receivers = {
      otlp = {
        protocols = {
          grpc = {
            endpoint = "0.0.0.0:${var.otlp_grpc_port}"
          }

          http = {
            endpoint = "0.0.0.0:${var.otlp_http_port}"
          }
        }
      }
    }

    # -------------------------------------------------------------------------
    # Processors
    # -------------------------------------------------------------------------

    processors = {
      memory_limiter = {
        check_interval         = var.memory_limiter_check_interval
        limit_percentage       = var.memory_limiter_limit_percentage
        spike_limit_percentage = var.memory_limiter_spike_limit_percentage
      }

      k8s_attributes = {
        auth_type   = "serviceAccount"
        passthrough = false

        extract = {
          metadata = [
            "k8s.namespace.name",
            "k8s.pod.name",
            "k8s.pod.uid",
            "k8s.deployment.name",
            "k8s.statefulset.name",
            "k8s.daemonset.name",
            "k8s.node.name"
          ]

          labels = [
            {
              tag_name = "app.kubernetes.io/name"
              key      = "app.kubernetes.io/name"
              from     = "pod"
            },
            {
              tag_name = "app.kubernetes.io/instance"
              key      = "app.kubernetes.io/instance"
              from     = "pod"
            },
            {
              tag_name = "environment"
              key      = "environment"
              from     = "pod"
            }
          ]
        }

        pod_association = [
          {
            sources = [
              {
                from = "resource_attribute"
                name = "k8s.pod.ip"
              }
            ]
          },
          {
            sources = [
              {
                from = "resource_attribute"
                name = "k8s.pod.uid"
              }
            ]
          },
          {
            sources = [
              {
                from = "connection"
              }
            ]
          }
        ]
      }

      resource = {
        attributes = [
          {
            key            = "service.namespace"
            action         = "upsert"
            from_attribute = "k8s.namespace.name"
          },
          {
            key    = "deployment.environment.name"
            action = "upsert"
            value  = var.environment
          },
          {
            key    = "cloud.provider"
            action = "upsert"
            value  = "aws"
          },
          {
            key    = "cloud.platform"
            action = "upsert"
            value  = "aws_eks"
          },
          {
            key    = "cloud.region"
            action = "upsert"
            value  = var.aws_region
          },
          {
            key    = "k8s.cluster.name"
            action = "upsert"
            value  = var.cluster_name
          }
        ]
      }

      batch = {
        timeout             = var.batch_timeout
        send_batch_size     = var.batch_send_size
        send_batch_max_size = var.batch_max_size
      }
    }

    # -------------------------------------------------------------------------
    # Exporters
    # -------------------------------------------------------------------------

    exporters = merge(
      {
        prometheus = {
          endpoint = "0.0.0.0:${var.prometheus_exporter_port}"

          namespace = var.prometheus_namespace

          resource_to_telemetry_conversion = {
            enabled = true
          }

          enable_open_metrics = true
        }
      },
      local.trace_exporters
    )

    # -------------------------------------------------------------------------
    # Collector Service
    # -------------------------------------------------------------------------

    service = {
      extensions = [
        "health_check",
        "zpages"
      ]

      # -----------------------------------------------------------------------
      # Collector Internal Telemetry
      #
      # This endpoint exposes the Collector's own operational metrics on 8888.
      # Prometheus uses these metrics to monitor receiver, processor, exporter,
      # memory, runtime, and pipeline health.
      # -----------------------------------------------------------------------

      telemetry = {
        logs = {
          level = var.collector_log_level
        }

        metrics = {
          readers = [
            {
              pull = {
                exporter = {
                  prometheus = {
                    host = "0.0.0.0"
                    port = local.collector_internal_metrics_port
                  }
                }
              }
            }
          ]
        }
      }

      # -----------------------------------------------------------------------
      # Telemetry Pipelines
      # -----------------------------------------------------------------------

      pipelines = {
        metrics = {
          receivers = ["otlp"]

          processors = [
            "memory_limiter",
            "k8s_attributes",
            "resource",
            "batch"
          ]

          exporters = [
            "prometheus"
          ]
        }

        traces = {
          receivers = ["otlp"]

          processors = [
            "memory_limiter",
            "resource",
            "batch"
          ]

          exporters = local.trace_exporter_names
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# OpenTelemetry Namespace
# -----------------------------------------------------------------------------

resource "kubernetes_namespace_v1" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace

    labels = merge(
      {
        "app.kubernetes.io/name"       = "opentelemetry-collector"
        "app.kubernetes.io/component"  = "observability"
        "app.kubernetes.io/part-of"    = var.project_name
        "app.kubernetes.io/managed-by" = "terraform"
        "environment"                  = var.environment
      },
      var.namespace_labels
    )
  }
}

# -----------------------------------------------------------------------------
# OpenTelemetry Collector Helm Release
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
      #
      # A Deployment provides a stable, horizontally scalable OTLP gateway for
      # application telemetry. It avoids adding one Collector pod per node.
      # -----------------------------------------------------------------------

      mode = "deployment"

      replicaCount = var.replica_count

      # -----------------------------------------------------------------------
      # Collector Image
      #
      # The contrib distribution includes the AWS X-Ray exporter and the
      # Kubernetes processors used by this module.
      # -----------------------------------------------------------------------

      image = {
        repository = var.image_repository
        tag        = var.image_tag
        pullPolicy = var.image_pull_policy
      }

      # -----------------------------------------------------------------------
      # Collector Configuration
      # -----------------------------------------------------------------------

      config = local.collector_config

      # -----------------------------------------------------------------------
      # Service Account
      #
      # The service account is also used by EKS Pod Identity when AWS X-Ray
      # export is enabled.
      # -----------------------------------------------------------------------

      serviceAccount = {
        create = true
        name   = var.service_account_name

        annotations = var.service_account_annotations
      }

      # -----------------------------------------------------------------------
      # Kubernetes Permissions
      #
      # The k8s_attributes processor requires permission to read pod,
      # namespace, node, ReplicaSet, Deployment, StatefulSet, DaemonSet,
      # and Job metadata.
      # -----------------------------------------------------------------------

      clusterRole = {
        create = true

        rules = [
          {
            apiGroups = [""]

            resources = [
              "pods",
              "namespaces",
              "nodes"
            ]

            verbs = [
              "get",
              "list",
              "watch"
            ]
          },
          {
            apiGroups = ["apps"]

            resources = [
              "replicasets",
              "deployments",
              "statefulsets",
              "daemonsets"
            ]

            verbs = [
              "get",
              "list",
              "watch"
            ]
          },
          {
            apiGroups = ["batch"]

            resources = [
              "jobs",
              "cronjobs"
            ]

            verbs = [
              "get",
              "list",
              "watch"
            ]
          }
        ]
      }

      # -----------------------------------------------------------------------
      # Network Ports
      #
      # 4317  - OTLP gRPC receiver
      # 4318  - OTLP HTTP receiver
      # 8888  - Collector internal operational metrics
      # 8889  - Prometheus exporter for OTLP metrics
      # 13133 - Collector health endpoint
      # 55679 - zPages diagnostics
      # -----------------------------------------------------------------------

      ports = {

        # OTLP gRPC
        otlp = {
          enabled       = true
          containerPort = var.otlp_grpc_port
          servicePort   = var.otlp_grpc_port
          protocol      = "TCP"
          appProtocol   = "grpc"
        }

        # OTLP HTTP
        "otlp-http" = {
          enabled       = true
          containerPort = var.otlp_http_port
          servicePort   = var.otlp_http_port
          protocol      = "TCP"
        }

        # Collector internal telemetry
        metrics = {
          enabled       = true
          containerPort = local.collector_internal_metrics_port
          servicePort   = local.collector_internal_metrics_port
          protocol      = "TCP"
        }

        # Prometheus exporter
        prometheus = {
          enabled       = true
          containerPort = var.prometheus_exporter_port
          servicePort   = var.prometheus_exporter_port
          protocol      = "TCP"
        }

        # Health endpoint
        health = {
          enabled       = true
          containerPort = var.health_check_port
          servicePort   = var.health_check_port
          protocol      = "TCP"
        }

        # zPages diagnostics
        zpages = {
          enabled       = var.zpages_enabled
          containerPort = var.zpages_port
          servicePort   = var.zpages_port
          protocol      = "TCP"
        }
      }

      # -----------------------------------------------------------------------
      # Kubernetes Service
      # -----------------------------------------------------------------------

      service = {
        enabled = true
        type    = var.service_type
      }

      # -----------------------------------------------------------------------
      # Prometheus ServiceMonitor
      #
      # Port "metrics" (8888):
      #   Scrapes Collector internal operational telemetry.
      #
      # Port "prometheus" (8889):
      #   Scrapes metrics received through the OTLP metrics pipeline and
      #   exported through the Collector's Prometheus exporter.
      # -----------------------------------------------------------------------

      serviceMonitor = {
        enabled = var.service_monitor_enabled

        extraLabels = {
          release = var.prometheus_release_name
        }

        metricsEndpoints = [
          {
            port     = "metrics"
            path     = "/metrics"
            interval = var.service_monitor_interval
          },
          {
            port     = "prometheus"
            path     = "/metrics"
            interval = var.service_monitor_interval
          }
        ]
      }

      # -----------------------------------------------------------------------
      # Prometheus Pod Annotations
      #
      # Retained for compatibility with environments that use annotation-based
      # Prometheus discovery. The primary integration for this platform is the
      # ServiceMonitor above.
      # -----------------------------------------------------------------------

      podAnnotations = {
        "prometheus.io/scrape" = tostring(var.prometheus_scrape_enabled)
        "prometheus.io/port"   = tostring(var.prometheus_exporter_port)
        "prometheus.io/path"   = "/metrics"
      }

      # -----------------------------------------------------------------------
      # Resources and Scaling
      # -----------------------------------------------------------------------

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

      autoscaling = {
        enabled     = var.autoscaling_enabled
        minReplicas = var.autoscaling_min_replicas
        maxReplicas = var.autoscaling_max_replicas

        targetCPUUtilizationPercentage = var.autoscaling_cpu_target
      }

      # -----------------------------------------------------------------------
      # Pod Scheduling
      # -----------------------------------------------------------------------

      nodeSelector = var.node_selector
      tolerations  = var.tolerations
      affinity     = var.affinity

      podLabels = {
        "app.kubernetes.io/part-of" = var.project_name
        "environment"               = var.environment
      }

      # -----------------------------------------------------------------------
      # Pod Health Checks
      # -----------------------------------------------------------------------

      livenessProbe = {
        httpGet = {
          path = "/"
          port = var.health_check_port
        }

        initialDelaySeconds = 10
        periodSeconds       = 10
        timeoutSeconds      = 3
        failureThreshold    = 3
      }

      readinessProbe = {
        httpGet = {
          path = "/"
          port = var.health_check_port
        }

        initialDelaySeconds = 5
        periodSeconds       = 10
        timeoutSeconds      = 3
        failureThreshold    = 3
      }

      # -----------------------------------------------------------------------
      # Security Context
      # -----------------------------------------------------------------------

      podSecurityContext = {
        runAsNonRoot = true
        runAsUser    = 10001
        runAsGroup   = 10001
        fsGroup      = 10001
      }

      securityContext = {
        allowPrivilegeEscalation = false
        readOnlyRootFilesystem   = true

        capabilities = {
          drop = ["ALL"]
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.this,
    aws_eks_pod_identity_association.this
  ]
}