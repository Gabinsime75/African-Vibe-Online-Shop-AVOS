# =============================================================================
# Fluent Bit Module
# =============================================================================
# Deploys Fluent Bit as a Kubernetes DaemonSet to collect and process
# container logs from every EKS worker node.
# =============================================================================

resource "kubernetes_namespace_v1" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/name"       = "fluent-bit"
      "app.kubernetes.io/component"  = "logging"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "this" {
  name       = var.release_name
  namespace  = var.namespace
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = var.chart_version

  create_namespace = false
  wait             = true
  timeout          = var.timeout
  atomic           = var.atomic

  values = [
    yamlencode({
      kind     = "DaemonSet"
      logLevel = var.log_level

      serviceMonitor = {
        enabled   = var.service_monitor_enabled
        namespace = var.monitoring_namespace
        interval  = var.scrape_interval
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

      tolerations = [
        {
          operator = "Exists"
        }
      ]

      config = {
        service = <<-EOT
          [SERVICE]
              Daemon        Off
              Flush         1
              Log_Level     ${var.log_level}
              Parsers_File  /fluent-bit/etc/parsers.conf
              HTTP_Server   On
              HTTP_Listen   0.0.0.0
              HTTP_Port     2020
              Health_Check  On
        EOT

        inputs = <<-EOT
          [INPUT]
              Name              tail
              Path              /var/log/containers/*.log
              multiline.parser  docker, cri
              Tag               kube.*
              Mem_Buf_Limit     5MB
              Skip_Long_Lines   On
              Refresh_Interval  10
        EOT

        filters = <<-EOT
          [FILTER]
              Name                kubernetes
              Match               kube.*
              Merge_Log           On
              Keep_Log            Off
              K8S-Logging.Parser  On
              K8S-Logging.Exclude On
        EOT

        outputs = <<-EOT
          [OUTPUT]
              Name        loki
              Match       kube.*
              Host        loki-gateway.logging.svc.cluster.local
              Port        80
              URI         /loki/api/v1/push
              Labels      job=fluent-bit,namespace=$kubernetes['namespace_name'],pod=$kubernetes['pod_name'],container=$kubernetes['container_name'],node=$kubernetes['host']
              Line_Format json
              Retry_Limit False
        EOT
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.this
  ]
}