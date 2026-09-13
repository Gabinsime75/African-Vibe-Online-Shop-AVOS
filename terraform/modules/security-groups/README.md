# 🌐 Networking Root Module

The **Networking Root Module** provisions the foundational networking layer for the CloudHustler Commerce Platform.

This root module composes the reusable networking modules required to create a production-ready AWS network foundation, including VPC networking, public and private subnets, NAT gateways, route tables, security groups, ACM certificates, an Application Load Balancer, and Route53 DNS records.

---

## 🎯 Purpose

The purpose of this root module is to create the shared AWS networking foundation that downstream platform layers will depend on.

This includes:

- A dedicated VPC for the platform
- Public subnets for internet-facing infrastructure
- Private application subnets for compute workloads
- Private database subnets for data-layer workloads
- Internet Gateway for public internet access
- NAT Gateways for private subnet outbound access
- Route tables and subnet associations
- Application Load Balancer security group
- ACM certificate for HTTPS
- HTTP to HTTPS redirect listener
- HTTPS listener forwarding to the application target group
- Route53 alias record pointing to the ALB

---

## 🏗 Architecture

```text
Internet
   |
   v
Route53 Hosted Zone
   |
   v
Application DNS Record
   |
   v
Application Load Balancer
   |
   |-- HTTP  :80  -> Redirect to HTTPS
   |
   |-- HTTPS :443 -> Forward to App Target Group
                        |
                        v
                  Future App Targets
                  EC2 / ECS / EKS Nodes


VPC
├── Public Subnets
│   ├── ALB
│   ├── NAT Gateway AZ A
│   └── NAT Gateway AZ B
│
├── Private Application Subnets
│   └── Future application workloads
│
└── Private Database Subnets
    └── Future database workloads
```

---

## 🚀 Features

- Production-style VPC layout
- Multi-AZ public subnets
- Multi-AZ private application subnets
- Multi-AZ private database subnets
- Internet Gateway
- Optional NAT Gateway support
- Optional single NAT Gateway mode for lower-cost development
- Public route table
- Private route tables per Availability Zone
- ALB security group with HTTP and HTTPS ingress
- Controlled outbound ALB egress
- ACM certificate creation
- DNS validation using Route53
- HTTP to HTTPS redirect
- HTTPS listener with modern TLS policy
- Application target group with health checks
- Route53 alias record for the application endpoint
- Consistent tagging across all resources

---

## 📦 Resources Created

This root module creates resources through the following reusable modules:

```text
modules/
├── vpc/
├── security-groups/
├── acm/
├── alb/
└── route53/
```

The planned resources include:

- `aws_vpc`
- `aws_subnet`
- `aws_internet_gateway`
- `aws_eip`
- `aws_nat_gateway`
- `aws_route_table`
- `aws_route`
- `aws_route_table_association`
- `aws_security_group`
- `aws_vpc_security_group_ingress_rule`
- `aws_vpc_security_group_egress_rule`
- `aws_acm_certificate`
- `aws_acm_certificate_validation`
- `aws_route53_record`
- `aws_lb`
- `aws_lb_listener`
- `aws_lb_target_group`

---

## 📁 Module Structure

```text
networking/
├── versions.tf
├── providers.tf
├── locals.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars
├── terraform.tfvars.example
└── README.md
```

---

## 📥 Inputs

