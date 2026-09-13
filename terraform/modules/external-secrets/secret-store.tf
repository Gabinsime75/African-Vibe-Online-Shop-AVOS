################################################################################
# External Secrets ClusterSecretStore
#
# This file creates the AWS ClusterSecretStore used by External Secrets
# Operator to authenticate with AWS Secrets Manager or AWS Systems Manager
# Parameter Store through Amazon EKS Pod Identity.
#
# Architecture
#
# AWS Secrets Manager / Parameter Store
#                 │
#                 ▼
#         ClusterSecretStore
#                 │
#                 ▼
#         ExternalSecret
#                 │
#                 ▼
#        Kubernetes Secret
#
# The ClusterSecretStore is cluster-scoped and may be referenced by
# ExternalSecret resources in any namespace.
#
# Authentication is performed through EKS Pod Identity. No AWS credentials are
# stored inside Kubernetes.
################################################################################

################################################################################
# AWS ClusterSecretStore
################################################################################

resource "kubernetes_manifest" "cluster_secret_store" {
  count = var.create_cluster_secret_store ? 1 : 0

  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ClusterSecretStore"

    metadata = {
      name   = local.secret_store.name
      labels = local.kubernetes_labels
    }

    spec = {
      provider = {
        aws = {
          service = local.secret_store.service
          region  = local.secret_store.region
        }
      }
    }
  }

  depends_on = [
    helm_release.this
  ]
}