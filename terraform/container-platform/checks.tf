# =============================================================================
# AVOS Container Platform — Architectural Checks
#
# Validates relationships that span multiple input variables and networking
# outputs. Check failures appear during terraform plan.
# =============================================================================

check "system_node_scaling_relationship" {
  assert {
    condition = (
      var.system_node_min_size <= var.system_node_desired_size &&
      var.system_node_desired_size <= var.system_node_max_size
    )

    error_message = "System node-group capacity must satisfy minimum <= desired <= maximum."
  }
}

check "cluster_endpoint_access" {
  assert {
    condition = (
      var.cluster_endpoint_private_access ||
      var.cluster_endpoint_public_access
    )

    error_message = "At least one EKS Kubernetes API endpoint access method must be enabled."
  }
}

check "restricted_public_endpoint" {
  assert {
    condition = (
      !var.cluster_endpoint_public_access ||
      (
        length(var.cluster_public_access_cidrs) > 0 &&
        !contains(var.cluster_public_access_cidrs, "0.0.0.0/0")
      )
    )

    error_message = "Public EKS API access must be restricted to approved CIDR blocks."
  }
}

check "administrator_role_account" {
  assert {
    condition = startswith(
      var.administrator_role_arn,
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/"
    )

    error_message = "administrator_role_arn must belong to the active AWS account."
  }
}

check "network_vpc_available" {
  assert {
    condition = (
      try(
        data.terraform_remote_state.networking.outputs.vpc_id,
        ""
      ) != ""
    )

    error_message = "The Phase 4 networking state must publish a nonempty vpc_id."
  }
}

check "three_private_application_subnets" {
  assert {
    condition = (
      length(
        try(
          data.terraform_remote_state.networking.outputs.private_application_subnet_ids,
          []
        )
      ) == 3
    )

    error_message = "The EKS platform requires exactly three private application subnets."
  }
}

check "unique_private_application_subnets" {
  assert {
    condition = (
      length(
        distinct(
          try(
            data.terraform_remote_state.networking.outputs.private_application_subnet_ids,
            []
          )
        )
      ) == 3
    )

    error_message = "The private application subnet IDs must be unique."
  }
}

check "required_addon_versions" {
  assert {
    condition = alltrue([
      for addon_name, addon_version in var.addon_versions :
      addon_version != null &&
      addon_version != "" &&
      can(regex("^v[0-9]+\\.", addon_version))
    ])

    error_message = "Every EKS managed add-on must have an explicit version beginning with v."
  }
}