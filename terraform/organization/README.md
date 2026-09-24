# AVOS AWS Organizations

This Terraform root manages the AWS Organizations hierarchy and initial
service control policy guardrails for African Vibe Online Shop (AVOS).

## Managed hierarchy

- Security
- Infrastructure
- Workloads
  - Development
  - Staging
  - Production
- Sandbox
- Policy-Staging
- Suspended

The existing management account and unrelated accounts remain at the
organization root. This root does not create or move AWS accounts.

## Initial service control policy

`AVOS-Deny-Leave-Organization` denies:

```text
organizations:LeaveOrganization