# =============================================================================
# AVOS IAM Identity Center — Local Values and Access Model
#
# Defines standard tags, workforce groups, permission sets, and the initial
# account-assignment model used by the Identity Center resources.
# =============================================================================

locals {
  identity_center_instance_arn = one(data.aws_ssoadmin_instances.current.arns)
  identity_store_id            = one(data.aws_ssoadmin_instances.current.identity_store_ids)

  common_tags = merge(
    {
      ManagedBy     = "Terraform"
      Owner         = var.owner
      Phase         = "3"
      Project       = "AVOS"
      Repository    = var.repository_name
      Scope         = "Identity"
      TerraformRoot = "identity"
    },
    var.additional_tags
  )

  identity_groups = {
    platform_admins = {
      display_name = "AVOS-Platform-Admins"
      description  = "Privileged administrators responsible for the AVOS AWS platform."
    }

    security_auditors = {
      display_name = "AVOS-Security-Auditors"
      description  = "Security personnel who review AVOS configurations findings and evidence."
    }

    developers = {
      display_name = "AVOS-Developers"
      description  = "Engineers who build and operate AVOS development workloads."
    }

    read_only = {
      display_name = "AVOS-ReadOnly"
      description  = "Personnel requiring non-mutating visibility into approved AVOS accounts."
    }
  }

  permission_sets = {
    administrator = {
      name             = "AVOS-AdministratorAccess"
      description      = "Privileged AVOS platform administration access."
      session_duration = "PT1H"
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
      ]
    }

    security_audit = {
      name             = "AVOS-SecurityAudit"
      description      = "Read-oriented access for AVOS security review and investigation."
      session_duration = "PT1H"
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/SecurityAudit"
      ]
    }

    developer = {
      name             = "AVOS-DeveloperAccess"
      description      = "Development access without unrestricted IAM administration."
      session_duration = "PT4H"
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/PowerUserAccess"
      ]
    }

    read_only = {
      name             = "AVOS-ReadOnlyAccess"
      description      = "Non-mutating visibility into AVOS AWS resources."
      session_duration = "PT4H"
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
    }
  }

  initial_account_assignments = {
    platform_admins_management = {
      group_key          = "platform_admins"
      permission_set_key = "administrator"
      account_id         = var.management_account_id
    }

    security_auditors_management = {
      group_key          = "security_auditors"
      permission_set_key = "security_audit"
      account_id         = var.management_account_id
    }
  }
}