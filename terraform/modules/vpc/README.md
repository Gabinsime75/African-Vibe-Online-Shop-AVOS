# 🌐 VPC Module

The **VPC Module** provisions the networking foundation for the CloudHustler Commerce Platform.

It creates a highly available Virtual Private Cloud (VPC) spanning multiple Availability Zones and provisions all networking components required for application workloads, including public subnets, private application subnets, private database subnets, Internet Gateway, NAT Gateways, route tables, and optional VPC Flow Logs.

The module is designed to be reusable across development, staging, and production environments while following AWS networking best practices.

---

# 🎯 Purpose

This module creates:

- Amazon VPC
- Internet Gateway
- Public Subnets
- Private Application Subnets
- Private Database Subnets
- Elastic IP Addresses
- NAT Gateways
- Public Route Table
- Private Route Tables
- Route Table Associations
- Optional VPC Flow Logs

---

# 🏗 Architecture

```text
                         Internet
                             │
                     Internet Gateway
                             │
                   ┌──────────────────┐
                   │       VPC        │
                   │   10.0.0.0/16    │
                   └──────────────────┘
                             │
        ┌────────────────────┴────────────────────┐
        │                                         │
 Availability Zone A                      Availability Zone B

 Public Subnet                           Public Subnet
      │                                       │
 NAT Gateway                           NAT Gateway
      │                                       │
 Private App Subnet                  Private App Subnet
      │                                       │
 Private DB Subnet                   Private DB Subnet
```

This design provides high availability by distributing infrastructure across multiple Availability Zones.

---

# 🚀 Features

- Region-agnostic Availability Zone discovery
- Configurable number of Availability Zones
- Multi-AZ architecture
- Public and private subnet separation
- Dedicated database subnet tier
- Optional single NAT Gateway for development environments
- One NAT Gateway per Availability Zone for production
- Optional IPv6 support
- Optional VPC Flow Logs
- Consistent resource tagging
- Enterprise naming convention

---

# 📦 Resources Created

The module provisions the following AWS resources:

- aws_vpc
- aws_internet_gateway
- aws_subnet (Public)
- aws_subnet (Private Application)
- aws_subnet (Private Database)
- aws_eip
- aws_nat_gateway
- aws_route_table
- aws_route
- aws_route_table_association
- aws_flow_log (optional)

---

# 📁 Module Structure

```text
modules/
└── vpc/
    ├── data.tf
    ├── locals.tf
    ├── network.tf
    ├── subnets.tf
    ├── nat.tf
    ├── route_tables.tf
    ├── flow_logs.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

Each file is responsible for a single networking component, making the module easier to maintain and extend.

---

# 📥 Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| project_name | Project name | string | n/a |
| environment | Deployment environment | string | n/a |
| tags | Resource tags | map(string) | {} |
| vpc_cidr | VPC CIDR block | string | n/a |
| enable_dns_support | Enable DNS resolution | bool | true |
| enable_dns_hostnames | Enable DNS hostnames | bool | true |
| az_count | Number of Availability Zones | number | 2 |
| public_subnet_cidrs | Public subnet CIDRs | list(string) | n/a |
| private_app_subnet_cidrs | Private application subnet CIDRs | list(string) | n/a |
| private_db_subnet_cidrs | Private database subnet CIDRs | list(string) | n/a |
| enable_nat_gateway | Enable NAT Gateways | bool | true |
| single_nat_gateway | Single NAT Gateway | bool | false |
| enable_flow_logs | Enable VPC Flow Logs | bool | false |
| flow_logs_destination_arn | Flow Logs destination ARN | string | null |
| flow_logs_iam_role_arn | Flow Logs IAM Role ARN | string | null |
| flow_logs_traffic_type | Flow Logs traffic type | string | ALL |
| enable_ipv6 | Enable IPv6 | bool | false |

---

# 📤 Outputs

The module exports:

- VPC ID
- VPC ARN
- VPC CIDR Block
- Availability Zones
- Public Subnet IDs
- Private Application Subnet IDs
- Private Database Subnet IDs
- Internet Gateway ID
- NAT Gateway IDs
- Public Route Table ID
- Private Route Table IDs

These outputs are consumed by downstream modules such as:

- Security Groups
- Application Load Balancer
- Amazon EKS
- Amazon RDS
- Amazon ElastiCache
- Amazon OpenSearch

---

# 💻 Example Usage

```terraform
module "vpc" {

  source = "../../modules/vpc"

  project_name = "cloudhustler-commerce-platform"

  environment = "dev"

  vpc_cidr = "10.0.0.0/16"

  az_count = 2

  public_subnet_cidrs = [

    "10.0.1.0/24",
    "10.0.2.0/24"

  ]

  private_app_subnet_cidrs = [

    "10.0.11.0/24",
    "10.0.12.0/24"

  ]

  private_db_subnet_cidrs = [

    "10.0.21.0/24",
    "10.0.22.0/24"

  ]

  tags = {

    Project = "CloudHustler"

  }

}
```

---

# 🌐 Network Layout

| Tier | Purpose |
|------|---------|
| Public | Internet-facing resources such as Application Load Balancers and NAT Gateways |
| Private Application | Amazon EKS worker nodes, APIs, and microservices |
| Private Database | PostgreSQL, ElastiCache, OpenSearch, and future data services |

This layered approach improves security by preventing direct internet access to application and database resources.

---

# 🏷 Tagging Strategy

Every resource receives a common set of tags.

Example:

```text
Project     = CloudHustler
Environment = dev
ManagedBy   = Terraform
```

Resource-specific tags such as **Name** and **Tier** are automatically added by the module.

---

# 🔒 Security Considerations

This module follows AWS networking best practices.

- Database resources remain in private subnets.
- Application workloads remain in private subnets.
- Only public-facing resources are deployed in public subnets.
- Public subnet instances automatically receive public IP addresses.
- NAT Gateways provide outbound internet access for private resources.
- VPC Flow Logs can be enabled for traffic monitoring.
- DNS Hostnames and DNS Resolution are enabled by default.

---

# 💡 Design Decisions

Several architectural decisions were made to improve portability, maintainability, and reusability.

## Dynamic Availability Zone Discovery

The module automatically discovers the available Availability Zones in the selected AWS Region.

Instead of requiring users to specify AZ names such as:

```text
us-east-1a
us-east-1b
```

the module selects the required number of Availability Zones based on the `az_count` variable.

This makes the module portable across AWS Regions without modification.

---

## Separate Subnet Tiers

The network is divided into three logical tiers:

- Public
- Private Application
- Private Database

This separation improves security, simplifies routing, and aligns with enterprise network architecture.

---

## Configurable NAT Strategy

Development environments can reduce cost by deploying a single NAT Gateway.

Production environments can improve availability by deploying one NAT Gateway per Availability Zone.

The same module supports both deployment models through configuration.

---

## File Organization

Instead of placing every resource into a single `main.tf`, the module is organized by responsibility.

This approach improves readability, simplifies maintenance, and scales better as the networking layer evolves.

---

# 📖 Next Steps

This module provides the networking foundation for the remaining CloudHustler Commerce Platform infrastructure.

The next modules will consume its outputs to provision:

- Security Groups
- Application Load Balancers
- Amazon EKS
- Amazon RDS
- Amazon ElastiCache
- Amazon OpenSearch
- Route 53
- ACM
- CloudFront
- AWS WAF

Together, these modules form the networking layer of the CloudHustler Commerce Platform.