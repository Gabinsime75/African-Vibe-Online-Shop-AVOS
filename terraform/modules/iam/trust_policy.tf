# Generic trust policy support
data "aws_iam_policy_document" "trust_policy" {


  # AWS Service Principals
  dynamic "statement" {

    for_each = length(var.trusted_services) > 0 ? [1] : []

    content {

      effect = "Allow"

      actions = [
        "sts:AssumeRole"
      ]

      principals {

        type        = "Service"
        identifiers = var.trusted_services
      }
    }
  }


  # AWS Account Principals
  dynamic "statement" {
    for_each = length(var.trusted_aws_principals) > 0 ? [1] : []

    content {
      effect = "Allow"
      actions = [
        "sts:AssumeRole"
      ]

      principals {

        type        = "AWS"
        identifiers = var.trusted_aws_principals

      }

    }

  }

  ###########################################
  # Federated Principals (OIDC / SAML)
  ###########################################

  dynamic "statement" {

    for_each = length(var.trusted_federated_principals) > 0 ? [1] : []

    content {

      effect = "Allow"

      actions = [
        "sts:AssumeRoleWithWebIdentity"
      ]

      principals {

        type        = "Federated"
        identifiers = var.trusted_federated_principals

      }

    }

  }

}