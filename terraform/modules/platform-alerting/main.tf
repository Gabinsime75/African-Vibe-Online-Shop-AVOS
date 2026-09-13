# =============================================================================
# CloudHustler Commerce Platform
# Platform Alerting Module
#
# This file deploys custom PrometheusRule resources for Kubernetes,
# Prometheus, Loki, OpenTelemetry, Istio, and application workloads.
#
# Alert definitions are maintained as standard YAML files under rules/.
# Terraform controls whether each rule group is deployed, while the alert
# expressions, thresholds, durations, severities, and annotations remain
# directly readable and version-controlled in YAML.
#
# This keeps the alerting implementation simple:
#
# Terraform -> deployment lifecycle
# YAML      -> alerting policy
# =============================================================================

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.30"
    }
  }
}

# -----------------------------------------------------------------------------
# Enabled Alert Rule Groups
# -----------------------------------------------------------------------------

locals {
  alert_rule_files = {
    kubernetes = {
      enabled = var.kubernetes_alerts_enabled
      file    = "kubernetes-alerts.yaml"
    }

    prometheus = {
      enabled = var.prometheus_alerts_enabled
      file    = "prometheus-alerts.yaml"
    }

    loki = {
      enabled = var.loki_alerts_enabled
      file    = "loki-alerts.yaml"
    }

    opentelemetry = {
      enabled = var.opentelemetry_alerts_enabled
      file    = "opentelemetry-alerts.yaml"
    }

    istio = {
      enabled = var.istio_alerts_enabled
      file    = "istio-alerts.yaml"
    }

    application = {
      enabled = var.application_alerts_enabled
      file    = "application-alerts.yaml"
    }
  }

  enabled_alert_rule_files = {
    for name, config in local.alert_rule_files :
    name => config
    if config.enabled
  }
}

# -----------------------------------------------------------------------------
# PrometheusRule Resources
#
# Terraform reads each enabled YAML document and submits it directly to
# Kubernetes through kubernetes_manifest.
# -----------------------------------------------------------------------------

resource "kubernetes_manifest" "alert_rule" {
  for_each = local.enabled_alert_rule_files

  manifest = yamldecode(
    file("${path.module}/rules/${each.value.file}")
  )
}