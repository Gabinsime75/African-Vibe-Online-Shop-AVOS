# ADR-001: AVOS Environment, Account, and Terraform State Model

- Status: Accepted
- Date: 2026-09-20
- Decision owners: AVOS Platform Engineering

## Context

AVOS requires an affordable development environment now while preserving a
production-grade path toward isolated development, staging, and production
accounts.

Terraform state contains infrastructure metadata and must be encrypted,
versioned, protected from public access, isolated by environment, and protected
against concurrent writers.

The Terraform backend cannot be used until its supporting S3 bucket and KMS key
exist. Therefore, the bootstrap root must initially use local state and migrate
that state only after the remote-state foundation has been created.

## Decision

AVOS will initially deploy the development environment into the existing AWS
sandbox account in `us-east-2`.

The target enterprise model will use separate AWS accounts for:

- shared platform and security services;
- development;
- staging;
- production.

The initial implementation will preserve those future boundaries through
environment-specific names, state keys, variables, and deployment roles.

Terraform state will use:

- an S3 bucket with a globally unique name;
- S3 versioning;
- customer-managed KMS encryption;
- all S3 public-access controls enabled;
- a policy denying insecure transport;
- native S3 lockfiles;
- one state key per environment and Terraform root;
- short-lived AWS credentials.

No AWS credentials, Terraform state, plan files, or environment-specific backend
configuration may be committed to Git.

## Naming convention

Resources will use lowercase AVOS identifiers:

```text
avos-<environment>-<resource>-<account-id>-<region>