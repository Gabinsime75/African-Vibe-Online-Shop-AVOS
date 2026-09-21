# Contributing to AVOS

## Purpose

These standards keep AVOS changes reviewable, reproducible, secure, and aligned with the approved implementation roadmap.

## Branch workflow

1. Start from an updated `main` branch.
2. Create a focused branch named for the phase and change.
3. Make the smallest coherent change that satisfies the roadmap step.
4. Run relevant local validation.
5. Open a pull request and attach evidence.
6. Merge only after required reviews and checks pass.

Examples:

```text
phase-2-terraform-bootstrap
feat-shopping-assistant-retrieval
fix-checkout-timeout
docs-phase-1-validation
```

## Conventional commits

Use the following commit types:

| Type | Short role |
|---|---|
| `feat` | Adds user-facing or platform capability. |
| `fix` | Corrects defective behavior. |
| `docs` | Changes documentation only. |
| `test` | Adds or corrects tests. |
| `refactor` | Changes implementation without changing expected behavior. |
| `perf` | Improves performance or resource use. |
| `build` | Changes build tooling or dependencies. |
| `ci` | Changes continuous-integration automation. |
| `chore` | Performs maintenance that does not fit another type. |
| `revert` | Reverses a previous change. |

Example:

```text
feat(cartservice): add managed Redis configuration
```

## Required validation

Run the checks relevant to the changed component. At minimum:

```bash
git diff --check
git diff --cached --check
```

Application changes must include the service's language tests and container build. Terraform changes must pass formatting, initialization without backend access when appropriate, validation, linting, security scanning, and reviewed planning before apply. Kubernetes and GitOps changes must render successfully before reconciliation.

## Security requirements

- Never commit credentials, tokens, private keys, kubeconfigs, Terraform state, plans, or secret values.
- Use GitHub OIDC for AWS CI authentication.
- Use AWS Secrets Manager and External Secrets for runtime secrets.
- Preserve non-root container execution.
- Preserve inherited copyright and license notices.
- Report suspected vulnerabilities through the repository's private security-reporting process.

## Architecture and documentation

- Update the appropriate ADR when a decision changes architecture or ownership.
- Update phase-validation evidence when implementation claims change.
- Label capabilities accurately as planned, implemented, deployed, or validated.
- Give every phase, step, tool, and resource a short statement explaining its role.

## Pull-request expectations

Every pull request must explain scope, validation, risk, rollback, and evidence. Infrastructure changes must also identify expected cost impact and cleanup behavior.