| Name | Description | Type | Required |
|---|---|---:|---:|
| `aws_region` | AWS region where networking resources are created. | `string` | yes |
| `project_name` | Name of the project. | `string` | yes |
| `environment` | Deployment environment such as `dev`, `staging`, or `prod`. | `string` | yes |
| `vpc_cidr` | CIDR block for the VPC. | `string` | yes |
| `public_subnet_cidrs` | CIDR blocks for public subnets. | `list(string)` | yes |
| `private_app_subnet_cidrs` | CIDR blocks for private application subnets. | `list(string)` | yes |
| `private_db_subnet_cidrs` | CIDR blocks for private database subnets. | `list(string)` | yes |
| `enable_nat_gateway` | Whether NAT Gateways should be created. | `bool` | yes |
| `single_nat_gateway` | Whether to use one shared NAT Gateway instead of one per AZ. | `bool` | yes |
| `domain_name` | Primary domain name for the application certificate and hosted zone. | `string` | yes |
| `app_domain_name` | Application DNS name. | `string` | yes |
| `hosted_zone_id` | Existing Route53 hosted zone ID. | `string` | yes |
| `create_app_record` | Whether to create the application DNS record. | `bool` | yes |
| `create_www_record` | Whether to create the `www` DNS record. | `bool` | yes |
| `enable_https` | Whether to create HTTPS listener and ACM certificate. | `bool` | yes |
| `acm_subject_alternative_names` | Additional domain names for the ACM certificate. | `list(string)` | no |
| `acm_key_algorithm` | ACM certificate key algorithm. | `string` | no |
| `certificate_transparency_logging_preference` | Certificate transparency logging preference. | `string` | no |
| `alb_ingress_cidrs` | CIDR blocks allowed to access the ALB. | `list(string)` | yes |
| `enable_http_ingress` | Whether to allow HTTP ingress to the ALB. | `bool` | yes |
| `enable_https_ingress` | Whether to allow HTTPS ingress to the ALB. | `bool` | yes |
| `alb_internal` | Whether the ALB is internal. | `bool` | yes |
| `alb_ip_address_type` | IP address type for the ALB. | `string` | no |
| `enable_alb_deletion_protection` | Whether ALB deletion protection is enabled. | `bool` | no |
| `enable_alb_cross_zone_load_balancing` | Whether cross-zone load balancing is enabled. | `bool` | no |
| `enable_alb_http2` | Whether HTTP/2 is enabled. | `bool` | no |
| `alb_idle_timeout` | ALB idle timeout in seconds. | `number` | no |
| `alb_drop_invalid_header_fields` | Whether invalid HTTP headers are dropped. | `bool` | no |
| `alb_desync_mitigation_mode` | ALB desync mitigation mode. | `string` | no |
| `ssl_policy` | TLS policy for the HTTPS listener. | `string` | no |
| `enable_alb_access_logs` | Whether ALB access logs are enabled. | `bool` | no |
| `alb_access_logs_bucket` | S3 bucket for ALB access logs. | `string` | no |
| `alb_access_logs_prefix` | S3 prefix for ALB access logs. | `string` | no |
| `app_target_group_port` | Application target group port. | `number` | yes |
| `app_target_group_protocol` | Application target group protocol. | `string` | yes |
| `app_target_type` | Application target type. | `string` | yes |
| `app_deregistration_delay` | Target group deregistration delay. | `number` | no |
| `app_slow_start` | Target group slow start duration. | `number` | no |
| `app_load_balancing_algorithm_type` | Target group load balancing algorithm. | `string` | no |
| `app_health_check_protocol` | Health check protocol. | `string` | yes |
| `app_health_check_path` | Health check path. | `string` | yes |
| `app_health_check_port` | Health check port. | `string` | yes |
| `app_health_check_matcher` | Health check success matcher. | `string` | yes |
| `app_health_check_interval` | Health check interval. | `number` | yes |
| `app_health_check_timeout` | Health check timeout. | `number` | yes |
| `app_healthy_threshold` | Healthy threshold count. | `number` | yes |
| `app_unhealthy_threshold` | Unhealthy threshold count. | `number` | yes |
| `enable_alb_stickiness` | Whether target group stickiness is enabled. | `bool` | no |
| `alb_stickiness_duration` | Stickiness cookie duration in seconds. | `number` | no |
| `tags` | Additional tags applied to resources. | `map(string)` | no |

---

## 📤 Outputs

| Name | Description |
|---|---|
| `vpc_id` | ID of the VPC. |
| `vpc_cidr_block` | CIDR block of the VPC. |
| `public_subnet_ids` | IDs of the public subnets. |
| `private_app_subnet_ids` | IDs of the private application subnets. |
| `private_db_subnet_ids` | IDs of the private database subnets. |
| `internet_gateway_id` | ID of the Internet Gateway. |
| `nat_gateway_ids` | IDs of the NAT Gateways. |
| `public_route_table_id` | ID of the public route table. |
| `private_route_table_ids` | IDs of the private route tables. |
| `security_group_ids` | Map of security group IDs. |
| `alb_security_group_id` | Security group ID attached to the ALB. |
| `certificate_arn` | ARN of the ACM certificate. |
| `validated_certificate_arn` | ARN of the validated ACM certificate. |
| `certificate_domain_name` | Domain name on the ACM certificate. |
| `domain_validation_options` | DNS validation options for ACM. |
| `validation_record_fqdns` | FQDNs of ACM validation records. |
| `alb_id` | ID of the Application Load Balancer. |
| `alb_arn` | ARN of the Application Load Balancer. |
| `alb_dns_name` | DNS name of the Application Load Balancer. |
| `alb_zone_id` | Route53 hosted zone ID of the ALB. |
| `alb_listener_arns` | Map of ALB listener ARNs. |
| `alb_target_group_arns` | Map of ALB target group ARNs. |
| `app_target_group_arn` | ARN of the application target group. |
| `app_target_group_name` | Name of the application target group. |
| `hosted_zone_id` | Route53 hosted zone ID used by this root module. |
| `hosted_zone_name` | Route53 hosted zone name used by this root module. |
| `route53_record_fqdns` | FQDNs of Route53 records. |
| `route53_record_names` | Names of Route53 records. |
| `application_url` | Primary application URL. |
| `alb_health_check_path` | Health check path configured for the application target group. |

