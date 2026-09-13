# =============================================================================
# CloudHustler Commerce Platform - Karpenter NodePool
# =============================================================================
# This file creates the default Karpenter NodePool used to dynamically
# provision general-purpose EKS worker nodes.
#
# The NodePool configures:
# - Linux AMD64 worker nodes
# - General-purpose, compute-optimized, and memory-optimized instance families
# - Spot and On-Demand capacity
# - Modern EC2 instance generations
# - Cluster-wide CPU and memory provisioning limits
# - Node expiration
# - Empty and underutilized node consolidation
#
# The existing EKS managed node group continues to host critical system
# workloads, including the Karpenter controller.
# =============================================================================

# -----------------------------------------------------------------------------
# Karpenter Default NodePool
# -----------------------------------------------------------------------------

resource "kubernetes_manifest" "karpenter_node_pool" {
  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"

    metadata = {
      name = var.karpenter_node_pool_name

      labels = {
        "app.kubernetes.io/name"       = "karpenter"
        "app.kubernetes.io/component"  = "node-pool"
        "app.kubernetes.io/managed-by" = "terraform"
        "environment"                  = var.environment
      }
    }

    spec = {
      # -----------------------------------------------------------------------
      # Node Template
      # -----------------------------------------------------------------------

      template = {
        metadata = {
          labels = {
            "node.cloudhusller.com/node-pool"  = var.karpenter_node_pool_name
            "node.cloudhusller.com/managed-by" = "karpenter"
            "environment"                      = var.environment
          }
        }

        spec = {
          # -------------------------------------------------------------------
          # EC2NodeClass Reference
          # -------------------------------------------------------------------

          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = var.karpenter_ec2_node_class_name
          }

          # -------------------------------------------------------------------
          # Node Requirements
          # -------------------------------------------------------------------

          requirements = [
            {
              key      = "kubernetes.io/os"
              operator = "In"
              values   = var.karpenter_operating_systems
            },
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = var.karpenter_architectures
            },
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = var.karpenter_capacity_types
            },
            {
              key      = "karpenter.k8s.aws/instance-category"
              operator = "In"
              values   = var.karpenter_instance_categories
            },
            {
              key      = "karpenter.k8s.aws/instance-generation"
              operator = "Gt"
              values   = [tostring(var.karpenter_minimum_instance_generation)]
            },
            {
              key      = "karpenter.k8s.aws/instance-cpu"
              operator = "In"
              values = [
                for cpu in var.karpenter_instance_cpu_options :
                tostring(cpu)
              ]
            }
          ]

          # -------------------------------------------------------------------
          # Node Lifetime
          # -------------------------------------------------------------------

          expireAfter = var.karpenter_node_expire_after
        }
      }

      # -----------------------------------------------------------------------
      # NodePool Resource Limits
      # -----------------------------------------------------------------------

      limits = {
        cpu    = tostring(var.karpenter_node_pool_cpu_limit)
        memory = var.karpenter_node_pool_memory_limit
      }

      # -----------------------------------------------------------------------
      # Disruption and Consolidation
      # -----------------------------------------------------------------------

      disruption = {
        consolidationPolicy = var.karpenter_consolidation_policy
        consolidateAfter    = var.karpenter_consolidate_after

        budgets = [
          {
            nodes = var.karpenter_disruption_budget
          }
        ]
      }

      # -----------------------------------------------------------------------
      # NodePool Scheduling Weight
      # -----------------------------------------------------------------------

      weight = var.karpenter_node_pool_weight
    }
  }

  depends_on = [
    kubernetes_manifest.karpenter_ec2_node_class
  ]
}