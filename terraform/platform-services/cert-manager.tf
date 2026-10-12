# =============================================================================
# AVOS Phase 6.4 — cert-manager and Route 53 DNS Validation Identity
# =============================================================================

locals {
  cert_manager_namespace       = "cert-manager"
  cert_manager_service_account = "cert-manager"

  cert_manager_node_selector = {
    "eks.amazonaws.com/nodegroup" = "avos-dev-system"
  }
}

resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = local.cert_manager_namespace

    labels = {
      "app.kubernetes.io/part-of" = "avos-platform"
    }
  }
}

data "aws_iam_policy_document" "cert_manager_assume_role" {
  statement {
    sid     = "AllowEKSPodIdentity"
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
      values   = [local.cert_manager_namespace]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-service-account"
      values   = [local.cert_manager_service_account]
    }
  }
}

resource "aws_iam_role" "cert_manager" {
  name               = "avos-${var.environment}-cert-manager"
  assume_role_policy = data.aws_iam_policy_document.cert_manager_assume_role.json
}

data "aws_iam_policy_document" "cert_manager" {
  statement {
    sid       = "ReadDNSChangeStatus"
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    sid       = "ReadDevelopmentHostedZoneRecords"
    effect    = "Allow"
    actions   = ["route53:ListResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/Z08118211LIG93KC7E5CI"]
  }

  statement {
    sid       = "ManageDevelopmentACMEChallenges"
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/Z08118211LIG93KC7E5CI"]

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "route53:ChangeResourceRecordSetsRecordTypes"
      values   = ["TXT"]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "route53:ChangeResourceRecordSetsActions"
      values   = ["CREATE", "UPSERT", "DELETE"]
    }

    condition {
      test     = "ForAllValues:StringLike"
      variable = "route53:ChangeResourceRecordSetsNormalizedRecordNames"
      values = [
        "_acme-challenge.avos-dev.cloudhusller.com",
        "_acme-challenge.*.avos-dev.cloudhusller.com"
      ]
    }
  }
}

resource "aws_iam_policy" "cert_manager" {
  name   = "avos-${var.environment}-cert-manager"
  policy = data.aws_iam_policy_document.cert_manager.json
}

resource "aws_iam_role_policy_attachment" "cert_manager" {
  role       = aws_iam_role.cert_manager.name
  policy_arn = aws_iam_policy.cert_manager.arn
}

resource "aws_eks_pod_identity_association" "cert_manager" {
  cluster_name    = data.aws_eks_cluster.this.name
  namespace       = local.cert_manager_namespace
  service_account = local.cert_manager_service_account
  role_arn        = aws_iam_role.cert_manager.arn

  depends_on = [
    aws_iam_role_policy_attachment.cert_manager
  ]
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name
  repository = "oci://quay.io/jetstack/charts"
  chart      = "cert-manager"
  version    = "v1.21.2"

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  values = [
    yamlencode({
      crds = {
        enabled = true
        keep    = true
      }

      global = {
        priorityClassName = "system-cluster-critical"
      }

      serviceAccount = {
        create = true
        name   = local.cert_manager_service_account
      }

      replicaCount              = 2
      nodeSelector              = local.cert_manager_node_selector
      topologySpreadConstraints = local.controller_topology_spread.cert_manager_controller

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

      webhook = {
        replicaCount              = 2
        nodeSelector              = local.cert_manager_node_selector
        topologySpreadConstraints = local.controller_topology_spread.cert_manager_webhook

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

      cainjector = {
        replicaCount              = 2
        nodeSelector              = local.cert_manager_node_selector
        topologySpreadConstraints = local.controller_topology_spread.cert_manager_cainjector

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

      startupapicheck = {
        nodeSelector = local.cert_manager_node_selector
      }
    })
  ]

  depends_on = [
    aws_eks_pod_identity_association.cert_manager
  ]
}
