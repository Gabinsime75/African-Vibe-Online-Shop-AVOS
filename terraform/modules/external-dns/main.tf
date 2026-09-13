####   Locals   ############################################################################
# ExternalDNS Module Local Configuration: This file defines shared local values used throughout the ExternalDNS module.
# It centralizes:
# 1. Resource naming.
# 2. Standard resource tags.
# 3. Kubernetes labels.
# 4. Helm values shared across the deployment.
# 5. Optional ServiceMonitor namespace selection.
# Centralizing these values keeps the IAM, Kubernetes, and Helm configuration
# consistent and prevents repeated naming and tagging logic across module files.
################################################################################


################################################################################
# Shared Resource Names: Generates consistent names for the IAM role, IAM policy, Kubernetes resources, and EKS Pod Identity association created by this module.
################################################################################
locals {
  iam_role_name = "${var.name}-pod-role"

  iam_policy_name = "${var.name}-r53-policy"

  pod_identity_association_name = "${var.name}-pod-id"
}


################################################################################
# Standard AWS Resource Tags: Merges caller-provided tags with module-specific metadata.
# Caller-provided tags may include:
# - Project
# - Environment
# - Owner
# - CostCenter
# - Repository
# Module tags identify the workload and the provisioning mechanism.
################################################################################

locals {
  common_tags = merge(
    var.tags,
    {
      Component = "external-dns"
      ManagedBy = "Terraform"
    }
  )
}


################################################################################
# Standard Kubernetes Labels: Defines a consistent set of Kubernetes recommended labels for resources managed by the ExternalDNS module.
################################################################################
locals {
  kubernetes_labels = {
    "app.kubernetes.io/name"       = "external-dns"
    "app.kubernetes.io/instance"   = var.name
    "app.kubernetes.io/component"  = "dns-controller"
    "app.kubernetes.io/part-of"    = var.platform_name
    "app.kubernetes.io/managed-by" = "Terraform"
  }
}


################################################################################
# ServiceMonitor Namespace Selection: Uses the explicitly configured ServiceMonitor namespace when provided. Otherwise, the ServiceMonitor is created in the ExternalDNS namespace.
################################################################################
locals {
  service_monitor_namespace = (
    var.service_monitor_namespace != ""
    ? var.service_monitor_namespace
    : var.namespace
  )
}


################################################################################
# ExternalDNS Provider Configuration: Defines the AWS provider configuration passed to the ExternalDNS Helm chart.
################################################################################
locals {
  provider_configuration = {
    name = "aws"
  }
}


################################################################################
# ExternalDNS AWS Arguments: Builds AWS-specific command-line arguments used by ExternalDNS.
# These arguments control:
# - Whether public or private Route 53 hosted zones are managed.
# - The maximum number of DNS changes submitted in each Route 53 batch.
################################################################################
locals {
  aws_extra_args = [
    "--aws-zone-type=${var.aws_zone_type}",
    "--aws-batch-change-size=${var.aws_batch_change_size}"
  ]
}


################################################################################
# ExternalDNS Base Helm Values: Builds the primary configuration passed to the ExternalDNS Helm chart.
# Additional caller-provided Helm values are merged in helm.tf so environments can extend the deployment without modifying this reusable module.
################################################################################
locals {
  helm_values = {
    provider = local.provider_configuration

    serviceAccount = {
      create = true
      name   = var.service_account_name

      labels = local.kubernetes_labels
    }

    sources = var.sources

    policy = var.policy

    registry = var.registry

    txtOwnerId = var.txt_owner_id

    txtPrefix = var.txt_prefix

    domainFilters = var.domain_filters

    triggerLoopOnEvent = var.trigger_loop_on_event

    interval = var.interval

    logLevel = var.log_level

    logFormat = var.log_format

    extraArgs = local.aws_extra_args

    replicaCount = var.replica_count

    resources = var.resources

    podLabels = merge(
      local.kubernetes_labels,
      var.pod_labels
    )

    podAnnotations = var.pod_annotations

    nodeSelector = var.node_selector

    tolerations = var.tolerations

    affinity = var.affinity

    priorityClassName = var.priority_class_name

    serviceMonitor = {
      enabled   = var.enable_service_monitor
      namespace = local.service_monitor_namespace
    }
  }
}