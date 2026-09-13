###############################################################################
# Let's Encrypt Staging ClusterIssuer
###############################################################################

resource "kubernetes_manifest" "letsencrypt_staging" {
  count = (
    var.create_cluster_issuers &&
    var.create_staging_cluster_issuer
  ) ? 1 : 0

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name   = var.staging_cluster_issuer_name
      labels = local.common_labels
    }

    spec = {
      acme = {
        email  = var.letsencrypt_email
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"

        privateKeySecretRef = {
          name = "${var.staging_cluster_issuer_name}-account-key"
        }

        solvers = [
          {
            selector = {
              dnsZones = [
                var.domain_name
              ]
            }

            dns01 = {
              route53 = {}
            }
          }
        ]
      }
    }
  }

  depends_on = [
    helm_release.cert_manager,
    aws_eks_pod_identity_association.cert_manager
  ]
}

###############################################################################
# Let's Encrypt Production ClusterIssuer
###############################################################################

resource "kubernetes_manifest" "letsencrypt_production" {
  count = var.create_cluster_issuers ? 1 : 0

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name   = var.production_cluster_issuer_name
      labels = local.common_labels
    }

    spec = {
      acme = {
        email  = var.letsencrypt_email
        server = "https://acme-v02.api.letsencrypt.org/directory"

        privateKeySecretRef = {
          name = "${var.production_cluster_issuer_name}-account-key"
        }

        solvers = [
          {
            selector = {
              dnsZones = [
                var.domain_name
              ]
            }

            dns01 = {
              route53 = {}
            }
          }
        ]
      }
    }
  }

  depends_on = [
    helm_release.cert_manager,
    aws_eks_pod_identity_association.cert_manager
  ]
}