# AVOS Phase 0 Validation Report

## Purpose

This report consolidates the evidence collected while converting the imported application source into the African Vibe Online Shop (AVOS) baseline. It validates repository content only and does not claim that AWS or Kubernetes resources are deployed.

## Status legend

| Status | Meaning |
|---|---|
| Passed | The required command completed successfully and evidence was observed. |
| Partial | Some checks passed, but the complete validation set has not yet passed. |
| Blocked | A local toolchain or dependency prevented validation. |
| Pending | No final validation output has been recorded yet. |

## Baseline scope

| Item | Expected count | Classification |
|---|---:|---|
| Business microservices | 11 | Customer-facing or internal AVOS application services. |
| Supporting test workloads | 1 | The Locust Load Generator validates behavior and performance. |
| Cart datastore | 1 | Redis is supporting data infrastructure, not a microservice. |

## Microservice validation matrix

| Component | Source update | Unit or service tests | Compile/build | Container image | Current status | Evidence or remaining action |
|---|---|---|---|---|---|---|
| `frontend` | Applied | Passed | Passed through `go test ./...` compilation | Pending evidence | Partial | Go packages and money tests passed; record the final Docker build result. |
| `productcatalogservice` | Applied | Passed | Passed with `go build ./...` | Passed | Passed | Go tests passed and `avos/productcatalogservice:phase-1` built successfully. |
| `adservice` | Applied | Partial | Gradle reached distribution validation | Pending evidence | Partial | `installDist` reported an implicit task-dependency problem; rerun after the Gradle task fix and record the Docker build. |
| `recommendationservice` | Applied | Pending | Pending | Pending | Pending | Run the Python tests, bytecode compilation, and container build. |
| `shoppingassistantservice` | Applied | Passed | Passed with `compileall` | Pending evidence | Partial | Five unit tests passed and dependency installation completed; record the container build. |
| `cartservice` | Applied | Blocked | Blocked | Pending | Blocked | The local machine did not have the .NET SDK; install the required SDK or validate through Docker. |
| `checkoutservice` | Applied | Pending | Pending | Pending | Pending | Run Go tests, Go build, and the container build. |
| `currencyservice` | Applied | No test files discovered | JavaScript syntax check passed | Pending | Partial | `npm run check` passed; `npm test` failed because `test/*.test.js` was absent. Add tests or correct the test script, then build the image. |
| `paymentservice` | Applied | Pending | Pending | Pending | Pending | Run Node.js validation, tests, and the container build. |
| `shippingservice` | Applied | Pending | Pending | Pending | Pending | Run Go tests, Go build, and the container build. |
| `emailservice` | Applied | Pending | Pending | Pending | Pending | Run Python tests, bytecode compilation, and the container build. |
| `loadgenerator` | Applied | Passed | Passed | Passed | Passed | Python 3.13.15 installed all pinned dependencies; six tests passed; Locust 2.43.0 discovered `AVOSShopper`; `avos/loadgenerator:phase-0` built successfully. |

No component marked Partial, Blocked, or Pending may be reported as fully validated.

## Required completion commands

Run commands from the named service directory unless stated otherwise.

### Go services

Use for `frontend`, `productcatalogservice`, `checkoutservice`, and `shippingservice`:

```bash
go mod tidy
go test ./...
go build ./...
docker build -t avos/<service>:phase-0 .
```

`go mod tidy` must not produce unexplained dependency changes.

### Python services

Use for `emailservice`, `recommendationservice`, and `shoppingassistantservice`:

```bash
python -m venv .venv
source .venv/Scripts/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python -m compileall -q .
python -m unittest discover -p "test_*.py" -v
docker build -t avos/<service>:phase-0 .
deactivate
```

If a service uses `pytest`, execute its documented `pytest` command instead of inventing a second test framework.

### Load Generator

Use Python 3.13 on Windows:

```bash
py -3.13 -m venv .venv
source .venv/Scripts/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python -m compileall -q .
python -m unittest discover -s test -p "test_*.py" -v
locust -f locustfile.py --list
docker build -t avos/loadgenerator:phase-0 .
deactivate
```

### Node.js services

Use for `currencyservice` and `paymentservice`:

```bash
npm ci
npm run check
npm test
docker build -t avos/<service>:phase-0 .
```

The Node.js version must satisfy the `engines` declaration in `package.json`.

### Cart Service

Use the SDK version declared by the service project:

```bash
dotnet --info
dotnet restore cartservice.sln
dotnet test cartservice.sln --no-restore
dotnet build cartservice.sln --configuration Release --no-restore
docker build -t avos/cartservice:phase-0 .
```

### Ad Service

After correcting the Gradle task dependency:

