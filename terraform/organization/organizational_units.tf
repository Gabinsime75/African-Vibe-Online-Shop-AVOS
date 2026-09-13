
# Security Organizational Unit
resource "aws_organizations_organizational_unit" "security" {

  count = var.create_security_ou ? 1 : 0

  name      = local.organizational_units.security
  parent_id = data.aws_organizations_organization.this.roots[0].id

}

# Infrastructure Organizational Unit
resource "aws_organizations_organizational_unit" "infrastructure" {

  count = var.create_infrastructure_ou ? 1 : 0

  name      = local.organizational_units.infrastructure
  parent_id = data.aws_organizations_organization.this.roots[0].id

}

# Shared Services Organizational Unit
resource "aws_organizations_organizational_unit" "shared_services" {

  count = var.create_shared_services_ou ? 1 : 0

  name = local.organizational_units.shared_services

  parent_id = aws_organizations_organizational_unit.infrastructure[0].id

}

# Logging Organizational Unit
resource "aws_organizations_organizational_unit" "logging" {

  count = var.create_logging_ou ? 1 : 0

  name = local.organizational_units.logging

  parent_id = aws_organizations_organizational_unit.infrastructure[0].id

}

# NonProduction Organizational Unit
resource "aws_organizations_organizational_unit" "nonproduction" {

  count = var.create_nonproduction_ou ? 1 : 0

  name      = local.organizational_units.nonproduction
  parent_id = data.aws_organizations_organization.this.roots[0].id

}

# Development Organizational Unit
resource "aws_organizations_organizational_unit" "development" {

  count = var.create_development_ou ? 1 : 0

  name = local.organizational_units.development

  parent_id = aws_organizations_organizational_unit.nonproduction[0].id

}

# Testing Organizational Unit
resource "aws_organizations_organizational_unit" "testing" {

  count = var.create_testing_ou ? 1 : 0

  name = local.organizational_units.testing

  parent_id = aws_organizations_organizational_unit.nonproduction[0].id

}

# Staging Organizational Unit
resource "aws_organizations_organizational_unit" "staging" {

  count = var.create_staging_ou ? 1 : 0

  name = local.organizational_units.staging

  parent_id = aws_organizations_organizational_unit.nonproduction[0].id

}

# Production Organizational Unit
resource "aws_organizations_organizational_unit" "production" {

  count = var.create_production_ou ? 1 : 0

  name      = local.organizational_units.production
  parent_id = data.aws_organizations_organization.this.roots[0].id

}

# Suspended Organizational Unit
resource "aws_organizations_organizational_unit" "suspended" {

  count = var.create_suspended_ou ? 1 : 0

  name      = local.organizational_units.suspended
  parent_id = data.aws_organizations_organization.this.roots[0].id

}