# ADR-003: AVOS Network Foundation

## Status

Accepted

## Date

September 28, 2026

## Context

The African Vibe Online Shop (AVOS) requires an AWS network foundation that
supports public entry points, private application workloads, isolated data
services, centralized network logging, and a future Amazon EKS platform.

The initial development environment is deployed in AWS account
`396913735153` in `us-east-2`.

The design must:

- Support workloads across three Availability Zones.
- Keep application and data workloads off the public internet.
- Provide controlled outbound access for private application workloads.
- Prevent private data subnets from receiving default internet routes.
- Support future public and internal AWS load balancers.
- Provide private access to Amazon S3 and DynamoDB.
- Capture network-flow metadata for security and troubleshooting.
- Remain cost-aware for the development environment.
- Support higher-availability NAT designs in staging and production.
- Publish stable Terraform outputs for downstream infrastructure roots.

## Decision

AVOS will use a dedicated VPC with three subnet tiers distributed across three
Availability Zones.

### Region and Availability Zones

| Region | Availability Zone | Zone ID |
|---|---|---|
| `us-east-2` | `us-east-2a` | `use2-az1` |
| `us-east-2` | `us-east-2b` | `use2-az2` |
| `us-east-2` | `us-east-2c` | `use2-az3` |

Availability Zone names are account-relative. Zone IDs provide stable
physical-AZ identifiers when comparing architectures across AWS accounts.

### VPC address space

The AVOS development VPC uses:

```text
10.20.0.0/16
```

This provides 65,536 IPv4 addresses before AWS-reserved addresses are
considered. The address space is divided into `/20` subnets to provide clear
tier boundaries and sufficient capacity for EKS nodes, pods, load balancers,
endpoints, and platform services.

### Subnet allocation

| Tier | Availability Zone | CIDR |
|---|---|---|
| Public | `us-east-2a` | `10.20.0.0/20` |
| Public | `us-east-2b` | `10.20.16.0/20` |
| Public | `us-east-2c` | `10.20.32.0/20` |
| Private application | `us-east-2a` | `10.20.64.0/20` |
| Private application | `us-east-2b` | `10.20.80.0/20` |
| Private application | `us-east-2c` | `10.20.96.0/20` |
| Private data | `us-east-2a` | `10.20.128.0/20` |
| Private data | `us-east-2b` | `10.20.144.0/20` |
| Private data | `us-east-2c` | `10.20.160.0/20` |

Unused address ranges remain available for future tiers or expansion.

### Public IPv4 assignment

Automatic public IPv4 assignment is disabled on all subnets, including public
subnets.

A subnet is public because its route table contains a default route to an
Internet Gateway. A resource receives public connectivity only when it also
has a public IP address and its security controls permit the traffic.

Public-facing AWS load balancers can explicitly receive public addresses
without enabling automatic public addressing for every resource launched in
the subnet.

### Public routing

The three public subnets share one public route table with the following
route:

```text
0.0.0.0/0 -> Internet Gateway
```

Public subnets are reserved for internet-facing infrastructure such as the
future public Application Load Balancer and the public NAT Gateway.
Application pods and databases will not be deployed in these subnets.

### Private application routing

Each private application subnet has an Availability-Zone-specific route table.

In the development environment, all three private application route tables use
a single public NAT Gateway located in `us-east-2a`:

```text
0.0.0.0/0 -> NAT Gateway in us-east-2a
```

This permits private application workloads to initiate outbound connections
for operations such as package downloads and external API calls. It does not
permit unsolicited inbound internet connections.

A single NAT Gateway is a deliberate development cost optimization. It creates
a cross-AZ dependency and may create cross-AZ data-processing charges.

Staging and production should use one NAT Gateway per Availability Zone so
each private application subnet uses a NAT Gateway in its own AZ.

### Private data routing

Each private data subnet has an Availability-Zone-specific route table.

Private data route tables do not contain a default route to an Internet
Gateway or NAT Gateway. They contain only the VPC-local route and routes
installed by approved Gateway VPC endpoints.

This tier is reserved for private databases, caches, and other stateful
services that do not require general internet egress.

### Kubernetes subnet discovery

Public subnets use:

```text
kubernetes.io/role/elb = 1
```

Private application subnets use:

```text
kubernetes.io/role/internal-elb = 1
```

These tags allow Kubernetes-integrated AWS controllers to discover the correct
subnets for internet-facing and internal load balancers.

### Gateway VPC endpoints

Gateway VPC endpoints are enabled for:

- Amazon S3
- Amazon DynamoDB

Both endpoints are associated with the six private application and private
data route tables. They are not associated with the public route table.

These endpoints allow S3 and DynamoDB traffic to use AWS-managed prefix-list
routes over the AWS network instead of traversing the NAT Gateway.

Gateway endpoints do not grant application authorization. IAM policies,
resource policies, and workload identities continue to control access.

Interface VPC endpoints are deferred until consuming workloads are implemented
because interface endpoints incur hourly and data-processing charges in each
selected Availability Zone.

### VPC Flow Logs

