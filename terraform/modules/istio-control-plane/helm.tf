###############################################################
# Istio Control Plane Helm Values
###############################################################

locals {
  istiod_default_values = merge(
    {
      global = merge(
        {
          proxy = {
            autoInject = var.enable_sidecar_injection ? "enabled" : "disabled"

            resources = {
              requests = {
                cpu    = var.proxy_cpu_request
                memory = var.proxy_memory_request
              }

              limits = {
                cpu    = var.proxy_cpu_limit
                memory = var.proxy_memory_limit
              }
            }
          }
        },
        var.image_hub != null && trimspace(var.image_hub) != "" ? {
          hub = var.image_hub
        } : {},
        var.image_tag != null && trimspace(var.image_tag) != "" ? {
          tag = var.image_tag
        } : {}
      )

      pilot = {
        autoscaleEnabled      = var.enable_autoscaling
        autoscaleMin          = var.autoscale_min_replicas
        autoscaleMax          = var.autoscale_max_replicas
        rollingMaxSurge       = 0
        rollingMaxUnavailable = 1

        replicaCount = var.enable_autoscaling ? null : var.replica_count

        cpu = {
          targetAverageUtilization = var.autoscaling_cpu_target_percentage
        }

        resources = {
          requests = {
            cpu    = var.istiod_cpu_request
            memory = var.istiod_memory_request
          }

          limits = {
            cpu    = var.istiod_cpu_limit
            memory = var.istiod_memory_limit
          }
        }

        env = merge(
          {
            PILOT_ENABLE_STATUS             = tostring(var.enable_status)
            PILOT_ENABLE_ANALYSIS           = tostring(var.enable_config_analysis)
            PILOT_ENABLE_GATEWAY_API        = tostring(var.enable_gateway_api)
            ENABLE_NATIVE_SIDECARS          = tostring(var.enable_native_sidecars)
            PILOT_ENABLE_IP_AUTOALLOCATE    = tostring(var.enable_ip_autoallocate)
            PILOT_ENABLE_GATEWAY_API_STATUS = tostring(var.enable_gateway_api_status)
          },
          var.additional_pilot_environment
        )
      }

      meshConfig = {
        enableTracing     = var.enable_tracing
        accessLogFile     = var.enable_access_logging ? "/dev/stdout" : ""
        accessLogEncoding = var.access_log_encoding

        defaultConfig = {
          holdApplicationUntilProxyStarts = var.hold_application_until_proxy_starts
          terminationDrainDuration        = var.termination_drain_duration

          tracing = {
            sampling = var.tracing_sampling_percentage
          }

          proxyMetadata = var.proxy_metadata
        }

        outboundTrafficPolicy = {
          mode = var.outbound_traffic_policy_mode
        }

        rootNamespace = var.root_namespace
        trustDomain   = var.trust_domain
      }

      telemetry = {
        enabled = var.enable_telemetry
      }
    },
    var.revision != null && trimspace(var.revision) != "" ? {
      revision = var.revision
    } : {}
  )

  istiod_values = concat(
    [
      yamlencode(local.istiod_default_values)
    ],
    var.additional_istiod_values
  )
}

###############################################################
# Istio Base
#
# Installs Istio CRDs and cluster-scoped foundation resources.
###############################################################

resource "helm_release" "base" {
  name       = var.base_release_name
  namespace  = var.namespace
  repository = var.chart_repository
  chart      = var.base_chart_name
  version    = var.chart_version

  create_namespace = var.create_namespace

  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.helm_timeout
  wait            = var.wait

  values = var.additional_base_values

  lifecycle {
    prevent_destroy = false
  }
}

###############################################################
# Istiod Control Plane
###############################################################

resource "helm_release" "istiod" {
  name       = var.istiod_release_name
  namespace  = var.namespace
  repository = var.chart_repository
  chart      = var.istiod_chart_name
  version    = var.chart_version

  create_namespace = false

  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.helm_timeout
  wait            = var.wait

  max_history = var.max_history

  values = local.istiod_values

  depends_on = [
    helm_release.base
  ]
}