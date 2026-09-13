# =============================================================================
# CloudHustler Commerce Platform
# Karpenter Interruption Handling Configuration
# =============================================================================
# Defines consistent naming and configuration for the SQS interruption queue
# used by Karpenter to process EC2 lifecycle and capacity events.
#
# The underlying queue, queue policy, EventBridge rules, and targets are created
# by the official terraform-aws-eks Karpenter submodule.
# =============================================================================

# -----------------------------------------------------------------------------
# Interruption Queue Naming
# -----------------------------------------------------------------------------

locals {
  karpenter_interruption_queue_name = coalesce(
    var.interruption_queue_name,
    "${var.name_prefix}-karpenter-interruption"
  )
}