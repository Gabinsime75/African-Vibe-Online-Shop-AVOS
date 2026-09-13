################################################################################
# External Secrets Operator Module - Shared Configuration
#
# This file centralizes the common configuration shared across the External
# Secrets Operator module.
#
# Responsibilities
#
# • Common resource naming
# • Standard AWS tags
# • Kubernetes recommended labels
# • Provider configuration
# • Helm values shared across the deployment
# • SecretStore configuration
#
# Architecture
#
# AWS Secrets Manager / Parameter Store
#                 │
#                 ▼
#             IAM Policy
#                 │
#                 ▼
#              IAM Role
#                 │
#                 ▼
#         EKS Pod Identity
#                 │
#                 ▼
#    External Secrets Operator
#                 │
#                 ▼
#        ClusterSecretStore
#                 │
#                 ▼
#          ExternalSecret
#                 │
#                 ▼
#        Kubernetes Secret
################################################################################

################################################################################
# AWS Information
################################################################################

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

################################################################################
# Local Values
################################################################################

locals {

  ##############################################################################
  # Resource Names
  ##############################################################################

  iam_role_name     = "${var.name}-role"
  iam_policy_name   = "${var.name}-policy"
  pod_identity_name = "${var.name}-podid"

  cluster_secret_store_name = var.cluster_secret_store_name

  ##############################################################################
  # Common Tags
  ##############################################################################

  common_tags = merge(

    var.tags,

    {
      Name      = var.name
      Component = "external-secrets"
      Project   = var.platform_name
      ManagedBy = "Terraform"
    }
  )

  ##############################################################################
  # Standard Kubernetes Labels
  #
  # Kubernetes Recommended Labels
  #
  # https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/
  ##############################################################################

  kubernetes_labels = {

    "app.kubernetes.io/name" = "external-secrets"

    "app.kubernetes.io/instance" = var.name

    "app.kubernetes.io/component" = "secrets-controller"

    "app.kubernetes.io/part-of" = var.platform_name

    "app.kubernetes.io/managed-by" = "Terraform"
  }

  ##############################################################################
  # AWS Provider Configuration
  ##############################################################################

  aws_provider = {

    region = var.aws_region
  }

  ##############################################################################
  # Default Cluster Secret Store
  ##############################################################################

  secret_store = {

    name = var.cluster_secret_store_name

    service = var.secret_store_service

    region = var.aws_region
  }

  ##############################################################################
  # Shared Helm Values
  #
  # These values are reused by helm.tf to keep the Helm release clean.
  ##############################################################################

  helm_values = {

    installCRDs = var.install_crds

    replicaCount = var.replica_count

    log = {

      level = var.log_level

      timeEncoding = var.log_time_encoding
    }

    serviceMonitor = {

      enabled = var.enable_service_monitor

      namespace = (
        var.service_monitor_namespace != ""
        ? var.service_monitor_namespace
        : var.namespace
      )

      interval = var.service_monitor_interval

      scrapeTimeout = var.service_monitor_scrape_timeout

      additionalLabels = var.service_monitor_labels
    }

    metrics = {

      service = {

        enabled = var.metrics_service_enabled

        annotations = var.metrics_service_annotations
      }
    }

    resources = var.resources

    nodeSelector = var.node_selector

    tolerations = var.tolerations

    affinity = var.affinity

    topologySpreadConstraints = var.topology_spread_constraints

    priorityClassName = var.priority_class_name

    podLabels = merge(

      local.kubernetes_labels,

      var.pod_labels
    )

    podAnnotations = var.pod_annotations

    securityContext = var.security_context

    podSecurityContext = var.pod_security_context
  }

}