---

## 💻 Example Usage

Create a `terraform.tfvars` file:

```hcl
aws_region   = "us-east-2"
project_name = "cloudhustler-commerce-platform"
environment  = "dev"

vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs = [
  "10.0.0.0/24",
  "10.0.1.0/24"
]

private_app_subnet_cidrs = [
  "10.0.2.0/24",
  "10.0.3.0/24"
]

private_db_subnet_cidrs = [
  "10.0.4.0/24",
  "10.0.5.0/24"
]

enable_nat_gateway = true
single_nat_gateway = false

domain_name     = "cloudhusller.com"
app_domain_name = "cloudhusller.com"
hosted_zone_id  = "Z08118211LIG93KC7E5CI"

create_app_record = true
create_www_record = false

enable_https = true

acm_subject_alternative_names = [
  "www.cloudhusller.com"
]

alb_ingress_cidrs = [
  "0.0.0.0/0"
]

enable_http_ingress  = true
enable_https_ingress = true

alb_internal = false

app_target_group_port     = 80
app_target_group_protocol = "HTTP"
app_target_type           = "instance"

app_health_check_protocol = "HTTP"
app_health_check_path     = "/health"
app_health_check_port     = "traffic-port"
app_health_check_matcher  = "200-399"
app_health_check_interval = 30
app_health_check_timeout  = 5

app_healthy_threshold   = 5
app_unhealthy_threshold = 2

tags = {
  Owner      = "Gabin"
  CostCenter = "CloudHustler"
}
```

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate
```

Review the execution plan:

```bash
terraform plan
```

Apply the networking layer:

```bash
terraform apply
```

---

## 🔒 Security Considerations

- Public access is limited to the ALB security group.
- HTTP traffic is redirected to HTTPS when HTTPS is enabled.
- HTTPS uses a modern TLS policy.
- Private application and database subnets do not assign public IPs on launch.
- NAT Gateways allow private workloads to reach the internet without being directly exposed.
- Route53 records use ALB alias records instead of hardcoded IP addresses.
- ACM certificates are validated through DNS using Route53.
- The ALB drops invalid HTTP header fields.
- The ALB uses defensive desync mitigation mode.
- Deletion protection can be enabled for production ALBs.
- ALB access logs can be enabled for auditability.

---

## 💡 Design Decisions

### Single Networking Root

This root module is intentionally designed as one deployment unit for the networking layer.

It composes reusable modules instead of creating resources directly in the root module.

```text
networking/
└── calls reusable modules from ../modules/
```

This keeps the root clean and makes the reusable modules portable.

---

### Public, Private Application, and Private Database Subnets

The VPC separates workloads into three tiers:

```text
Public Subnets
Private Application Subnets
Private Database Subnets
```

This supports a common enterprise network pattern where:

- Public resources are internet-facing.
- Application workloads run privately.
- Database workloads are isolated from direct internet access.

---

### Multi-AZ NAT Gateway Support

The module supports both:

```hcl
single_nat_gateway = true
```

and:

```hcl
single_nat_gateway = false
```

For development, a single NAT Gateway reduces cost.

For production, one NAT Gateway per AZ improves availability.

---

### ACM DNS Validation

ACM validation records are created automatically in Route53.

This avoids manual DNS validation steps and allows Terraform to manage the full HTTPS certificate lifecycle.

---

### HTTP to HTTPS Redirect

When HTTPS is enabled, the ALB creates:

```text
HTTP  :80  -> Redirect to HTTPS :443
HTTPS :443 -> Forward to app target group
```

This enforces encrypted traffic at the load balancer layer.

---

### Target Group Without Registered Targets

The application target group is created without registered targets at this stage.

This is expected.

Targets will be attached later by downstream compute layers such as:

- EC2 Auto Scaling Groups
- ECS Services
- EKS workloads
- AWS Load Balancer Controller

---

## 🧪 Testing

Run formatting:

```bash
terraform fmt -recursive
```

Run validation:

```bash
terraform validate
```

Run plan:

```bash
terraform plan
```

Expected successful result:

```text
Plan: 37 to add, 0 to change, 0 to destroy.
```

---

## 📖 Next Steps

After this networking layer is applied, the next platform layers can be built on top of it:

1. Finalize remote backend configuration for the networking root.
2. Apply the networking root.
3. Create the security root module.
4. Create the observability root module.
5. Create the EKS/container platform root module.
6. Attach workloads to the ALB target group.
7. Add WAF in front of the Application Load Balancer.
8. Enable ALB access logs for production.
9. Add VPC endpoints for private AWS service access.
10. Add VPC Flow Logs if not already enabled in the VPC module.