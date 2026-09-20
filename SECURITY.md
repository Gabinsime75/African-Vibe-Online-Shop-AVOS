# AVOS Security Policy

## Supported state

AVOS is being implemented through controlled roadmap phases. Security support applies to the latest commit on `main`; historical tags exist for recovery and evidence but do not receive fixes.

## Reporting a vulnerability

Do not disclose suspected vulnerabilities in a public issue, discussion, commit, or pull request.

Use GitHub's private vulnerability reporting or private security-advisory capability for this repository. Include:

- A concise description of the issue
- Affected files, services, or environments
- Reproduction steps or proof of concept
- Expected and observed behavior
- Potential impact
- Suggested mitigation, if known

Do not include real credentials, customer information, or unnecessary sensitive data in the report.

## Response approach

The project owner will validate the report, determine severity and affected scope, prepare a fix, test the remediation, and publish appropriate disclosure information after the risk is controlled.

## Security boundaries

- No source-controlled file is evidence that an AWS resource is currently deployed.
- Example values must not contain working credentials or secret material.
- AI-generated operational recommendations remain advisory unless an allow-listed, human-approved remediation workflow explicitly authorizes execution.
