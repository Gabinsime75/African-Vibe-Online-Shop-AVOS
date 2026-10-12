# =============================================================================
# AVOS External Secrets — Development Scope and EKS Pod Identity
# =============================================================================

locals {
  external_secrets_namespace          = "external-secrets"
  external_secrets_workload_namespace = "avos-dev"
  external_secrets_service_account    = "external-secrets"

  external_secrets_node_selector = {
    "eks.amazonaws.com/nodegroup" = "avos-dev-system"
  }
}

resource "kubernetes_namespace_v1" "external_secrets" {
  metadata {
    name = local.external_secrets_namespace
  }
}

resource "kubernetes_namespace_v1" "avos_dev" {
  metadata {
    name = local.external_secrets_workload_namespace
  }
}

data "aws_iam_policy_document" "external_secrets_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks-cluster-arn"
      values   = [data.aws_eks_cluster.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-namespace"
      values   = [local.external_secrets_namespace]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-service-account"
      values   = [local.external_secrets_service_account]
    }
  }
}

resource "aws_iam_role" "external_secrets" {
  name               = "avos-${var.environment}-external-secrets"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume_role.json
}

data "aws_iam_policy_document" "external_secrets" {
  statement {
    sid    = "ReadAvosDevelopmentSecrets"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:avos/dev/*"
    ]
  }
}

resource "aws_iam_policy" "external_secrets" {
  name   = "avos-${var.environment}-external-secrets"
  policy = data.aws_iam_policy_document.external_secrets.json
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}

resource "aws_eks_pod_identity_association" "external_secrets" {
  cluster_name    = data.aws_eks_cluster.this.name
  namespace       = local.external_secrets_namespace
  service_account = local.external_secrets_service_account
  role_arn        = aws_iam_role.external_secrets.arn

  depends_on = [
    aws_iam_role_policy_attachment.external_secrets
  ]
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  namespace  = kubernetes_namespace_v1.external_secrets.metadata[0].name
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "2.12.0"

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  values = [
    yamlencode({
      installCRDs = true

      replicaCount = 2
      leaderElect  = true

      livenessProbe = {
        enabled = true
      }

      readinessProbe = {
        enabled = true
      }

      serviceAccount = {
        create = true
        name   = local.external_secrets_service_account
      }

      scopedNamespace = local.external_secrets_workload_namespace
      scopedRBAC      = true

      processClusterStore          = false
      processClusterExternalSecret = false
      processClusterGenerator      = false
      processClusterPushSecret     = false
      processPushSecret            = false

      nodeSelector      = local.external_secrets_node_selector
      priorityClassName = "system-cluster-critical"

      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "256Mi"
        }
      }

      podDisruptionBudget = {
        enabled      = true
        minAvailable = 1
      }

      topologySpreadConstraints = local.controller_topology_spread.external_secrets_controller

      webhook = {
        replicaCount              = 2
        nodeSelector              = local.external_secrets_node_selector
        priorityClassName         = "system-cluster-critical"
        topologySpreadConstraints = local.controller_topology_spread.external_secrets_webhook
        livenessProbe = {
          enabled = true
        }

        resources = {
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
          limits = {
            cpu    = "250m"
            memory = "128Mi"
          }
        }
      }

      certController = {
        replicaCount      = 1
        nodeSelector      = local.external_secrets_node_selector
        priorityClassName = "system-cluster-critical"

        livenessProbe = {
          enabled = true
        }

        resources = {
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
          limits = {
            cpu    = "250m"
            memory = "128Mi"
          }
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.avos_dev,
    aws_iam_role_policy_attachment.external_secrets,
    aws_eks_pod_identity_association.external_secrets
  ]
}

output "external_secrets_role_arn" {
  description = "Pod Identity role for the AVOS development ESO controller."
  value       = aws_iam_role.external_secrets.arn
}

output "external_secrets_pod_identity_association_id" {
  value = aws_eks_pod_identity_association.external_secrets.association_id
}
