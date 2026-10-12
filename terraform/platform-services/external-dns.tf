# =============================================================================
# AVOS ExternalDNS — Scoped Route 53 Access through EKS Pod Identity
# =============================================================================

locals {
  external_dns_zone_id         = "Z08118211LIG93KC7E5CI"
  external_dns_zone_domain     = "cloudhusller.com"
  external_dns_domain_scope    = "avos-dev.cloudhusller.com"
  external_dns_namespace       = "kube-system"
  external_dns_service_account = "external-dns"
}

# Only the approved cluster, namespace, and service account may assume this role.
data "aws_iam_policy_document" "external_dns_assume_role" {
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
      values   = [local.external_dns_namespace]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-service-account"
      values   = [local.external_dns_service_account]
    }
  }
}

resource "aws_iam_role" "external_dns" {
  name               = "avos-${var.environment}-external-dns"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role.json
}

# Discovery is read-only. Record access and mutations are scoped separately.
data "aws_iam_policy_document" "external_dns" {
  statement {
    sid       = "DiscoverHostedZones"
    effect    = "Allow"
    actions   = ["route53:ListHostedZones"]
    resources = ["*"]
  }

  statement {
    sid    = "ReadApprovedHostedZone"
    effect = "Allow"

    actions = [
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResources"
    ]

    resources = [
      "arn:aws:route53:::hostedzone/${local.external_dns_zone_id}"
    ]
  }

  statement {
    sid     = "WriteApprovedDevelopmentRecords"
    effect  = "Allow"
    actions = ["route53:ChangeResourceRecordSets"]
    resources = [
      "arn:aws:route53:::hostedzone/${local.external_dns_zone_id}"
    ]

    condition {
      test     = "ForAllValues:StringLike"
      variable = "route53:ChangeResourceRecordSetsNormalizedRecordNames"
      values = [
        local.external_dns_domain_scope,
        "*.${local.external_dns_domain_scope}"
      ]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "route53:ChangeResourceRecordSetsRecordTypes"
      values   = ["A", "AAAA", "CNAME", "TXT"]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "route53:ChangeResourceRecordSetsActions"
      values   = ["CREATE", "UPSERT"]
    }
  }
}

resource "aws_iam_policy" "external_dns" {
  name   = "avos-${var.environment}-external-dns"
  policy = data.aws_iam_policy_document.external_dns.json
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

resource "aws_eks_pod_identity_association" "external_dns" {
  cluster_name    = data.aws_eks_cluster.this.name
  namespace       = local.external_dns_namespace
  service_account = local.external_dns_service_account
  role_arn        = aws_iam_role.external_dns.arn

  depends_on = [
    aws_iam_role_policy_attachment.external_dns
  ]
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = local.external_dns_namespace
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.22.0"

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  values = [
    yamlencode({
      provider = {
        name = "aws"
      }

      serviceAccount = {
        create = true
        name   = local.external_dns_service_account
      }

      sources          = ["service", "ingress"]
      domainFilters    = [local.external_dns_zone_domain]
      annotationFilter = "avos.io/external-dns=enabled"

      policy     = "upsert-only"
      registry   = "txt"
      txtOwnerId = "${var.cluster_name}-external-dns"
      txtPrefix  = "_externaldns."

      interval = "1m"

      extraArgs = [
        "--zone-id-filter=${local.external_dns_zone_id}",
        "--aws-zone-type=public",
      ]

      env = [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        }
      ]

      nodeSelector = {
        "eks.amazonaws.com/nodegroup" = "avos-dev-system"
      }

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
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.external_dns,
    aws_eks_pod_identity_association.external_dns
  ]
}

output "external_dns_role_arn" {
  description = "Dedicated ExternalDNS Pod Identity role."
  value       = aws_iam_role.external_dns.arn
}

output "external_dns_domain_scope" {
  description = "DNS names permitted by the ExternalDNS IAM policy."
  value       = local.external_dns_domain_scope
}

output "external_dns_pod_identity_association_id" {
  value = aws_eks_pod_identity_association.external_dns.association_id
}
