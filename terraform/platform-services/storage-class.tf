# =============================================================================
# CloudHustler Commerce Platform - EBS gp3 StorageClass
# =============================================================================
# This file creates the Kubernetes gp3 StorageClass used by stateful platform
# workloads such as Prometheus, Alertmanager, Grafana, Loki, and application
# databases.
#
# Dynamic volume provisioning is performed by the Amazon EBS CSI Driver.
# =============================================================================

# -----------------------------------------------------------------------------
# EBS gp3 StorageClass
# -----------------------------------------------------------------------------

resource "kubernetes_storage_class_v1" "gp3" {
  metadata {
    name = "gp3"

    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false"
    }

    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
      "app.kubernetes.io/part-of"    = var.project_name
      "cloudhusller.com/environment" = var.environment
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type      = "gp3"
    encrypted = "true"
    fsType    = "ext4"
  }
}