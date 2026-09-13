# =============================================================================
# CloudHustler Commerce Platform - Karpenter EC2NodeClass
# =============================================================================
# This file creates the AWS-specific EC2NodeClass used by Karpenter to launch
# dynamically provisioned EKS worker nodes.
#
# The EC2NodeClass configures:
# - Amazon Linux 2023 EKS-optimized AMI selection
# - Karpenter node IAM role
# - Private subnet discovery
# - EKS cluster security group discovery
# - Encrypted GP3 root volumes
# - IMDSv2 enforcement
# - EC2 resource tags
#
# The Karpenter NodePool will reference this EC2NodeClass when provisioning
# new worker nodes for unschedulable Kubernetes workloads.
# =============================================================================

# -----------------------------------------------------------------------------
# Karpenter EC2NodeClass
# -----------------------------------------------------------------------------

resource "kubernetes_manifest" "karpenter_ec2_node_class" {
  manifest = {
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"

    metadata = {
      name = var.karpenter_ec2_node_class_name

      labels = {
        "app.kubernetes.io/name"       = "karpenter"
        "app.kubernetes.io/component"  = "node-class"
        "app.kubernetes.io/managed-by" = "terraform"
        "environment"                  = var.environment
      }
    }

    spec = {
      # -----------------------------------------------------------------------
      # AMI Selection
      # -----------------------------------------------------------------------

      amiFamily = var.karpenter_ami_family

      amiSelectorTerms = [
        {
          alias = var.karpenter_ami_alias
        }
      ]

      # -----------------------------------------------------------------------
      # Node IAM Role
      # -----------------------------------------------------------------------

      role = module.karpenter.node_iam_role_name

      # -----------------------------------------------------------------------
      # Private Subnet Discovery
      # -----------------------------------------------------------------------

      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]

      # -----------------------------------------------------------------------
      # Security Group Discovery
      # -----------------------------------------------------------------------

      securityGroupSelectorTerms = [
        {
          id = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
        }
      ]

      # -----------------------------------------------------------------------
      # Root Volume Configuration
      # -----------------------------------------------------------------------

      blockDeviceMappings = [
        {
          deviceName = "/dev/xvda"

          ebs = {
            volumeType          = var.karpenter_root_volume_type
            volumeSize          = var.karpenter_root_volume_size
            iops                = var.karpenter_root_volume_iops
            throughput          = var.karpenter_root_volume_throughput
            encrypted           = true
            deleteOnTermination = true
          }
        }
      ]

      # -----------------------------------------------------------------------
      # EC2 Instance Metadata Service
      # -----------------------------------------------------------------------

      metadataOptions = {
        httpEndpoint            = "enabled"
        httpProtocolIPv6        = "disabled"
        httpPutResponseHopLimit = 1
        httpTokens              = "required"
      }

      # -----------------------------------------------------------------------
      # EC2 Resource Tags
      # -----------------------------------------------------------------------

      tags = merge(
        var.tags,
        {
          "Name"                    = "${var.project_name}-${var.environment}-karpenter-node"
          "karpenter.sh/discovery"  = var.cluster_name
          "karpenter.sh/node-class" = var.karpenter_ec2_node_class_name
        }
      )
    }
  }

  depends_on = [
    module.karpenter
  ]
}