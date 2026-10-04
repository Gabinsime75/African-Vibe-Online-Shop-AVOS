data "aws_iam_policy_document" "karpenter_controller_assume_role" {
  statement {
    sid    = "AllowEksPodIdentity"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "karpenter_controller" {
  statement {
    sid    = "AllowScopedEC2InstanceAccess"
    effect = "Allow"

    actions = [
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate",
      "ec2:RunInstances"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = [aws_eks_cluster.this.name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${aws_eks_cluster.this.name}"
      values   = ["owned"]
    }

    condition {
      test     = "Null"
      variable = "aws:RequestTag/karpenter.sh/nodepool"
      values   = ["false"]
    }
  }

  statement {
    sid    = "AllowScopedEC2InstanceAccessActions"
    effect = "Allow"

    actions = [
      "ec2:CreateFleet",
      "ec2:RunInstances"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}::image/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}::snapshot/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:capacity-reservation/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:placement-group/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:security-group/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:subnet/*"
    ]
  }

  statement {
    sid    = "AllowScopedEC2LaunchTemplateAccessActions"
    effect = "Allow"

    actions = [
      "ec2:CreateFleet",
      "ec2:RunInstances"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:launch-template/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.this.name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  statement {
    sid    = "AllowScopedResourceTagging"
    effect = "Allow"

    actions = [
      "ec2:CreateTags"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/eks:eks-cluster-name"
      values   = [aws_eks_cluster.this.name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.this.name}"
      values   = ["owned"]
    }
  }

  statement {
    sid    = "AllowScopedInstanceTermination"
    effect = "Allow"

    actions = [
      "ec2:TerminateInstances",
      "ec2:DeleteLaunchTemplate"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/eks:eks-cluster-name"
      values   = [aws_eks_cluster.this.name]
    }

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["false"]
    }
  }

  statement {
    sid    = "AllowRegionalReadOnlyEC2Access"
    effect = "Allow"

    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "AllowPricingReadAccess"
    effect = "Allow"

    actions   = ["pricing:GetProducts"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowSSMParameterReadAccess"
    effect = "Allow"

    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:ssm:${var.aws_region}::parameter/aws/service/*"
    ]
  }

  statement {
    sid    = "AllowInterruptionQueueAccess"
    effect = "Allow"

    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage"
    ]

    resources = [
      aws_sqs_queue.karpenter_interruption.arn
    ]
  }

  statement {
    sid    = "AllowPassingKarpenterNodeRole"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      aws_iam_role.karpenter_node.arn
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com"]
    }
  }

  statement {
    sid    = "AllowInstanceProfileReadAccess"
    effect = "Allow"

    actions = [
      "iam:GetInstanceProfile"
    ]

    resources = [
      aws_iam_instance_profile.karpenter_node.arn
    ]
  }

  statement {
    sid    = "AllowClusterDiscovery"
    effect = "Allow"

    actions = [
      "eks:DescribeCluster"
    ]

    resources = [
      aws_eks_cluster.this.arn
    ]
  }

  statement {
    sid    = "AllowScopedResourceCreationTagging"
    effect = "Allow"

    actions = [
      "ec2:CreateTags"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values = [
        "CreateFleet",
        "CreateLaunchTemplate",
        "RunInstances"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = [aws_eks_cluster.this.name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${aws_eks_cluster.this.name}"
      values   = ["owned"]
    }

    condition {
      test     = "Null"
      variable = "aws:RequestTag/karpenter.sh/nodepool"
      values   = ["false"]
    }
  }

  statement {
    sid    = "AllowInstanceProfileListing"
    effect = "Allow"

    actions = [
      "iam:ListInstanceProfiles"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "karpenter_controller" {
  name               = "${local.name_prefix}-karpenter-controller-role"
  assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume_role.json

  tags = {
    Name    = "${local.name_prefix}-karpenter-controller-role"
    Purpose = "KarpenterController"
  }
}

resource "aws_iam_policy" "karpenter_controller" {
  name        = "${local.name_prefix}-karpenter-controller"
  description = "Allows Karpenter to manage compute capacity for ${aws_eks_cluster.this.name}."
  policy      = data.aws_iam_policy_document.karpenter_controller.json

  tags = {
    Name    = "${local.name_prefix}-karpenter-controller"
    Purpose = "KarpenterController"
  }
}

resource "aws_iam_role_policy_attachment" "karpenter_controller" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
}

resource "aws_eks_pod_identity_association" "karpenter" {
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "karpenter"
  role_arn        = aws_iam_role.karpenter_controller.arn

  tags = {
    Name    = "${local.name_prefix}-karpenter"
    Purpose = "KarpenterController"
  }

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_iam_role_policy_attachment.karpenter_controller
  ]
}