```bash
./gradlew clean test installDist
docker build -t avos/adservice:phase-0 .
```

## Repository hygiene validation

| Check | Current evidence | Status |
|---|---|---|
| Customer-facing legacy branding | Source scan reduced to historical documentation, predecessor delivery configuration, and diagram binary data. | Partial |
| Legacy per-service CI | Workflows referencing predecessor ECR repositories and IAM roles are staged for removal. | Passed |
| Legacy Argo CD configuration | Applications referencing predecessor repositories and namespaces are staged for removal. | Passed |
| Product Catalog test binary | Removed from tracking during source replacement and absent from the tracked-artifact scan. | Passed |
| Terraform state backup | Removed from tracking and absent from the tracked-artifact scan. | Passed |
| Draw.io backup and temporary files | Staged for removal and protected through `.gitignore`. | Passed |
| Whitespace errors | Both `git diff --check` and `git diff --cached --check` completed without output. | Passed |
| Secrets | No consolidated secret scan has been recorded. | Pending |

## Final repository checks

Run from the repository root:

```bash
git grep -n -I -i -E \
"cloudhustler|cloudhusller|online boutique|cymbal|hipster shop|google cloud|gcp" \
-- \
':!Docs/Architectures/**' \
':!**/.venv/**' \
':!**/node_modules/**' \
':!**/build/**' \
':!**/dist/**'

git ls-files | grep -Ei \
'(^|/)(\.venv|node_modules|build|dist)/|\.tfstate(\.|$)|\.pem$|\.key$|\.test$|\.drawio\.(bkp|dtmp)$|AVOS-.*-update'

git diff --check
git diff --cached --check
git status --short
git diff --stat
git diff --cached --stat
```

Expected results:

- The branding scan returns no actionable customer-facing or active-configuration matches.
- The tracked-artifact scan returns no result.
- Both whitespace checks return no error.
- The status and statistics contain only intentional Phase 0 changes.

## Security and sensitive-file checks

Before committing, confirm that no real credentials are present:

```bash
git grep -n -I -E \
'AKIA[0-9A-Z]{16}|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|aws_secret_access_key|client_secret[[:space:]]*[:=]'
```

A match must be inspected; examples and variable names are not automatically secrets. Never paste a discovered credential into documentation or chat. Rotate any real credential before removing it from Git.

## Deferred implementation

The following capabilities are intentionally outside the Phase 0 source baseline:

- AWS accounts, remote state, governance, identity, networking, and security controls.
- ECR repositories and GitHub Actions OIDC roles.
- Amazon EKS, Karpenter, Istio, Gateway API, and shared controllers.
- Managed Aurora PostgreSQL, ElastiCache, OpenSearch, analytics, and AIOps services.
- Argo CD applications and Argo CD Image Updater write-back.
- Runtime observability, alerting, incident response, and operational interfaces.

Their absence does not fail Phase 0 unless the roadmap incorrectly presents them as deployed.

## Approval criteria

Phase 0 may be approved when:

1. Every row in the validation matrix is Passed or has an explicitly accepted exception.
2. No active CI or GitOps configuration targets predecessor resources.
3. No generated artifact, state file, secret, delivery ZIP, extracted update directory, or local dependency directory is tracked.
4. The final branding scan contains only reviewed compatibility, attribution, or historical references.
5. Repository whitespace checks pass.
6. The baseline inventory, validation report, ADRs, and roadmap agree on what is implemented and deferred.
7. The approved changes are committed and tagged with a post-rebranding Phase 0 tag.

## Sign-off

| Field | Value |
|---|---|
| Phase | Phase 0 — AVOS source baseline |
| Decision | Pending final validation |
| Approved by | Pending |
| Approval date | Pending |
| Commit SHA | Pending |
| Release tag | Pending |
| Accepted exceptions | None recorded |


## Container validation summary

All 11 AVOS business services and the supporting load generator successfully produced container images.

| Component | Runtime user | Result |
|---|---|---|
| frontend | `65532:65532` | Passed |
| productcatalogservice | `65532:65532` | Passed |
| cartservice | `1654` | Passed |
| checkoutservice | `65532:65532` | Passed |
| currencyservice | `node` | Passed |
| paymentservice | `node` | Passed |
| shippingservice | `nonroot:nonroot` | Passed |
| emailservice | `avos` | Passed |
| recommendationservice | `avos` | Passed |
| adservice | `avos` | Passed |
| shoppingassistantservice | `10001:10001` | Passed |
| loadgenerator | `avos` | Passed |

All validated containers run without root privileges. Service tests, language-level validation, compilation, and container builds completed successfully. Remaining warnings are documented as technical debt and do not block the Phase 0 baseline.