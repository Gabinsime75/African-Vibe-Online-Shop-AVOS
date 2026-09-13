###############################################################################
# Cert-Manager Helm Release
###############################################################################

resource "helm_release" "cert_manager" {
  name = var.helm_release_name

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.chart_version

  namespace        = var.namespace
  create_namespace = true

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 900

  values = [
    yamlencode({
      crds = {
        enabled = true
      }

      replicaCount = var.replica_count

      serviceAccount = {
        create = true
        name   = local.service_account_name

        labels = local.common_labels
      }

      webhook = {
        replicaCount = var.webhook_replica_count
      }

      cainjector = {
        replicaCount = var.cainjector_replica_count
      }

      prometheus = {
        enabled = true

        servicemonitor = {
          enabled = false
        }
      }

      global = {
        leaderElection = {
          namespace = var.namespace
        }
      }
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.cert_manager,
    # aws_eks_pod_identity_association.cert_manager
  ]
}