VPC Flow Logs capture accepted and rejected traffic for the complete VPC.

The implementation uses:

- Traffic type `ALL`
- Maximum aggregation interval of 60 seconds
- Amazon CloudWatch Logs as the destination
- A 30-day retention period
- A dedicated IAM delivery role
- A dedicated customer-managed KMS key
- Annual automatic KMS key rotation

Flow Logs contain network metadata rather than packet payloads. They support
network troubleshooting, security investigations, traffic analysis, and
future automated detection workflows.

### Default security group

The default VPC security group is managed by Terraform with no ingress or
egress rules.

AVOS resources must use purpose-built security groups that express their
specific communication requirements. This prevents accidental use of the
permissive rules AWS normally places on the default security group.

### Network ACLs

AVOS retains the default network ACL behavior for the initial network
foundation.

Security groups are the primary workload-level network control because they
are stateful and can reference other security groups. Custom network ACLs will
not be introduced without a defined compliance, subnet-boundary, or
explicit-deny requirement.

This avoids unnecessary stateless-filtering complexity, particularly manual
management of return traffic and ephemeral port ranges.

### Terraform state

The networking root uses the protected remote S3 backend created during
Phase 2:

```text
network/terraform.tfstate
```

Native S3 state locking, bucket versioning, and KMS encryption protect the
networking state.

### Terraform outputs

The networking root publishes stable outputs for:

- VPC identifiers and CIDR block
- Availability Zones
- Public subnet IDs and CIDRs
- Private application subnet IDs and CIDRs
- Private data subnet IDs and CIDRs
- Internet Gateway identifier
- NAT Gateway identifiers and public addresses
- Public and private route-table identifiers
- S3 and DynamoDB endpoint identifiers
- VPC Flow Log resources
- Flow Logs KMS key and CloudWatch Logs destination
- Restricted default security group identifier

Both ordered subnet lists and Availability-Zone-keyed maps are exposed.
Ordered lists support services such as EKS, load balancers, and databases,
while maps preserve explicit AZ-to-subnet relationships.

## Alternatives considered

### One subnet tier

Rejected because it would mix public entry points, application workloads, and
data services within the same routing boundary.

### Two Availability Zones

Rejected because three Availability Zones provide a stronger foundation for
future EKS, load balancer, and database resilience.

### One NAT Gateway per Availability Zone in development

Deferred because three NAT Gateways would increase development cost. The
Terraform design supports moving to per-AZ NAT Gateways for higher
environments.

### NAT Gateway access for S3 and DynamoDB

Rejected as the preferred path because Gateway VPC endpoints provide private
routing and avoid unnecessary NAT data-processing charges.

### Immediate deployment of interface endpoints

Deferred until consumer requirements are known because interface endpoints
have recurring per-AZ costs.

### Custom network ACLs for every subnet tier

Rejected for the initial foundation because no compliance or explicit-deny
requirement currently justifies the operational complexity.

## Consequences

### Positive consequences

- Public, application, and data workloads have distinct routing boundaries.
- Application and data subnets span three Availability Zones.
- Private workloads do not require public IPv4 addresses.
- Data subnets have no general internet route.
- S3 and DynamoDB traffic can bypass the NAT Gateway.
- Network-flow metadata is encrypted and centrally retained.
- The default security group cannot provide unintended connectivity.
- Stable Terraform outputs support downstream infrastructure roots.
- The design can evolve to per-AZ NAT Gateways without redesigning the VPC.

### Tradeoffs

- The development environment's single NAT Gateway is an availability
  dependency on `us-east-2a`.
- Cross-AZ NAT traffic can incur additional charges.
- Other AWS-service traffic may use the NAT path until corresponding interface
  endpoints are intentionally deployed.
- CloudWatch Logs, the NAT Gateway, its public IPv4 address, and the
  customer-managed KMS key incur AWS charges.
- Network ACLs do not currently provide subnet-level explicit-deny controls.

## Future considerations

- Use one NAT Gateway per Availability Zone in staging and production.
- Add interface VPC endpoints when EKS and platform-service requirements are
  confirmed.
- Introduce workload-specific security groups with least-privilege rules.
- Evaluate IPv6 and egress-only Internet Gateway support.
- Evaluate centralized inspection through AWS Network Firewall if required.
- Add AWS Transit Gateway or VPC peering only when multi-VPC connectivity is
  required.
- Export Flow Logs to a longer-term security analytics platform during the
  observability and AIOps phases.

## Validation criteria

This decision is considered implemented when:

- The VPC uses `10.20.0.0/16` with DNS support and DNS hostnames enabled.
- Nine `/20` subnets exist across the approved three Availability Zones.
- Public subnets route through the Internet Gateway.
- Private application subnets route through the approved NAT topology.
- Private data subnets contain no default internet route.
- S3 and DynamoDB Gateway endpoints are attached only to private route tables.
- VPC Flow Logs deliver encrypted records to CloudWatch Logs.
- The default VPC security group contains no ingress or egress rules.
- Terraform validation succeeds.
- A refresh plan returns exit code `0`.