# 🚀 Application Load Balancer (ALB) Module

The **Application Load Balancer (ALB) Module** provisions a production-grade AWS Application Load Balancer using reusable Terraform code.

The module supports multiple listeners, listener rules, weighted target groups, health checks, redirects, fixed responses, and HTTPS termination while following enterprise infrastructure standards.

---

# 🎯 Purpose

This module creates:

- Application Load Balancer
- Target Groups
- HTTP and HTTPS Listeners
- Listener Rules
- Health Checks
- Weighted Target Groups
- Access Logging
- Cross-Zone Load Balancing

---

# 🏗 Architecture

```
                Internet
                    │
                    ▼
        ┌─────────────────────┐
        │ Application Load    │
        │     Balancer        │
        └─────────┬───────────┘
                  │
      ┌───────────┴───────────┐
      ▼                       ▼
 Target Group A          Target Group B
      │                       │
      ▼                       ▼
    EC2/ECS/EKS           EC2/ECS/EKS
```

---

# 🚀 Features

- Internet-facing or Internal ALB
- HTTP Listeners
- HTTPS Listeners
- Multiple Listener Rules
- Host-based Routing
- Path-based Routing
- Redirect Actions
- Fixed Response Actions
- Forward Actions
- Weighted Target Groups
- Stickiness
- Health Checks
- HTTP/2
- Cross-Zone Load Balancing
- Access Logs
- IPv4 / DualStack
- Enterprise Tagging

---

# 📦 Resources Created

- aws_lb
- aws_lb_target_group
- aws_lb_listener
- aws_lb_listener_rule

---

# 📁 Module Structure

```
modules/
└── alb/
    ├── data.tf
    ├── locals.tf
    ├── load_balancer.tf
    ├── target_groups.tf
    ├── listeners.tf
    ├── listener_rules.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

---

# 📥 Inputs

| Name | Description |
|------|-------------|
| name | ALB Name |
| vpc_id | VPC ID |
| subnet_ids | Subnets for the ALB |
| security_group_ids | Security Groups |
| listeners | Listener configuration |
| listener_rules | Listener rules |
| target_groups | Target Groups |
| access_logs | Access log configuration |
| tags | Resource tags |

---

# 📤 Outputs

| Name | Description |
|------|-------------|
| id | ALB ID |
| arn | ALB ARN |
| arn_suffix | ALB ARN Suffix |
| dns_name | DNS Name |
| zone_id | Hosted Zone ID |
| listener_arns | Listener ARNs |
| target_group_ids | Target Group IDs |
| target_group_arns | Target Group ARNs |
| target_group_names | Target Group Names |
| listener_rule_ids | Listener Rule IDs |
| listener_rule_arns | Listener Rule ARNs |

---

# 💻 Example Usage

```hcl
module "alb" {

  source = "../../modules/alb"

  name               = "commerce-alb"

  vpc_id             = module.vpc.vpc_id

  subnet_ids         = module.vpc.public_subnet_ids

  security_group_ids = [module.alb_sg.id]

  listeners = {}

  listener_rules = {}

  target_groups = {}

  tags = {

    Environment = "dev"

    ManagedBy = "Terraform"

  }

}
```

---

# 🔒 Security Considerations

- Supports HTTPS listeners with ACM certificates.
- Supports internal and internet-facing deployments.
- Compatible with AWS WAF.
- Compatible with AWS Shield.
- Supports private target groups.
- Supports access logging for auditing.

---

# 💡 Design Decisions

- One reusable module for all ALB deployments.
- Dynamic listeners.
- Dynamic listener rules.
- Dynamic target groups.
- Strongly typed variables.
- Enterprise tagging strategy.
- Fully reusable across environments.

---

# 📖 Next Steps

This module is intended to be consumed by the Networking ALB root module, where environment-specific configuration, certificates, DNS records, and WAF associations are composed into complete load balancer deployments.