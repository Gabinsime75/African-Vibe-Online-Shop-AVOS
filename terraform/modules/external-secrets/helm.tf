################################################################################
# External Secrets Operator Helm Deployment: This file installs External Secrets Operator into the Amazon EKS cluster by
# using the official External Secrets Helm chart.
# Components Deployed
# • External Secrets core controller
# • Admission webhook
# • Certificate controller
# • Kubernetes ServiceAccount
# • External Secrets CRDs
# • Metrics service
# • Optional Prometheus ServiceMonitor
# Authentication Flow
# External Secrets Pod
#         │
#         ▼
# Kubernetes ServiceAccount
#         │
#         ▼
# EKS Pod Identity Association
#         │
#         ▼
# IAM Role
#         │
#         ▼
# AWS Secrets Manager / Parameter Store
# The ServiceAccount name configured here must match the service account used
# by the aws_eks_pod_identity_association resource in iam.tf.
################################################################################


################################################################################
# External Secrets Namespace: Terraform creates the namespace independently from Helm so that labels and
# lifecycle management remain controlled by Terraform.
################################################################################

resource "kubernetes_namespace" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace

    labels = local.kubernetes_labels
  }
}


################################################################################
# External Secrets Helm Release: Installs and configures all External Secrets Operator components.
################################################################################

resource "helm_release" "this" {
  name       = var.name
  repository = var.helm_repository
  chart      = var.chart_name
  version    = var.chart_version
  namespace  = var.namespace

  create_namespace = false

  atomic          = var.helm_atomic
  cleanup_on_fail = var.helm_cleanup_on_fail
  wait            = var.helm_wait
  timeout         = var.helm_timeout

  values = [
    yamlencode(
      merge(
        local.helm_values,

        {
          ######################################################################
          # External Secrets CRDs
          ######################################################################

          installCRDs = true

          ##############################################################################
          # Main Controller Configuration
          ##############################################################################

          controllerClass = var.controller_class

          processClusterExternalSecret = var.process_cluster_external_secret

          processClusterStore = var.process_cluster_store

          processPushSecret = var.process_push_secret

          processClusterPushSecret = var.process_cluster_push_secret

          concurrent = var.concurrent

          ######################################################################
          # Kubernetes ServiceAccount
          #
          # EKS Pod Identity does not require an IAM role annotation on the
          # ServiceAccount. AWS maps the ServiceAccount to the IAM role through
          # the Pod Identity association created in iam.tf.
          ######################################################################

          serviceAccount = {
            create = true
            name   = var.service_account_name

            labels = merge(
              local.kubernetes_labels,
              var.service_account_labels
            )

            annotations = var.service_account_annotations
          }


          ######################################################################
          # Admission Webhook
          ######################################################################

          webhook = {
            create       = var.enable_webhook
            replicaCount = var.webhook_replica_count

            resources = var.webhook_resources

            nodeSelector = var.webhook_node_selector
            tolerations  = var.webhook_tolerations
            affinity     = var.webhook_affinity

            priorityClassName = var.priority_class_name

            serviceMonitor = {
              enabled = var.enable_service_monitor

              namespace = (
                var.service_monitor_namespace != ""
                ? var.service_monitor_namespace
                : var.namespace
              )

              interval         = var.service_monitor_interval
              scrapeTimeout    = var.service_monitor_scrape_timeout
              additionalLabels = var.service_monitor_labels
            }

            metrics = {
              service = {
                enabled     = var.metrics_service_enabled
                annotations = var.metrics_service_annotations
              }
            }
          }

          ######################################################################
          # Certificate Controller
          #
          # The certificate controller manages certificates used by the
          # External Secrets admission webhook.
          ######################################################################

          certController = {
            create       = var.enable_cert_controller
            replicaCount = var.cert_controller_replica_count

            resources = var.cert_controller_resources

            nodeSelector = var.cert_controller_node_selector
            tolerations  = var.cert_controller_tolerations
            affinity     = var.cert_controller_affinity

            priorityClassName = var.priority_class_name

            serviceMonitor = {
              enabled = var.enable_service_monitor

              namespace = (
                var.service_monitor_namespace != ""
                ? var.service_monitor_namespace
                : var.namespace
              )

              interval         = var.service_monitor_interval
              scrapeTimeout    = var.service_monitor_scrape_timeout
              additionalLabels = var.service_monitor_labels
            }

            metrics = {
              service = {
                enabled     = var.metrics_service_enabled
                annotations = var.metrics_service_annotations
              }
            }
          }


          ######################################################################
          # Pod Disruption Budget
          ######################################################################

          podDisruptionBudget = {
            enabled      = var.pod_disruption_budget_enabled
            minAvailable = var.pod_disruption_budget_min_available
          }
        },

        var.additional_helm_values
      )
    )
  ]

  depends_on = [
    aws_iam_role_policy_attachment.this,
    aws_eks_pod_identity_association.this,
    kubernetes_namespace.this
  ]
}