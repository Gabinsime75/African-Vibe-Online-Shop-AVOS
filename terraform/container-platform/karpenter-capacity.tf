resource "kubernetes_manifest" "karpenter_ec2_node_class" {
  manifest = {
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"

    metadata = {
      name = "${local.name_prefix}-application"
    }

    spec = {
      instanceProfile = aws_iam_instance_profile.karpenter_node.name

      amiSelectorTerms = [
        {
          alias = "al2023@latest"
        }
      ]

      subnetSelectorTerms = [
        for subnet_id in data.terraform_remote_state.networking.outputs.private_application_subnet_ids :
        {
          id = subnet_id
        }
      ]

      securityGroupSelectorTerms = [
        {
          id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
        }
      ]

      blockDeviceMappings = [
        {
          deviceName = "/dev/xvda"

          ebs = {
            volumeSize          = "50Gi"
            volumeType          = "gp3"
            encrypted           = true
            deleteOnTermination = true
            iops                = 3000
            throughput          = 125
          }
        }
      ]

      metadataOptions = {
        httpEndpoint            = "enabled"
        httpProtocolIPv6        = "disabled"
        httpPutResponseHopLimit = 2
        httpTokens              = "required"
      }

      detailedMonitoring = true

      tags = merge(
        local.common_tags,
        {
          Name                     = "${local.name_prefix}-karpenter-node"
          "karpenter.sh/discovery" = aws_eks_cluster.this.name
          CapacityManager          = "Karpenter"
        }
      )
    }
  }

  depends_on = [
    helm_release.karpenter,
    aws_eks_access_entry.karpenter_node,
    aws_iam_instance_profile.karpenter_node
  ]
}

resource "kubernetes_manifest" "karpenter_node_pool" {
  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"

    metadata = {
      name = "application"
    }

    spec = {
      weight = 10

      template = {
        metadata = {
          labels = {
            "node-pool"     = "application"
            "workload-type" = "application"
          }
        }

        spec = {
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = kubernetes_manifest.karpenter_ec2_node_class.manifest.metadata.name
          }

          requirements = [
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64"]
            },
            {
              key      = "kubernetes.io/os"
              operator = "In"
              values   = ["linux"]
            },
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["spot", "on-demand"]
            },
            {
              key      = "karpenter.k8s.aws/instance-category"
              operator = "In"
              values   = ["c", "m", "r"]
            },
            {
              key      = "karpenter.k8s.aws/instance-generation"
              operator = "Gt"
              values   = ["5"]
            },
            {
              key      = "karpenter.k8s.aws/instance-size"
              operator = "NotIn"
              values = [
                "nano",
                "micro",
                "small",
                "metal"
              ]
            }
          ]

          expireAfter            = "720h"
          terminationGracePeriod = "1h"
        }
      }

      limits = {
        cpu    = "100"
        memory = "400Gi"
      }

      disruption = {
        consolidationPolicy = "WhenEmptyOrUnderutilized"
        consolidateAfter    = "5m"

        budgets = [
          {
            nodes = "10%"
          }
        ]
      }
    }
  }

  depends_on = [
    kubernetes_manifest.karpenter_ec2_node_class
  ]
}