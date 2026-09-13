################################################################################
# ExternalDNS IAM and EKS Pod Identity
# This file creates and configures:
# 1. AWS partition data used to build portable IAM ARNs.
# 2. An EKS Pod Identity trust policy for ExternalDNS.
# 3. A least-privilege IAM policy for Route 53 access.
# 4. An IAM role assumed by the ExternalDNS Kubernetes workload.
# 5. An IAM policy attachment connecting the role to Route 53 permissions.
# 6. An EKS Pod Identity association linking:
#      - the EKS cluster
#      - the ExternalDNS namespace
#      - the ExternalDNS service account
#      - the IAM role
#
# Authentication flow:
#
# ExternalDNS Pod
#      ↓
# Kubernetes ServiceAccount
#      ↓
# EKS Pod Identity Association
#      ↓
# IAM Role
#      ↓
# Route 53 IAM Policy
#      ↓
# Authorized Route 53 Hosted Zone
################################################################################


################################################################################
# AWS Partition: Detects the current AWS partition so IAM ARNs remain portable across standard AWS, AWS GovCloud, and AWS China partitions.
################################################################################

data "aws_partition" "current" {}

################################################################################
# EKS Pod Identity Trust Policy: Allows the EKS Pod Identity service to assume the ExternalDNS IAM role.
# The request-tag conditions restrict role usage to the configured:
#
# - Kubernetes namespace
# - Kubernetes service account
################################################################################

data "aws_iam_policy_document" "pod_identity_assume_role" {
  statement {
    sid    = "AllowEksAuthToAssumeRoleForPodIdentity"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-namespace"

      values = [
        var.namespace
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-service-account"

      values = [
        var.service_account_name
      ]
    }
  }
}


################################################################################
# ExternalDNS Route 53 IAM Policy: Grants ExternalDNS permission to:
# - Create, update, and delete DNS records in the authorized hosted zone.
# - Read existing resource record sets.
# - read Route 53 resource tags.
# - Discover hosted zones by ID or name.
#
# Record-management permissions are restricted to the configured hosted zone.
# Route 53 list operations require wildcard resource access.
################################################################################

data "aws_iam_policy_document" "external_dns" {
  statement {
    sid    = "ManageRoute53Records"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResources"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:route53:::hostedzone/${var.hosted_zone_id}"
    ]
  }

  statement {
    sid    = "DiscoverRoute53HostedZones"
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName"
    ]

    resources = [
      "*"
    ]
  }
}


################################################################################
# ExternalDNS IAM Role: Creates the IAM role that ExternalDNS assumes through EKS Pod Identity.
################################################################################

resource "aws_iam_role" "this" {
  name        = local.iam_role_name
  description = "IAM role used by ExternalDNS through EKS Pod Identity."

  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume_role.json

  tags = merge(
    var.tags,
    {
      Name      = local.iam_role_name
      Component = "external-dns"
      ManagedBy = "Terraform"
    }
  )
}


################################################################################
# ExternalDNS Route 53 IAM Policy Resource: Creates the customer-managed IAM policy containing the Route 53 permissions defined above.
################################################################################

resource "aws_iam_policy" "this" {
  name        = local.iam_policy_name
  description = "Allows ExternalDNS to manage records in the authorized Route 53 hosted zone."

  policy = data.aws_iam_policy_document.external_dns.json

  tags = merge(
    var.tags,
    {
      Name      = local.iam_policy_name
      Component = "external-dns"
      ManagedBy = "Terraform"
    }
  )
}


################################################################################
# IAM Role Policy Attachment: Attaches the ExternalDNS Route 53 policy to the ExternalDNS Pod Identity role.
################################################################################

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}


################################################################################
# EKS Pod Identity Association: Connects the ExternalDNS Kubernetes service account to the AWS IAM role.
# ExternalDNS Pods using this service account receive temporary AWS credentials without storing static access keys in Kubernetes.
################################################################################

resource "aws_eks_pod_identity_association" "this" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account_name
  role_arn        = aws_iam_role.this.arn

  tags = merge(
    var.tags,
    {
      Name      = local.pod_identity_association_name
      Component = "external-dns"
      ManagedBy = "Terraform"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.this
  ]
}