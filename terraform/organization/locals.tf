# =============================================================================
# AVOS AWS Organizations — Local Values
#
# Defines mandatory tags and the approved, frozen organizational-unit model.
# These values are intentionally not exposed as runtime variables.
# =============================================================================

locals {
  common_tags = merge(
    var.additional_tags,
    {
      Project       = "AVOS"
      ManagedBy     = "Terraform"
      TerraformRoot = "organization"
      Owner         = var.owner
      Scope         = "Organization"
    }
  )

  top_level_ous = {
    security = {
      name    = "Security"
      purpose = "Centralized security audit and log archive accounts"
    }

    infrastructure = {
      name    = "Infrastructure"
      purpose = "Shared networking platform DNS and CI/CD accounts"
    }

    workloads = {
      name    = "Workloads"
      purpose = "Parent boundary for AVOS workload environments"
    }

    sandbox = {
      name    = "Sandbox"
      purpose = "Controlled experimentation and learning accounts"
    }

    policy_staging = {
      name    = "Policy-Staging"
      purpose = "Safe validation of service control policies"
    }

    suspended = {
      name    = "Suspended"
      purpose = "Quarantined retired or decommissioning accounts"
    }
  }

  workload_ous = {
    development = {
      name    = "Development"
      purpose = "AVOS development workload accounts"
    }

    staging = {
      name    = "Staging"
      purpose = "AVOS preproduction workload accounts"
    }

    production = {
      name    = "Production"
      purpose = "AVOS production workload accounts"
    }
  }
}