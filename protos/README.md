# AVOS Protobuf Contracts

## Ownership

The protos directory owns application contracts.
CODEOWNERS assigns ownership to @Gabinsime75.
Reviewer approval is not currently mandatory.

- demo.proto: shared business-service API.
- shoppingassistant.proto: versioned assistant API.
- cartservice/Cart.proto: existing C# cart projection.

Edit central sources first and update affected service-local build copies.
Standard gRPC health schemas are upstream dependencies.

## Generation

Go and Python clients are committed and checked by
.github/scripts/protobuf/check-generated.py.
Run the script from the repository root in Linux or WSL.
Pass --output with an empty directory outside the repository.
Review generated-files.txt and drift.diff before copying outputs back.

Java generates clients through Gradle; C# uses Grpc.Tools.
Node.js loads schemas at runtime.
Pinned versions live in the workflow, generation script,
service project files, and dependency lockfiles.
Do not hand-edit generated client bodies.

## Compatibility and changes

Preserve existing hipstershop RPC paths and field numbers.
Reserve removed field numbers and names.
Breaking changes require an explicit versioned migration.

The cart projection retains its C# namespace and google.protobuf.Empty
responses. It repeats shared definitions and is excluded from the shared
Buf module. CI verifies its build copy and retains separate cart
compilation and FILE compatibility checks.

Update authoritative contracts and affected build copies together.
Regenerate clients, build consumers, and pass compilation,
FILE compatibility, copy-consistency, and generated-client checks.
