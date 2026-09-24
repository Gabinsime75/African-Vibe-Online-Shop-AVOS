# AVOS Phase 3 Baseline Inventory

## Purpose

This document records the AWS identity, organization, governance, and security
state discovered before the AVOS Phase 3 implementation.

Discovery was read-only. Existing AWS resources were not modified.

## AWS account

| Item | Verified value |
|---|---|
| AWS account | `396913735153` |
| Account name | `AWS_Savant` |
| Organization role | Management account |
| Primary AVOS Region | `us-east-2` |
| Current CLI identity | IAM user |
| Root MFA | Enabled |
| IAM users | One |
| IAM-user access keys | One active key |
| IAM Identity Center | Not enabled in checked Regions |
| Custom password policy | Not configured |

Access-key identifiers and account email addresses are intentionally excluded.

## AWS Organizations

| Item | Verified value |
|---|---|
| Organization ID | `o-oz0x97sv9g` |
| Organization feature set | All features |
| Root ID | `r-2tht` |
| SCP policy type | Enabled |
| Custom organizational units | None |
| Custom SCPs | None |
| Root-attached SCP | AWS-managed `FullAWSAccess` |
| Delegated administrators | None |

## Organization accounts

| Account | Placement | AVOS classification |
|---|---|---|
| `AWS_Savant` | Organization root | Management account and temporary AVOS development account |
| `DCT-PRODUCTION` | Organization root | Existing account; not classified as an AVOS account |

The existing `DCT-PRODUCTION` account must not be moved or receive AVOS policies
without separate approval.

## Governance and detection services

| Service | Baseline state |
|---|---|
| CloudTrail | No customer-created trail |
| AWS Config | Trusted service integration exists, but no recorder or delivery channel |
| GuardDuty | Disabled in `us-east-2` |
| Security Hub | Disabled in `us-east-2` |
| Detective | No behavior graph |
| IAM Access Analyzer | No analyzer |
| Secrets Manager | No secrets |
| Customer-managed KMS | Phase 2 Terraform-state key only |

## Source-code baseline

Inherited Terraform roots exist for:

- `terraform/organization`
- `terraform/identity`
- `terraform/governance`
- `terraform/security`

These roots will not be updated in place. Each capability will be removed and
rebuilt as a fresh AVOS implementation when its Phase 3 step begins.

## Baseline risks

| Finding | Risk | Planned treatment |
|---|---|---|
| Human access uses a long-lived IAM-user key | Credential exposure and weak session governance | Establish IAM Identity Center and temporary role sessions before retiring the key |
| IAM user has no MFA device | Compromise could permit administrative access | Configure temporary MFA protection, then migrate routine access to Identity Center |
| Management account hosts development resources | Expands management-account blast radius | Preserve temporarily and design migration to a development member account |
| Existing accounts are directly under root | Policies cannot be applied by workload classification | Introduce AVOS OUs without moving unrelated accounts |
| No preventive AVOS SCPs | No organization-wide permission guardrails | Test SCPs in `Policy-Staging` before workload attachment |
| Governance and detection services are disabled | Limited audit, drift, and threat visibility | Implement them in controlled Phase 3 steps |

## Baseline conclusion

The organization is suitable for a fresh AVOS governance implementation.
Organization-wide changes must be introduced carefully because this account is
the management account and an existing non-AVOS account is present.