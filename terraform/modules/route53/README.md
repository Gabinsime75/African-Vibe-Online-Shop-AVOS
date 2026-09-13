# 🚀 Route53 Module

The **Route53 Module** provisions and manages AWS Route53 hosted zones, DNS records, alias records, routing policies, and health checks using reusable Terraform code.

This module is designed for the CloudHustler Commerce Platform networking layer and can be reused across dev, staging, production, and future AWS accounts.

---

## 🎯 Purpose

This module provides a reusable DNS foundation for AWS workloads.

It supports:

- Public hosted zones
- Private hosted zones
- Existing hosted zone lookup
- Standard DNS records
- Alias records
- ALB alias records
- Weighted routing
- Failover routing
- Latency routing
- Geolocation routing
- Multivalue answer routing
- Route53 health checks

---

## 🏗 Architecture

```text
Domain
  │
  ▼
Route53 Hosted Zone
  │
  ├── A / AAAA Records
  ├── CNAME Records
  ├── TXT Records
  ├── MX Records
  ├── Alias Records
  │      │
  │      ▼
  │   ALB / CloudFront / API Gateway
  │
  └── Health Checks
         │
         ▼
   Failover / Weighted Routing
```

---

## 🚀 Features

- Create new Route53 hosted zones
- Use existing hosted zones
- Hosted zone lookup by name
- Public hosted zones
- Private hosted zones
- VPC association for private zones
- Standard DNS records
- Alias DNS records
- ALB alias support
- Weighted routing policies
- Failover routing policies
- Latency routing policies
- Geolocation routing policies
- Multivalue answer routing
- Route53 health checks
- Health check association with DNS records
- Enterprise tagging
- Safe overwrite support for DNS records

---

## 📦 Resources Created

This module can create the following resources:

- `aws_route53_zone`
- `aws_route53_record`
- `aws_route53_health_check`

---

## 📁 Module Structure

```text
modules/
└── route53/
    ├── data.tf
    ├── locals.tf
    ├── hosted_zone.tf
    ├── records.tf
    ├── health_checks.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

---

## 📥 Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `create_hosted_zone` | Whether to create a new Route53 hosted zone. | `bool` | `false` |
| `hosted_zone_id` | Existing Route53 hosted zone ID. Used when `create_hosted_zone` is false. | `string` | `null` |
| `hosted_zone_name` | Route53 hosted zone name. | `string` | Required |
| `private_zone` | Whether the hosted zone is private. | `bool` | `false` |
| `comment` | Comment for the Route53 hosted zone. | `string` | `null` |
| `force_destroy` | Whether to destroy all records in the hosted zone when deleting the zone. | `bool` | `false` |
| `vpcs` | VPC associations for private hosted zones. | `list(object)` | `[]` |
| `records` | Route53 DNS records. | `map(object)` | `{}` |
| `health_checks` | Route53 health checks. | `map(object)` | `{}` |
| `tags` | Tags applied to supported Route53 resources. | `map(string)` | `{}` |

---

## 📤 Outputs

| Name | Description |
|------|-------------|
| `hosted_zone_id` | Route53 hosted zone ID used by this module. |
| `hosted_zone_name` | Route53 hosted zone name. |
| `hosted_zone_arn` | ARN of the Route53 hosted zone when created by this module. |
| `hosted_zone_name_servers` | Name servers for the hosted zone when created by this module. |
| `record_names` | Map of Route53 record names. |
| `record_fqdns` | Map of Route53 record FQDNs. |
| `record_types` | Map of Route53 record types. |
| `health_check_ids` | Map of Route53 health check IDs. |
| `health_check_arns` | Map of Route53 health check ARNs. |

---

## 💻 Example Usage

### Use Existing Hosted Zone with ALB Alias Record

```hcl
module "route53" {
  source = "../modules/route53"

  create_hosted_zone = false

  hosted_zone_id   = "Z123456789ABCDEFG"
  hosted_zone_name = "cloudhustler.com"

  records = {
    app = {
      name = "app.cloudhustler.com"
      type = "A"

      alias = {
        name                   = module.alb.dns_name
        zone_id                = module.alb.zone_id
        evaluate_target_health = true
      }
    }
  }

  tags = {
    Project     = "cloudhustler-commerce-platform"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

---

### Create a New Public Hosted Zone

```hcl
module "route53" {
  source = "../modules/route53"

  create_hosted_zone = true

  hosted_zone_name = "cloudhustler.com"

  comment = "Public hosted zone for CloudHustler Commerce Platform."

  records = {
    www = {
      name    = "www.cloudhustler.com"
      type    = "CNAME"
      ttl     = 300
      records = ["cloudhustler.com"]
    }
  }

  tags = {
    Project     = "cloudhustler-commerce-platform"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

---

### Create a Private Hosted Zone

```hcl
module "route53_private" {
  source = "../modules/route53"

  create_hosted_zone = true

  hosted_zone_name = "internal.cloudhustler.com"

  private_zone = true

  vpcs = [
    {
      vpc_id     = module.vpc.vpc_id
      vpc_region = "us-east-2"
    }
  ]

  records = {
    api = {
      name    = "api.internal.cloudhustler.com"
      type    = "A"
      ttl     = 300
      records = ["10.0.10.25"]
    }
  }

  tags = {
    Project     = "cloudhustler-commerce-platform"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

---

### Standard DNS Records

```hcl
module "route53" {
  source = "../modules/route53"

  create_hosted_zone = false

  hosted_zone_id   = "Z123456789ABCDEFG"
  hosted_zone_name = "cloudhustler.com"

  records = {
    root_txt = {
      name    = "cloudhustler.com"
      type    = "TXT"
      ttl     = 300
      records = ["v=spf1 include:amazonses.com ~all"]
    }

    api_cname = {
      name    = "api.cloudhustler.com"
      type    = "CNAME"
      ttl     = 300
      records = ["app.cloudhustler.com"]
    }

    mx = {
      name = "cloudhustler.com"
      type = "MX"
      ttl  = 300

      records = [
        "10 inbound-smtp.us-east-1.amazonaws.com"
      ]
    }
  }

  tags = {
    Project     = "cloudhustler-commerce-platform"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

---

### Weighted Routing

```hcl
module "route53" {
  source = "../modules/route53"

  create_hosted_zone = false

  hosted_zone_id   = "Z123456789ABCDEFG"
  hosted_zone_name = "cloudhustler.com"

  records = {
    app_blue = {
      name = "app.cloudhustler.com"
      type = "A"

      set_identifier = "blue"

      alias = {
        name                   = module.blue_alb.dns_name
        zone_id                = module.blue_alb.zone_id
        evaluate_target_health = true
      }

      weighted_routing_policy = {
        weight = 80
      }
    }

    app_green = {
      name = "app.cloudhustler.com"
      type = "A"

      set_identifier = "green"

      alias = {
        name                   = module.green_alb.dns_name
        zone_id                = module.green_alb.zone_id
        evaluate_target_health = true
      }

      weighted_routing_policy = {
        weight = 20
      }
    }
  }

  tags = {
    Project     = "cloudhustler-commerce-platform"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}
```

---

### Failover Routing with Health Checks

```hcl
module "route53" {
  source = "../modules/route53"

  create_hosted_zone = false

  hosted_zone_id   = "Z123456789ABCDEFG"
  hosted_zone_name = "cloudhustler.com"

  health_checks = {
    primary_app = {
      fqdn              = "primary.cloudhustler.com"
      type              = "HTTPS"
      port              = 443
      resource_path     = "/health"
      failure_threshold = 3
      request_interval  = 30
    }
  }

  records = {
    app_primary = {
      name = "app.cloudhustler.com"
      type = "A"

      set_identifier   = "primary"
      health_check_key = "primary_app"

      alias = {
        name                   = module.primary_alb.dns_name
        zone_id                = module.primary_alb.zone_id
        evaluate_target_health = true
      }

      failover_routing_policy = {
        type = "PRIMARY"
      }
    }

    app_secondary = {
      name = "app.cloudhustler.com"
      type = "A"

      set_identifier = "secondary"

      alias = {
        name                   = module.secondary_alb.dns_name
        zone_id                = module.secondary_alb.zone_id
        evaluate_target_health = true
      }

      failover_routing_policy = {
        type = "SECONDARY"
      }
    }
  }

  tags = {
    Project     = "cloudhustler-commerce-platform"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}
```

---

## 🔒 Security Considerations

- Use private hosted zones for internal service discovery.
- Avoid exposing internal application endpoints in public hosted zones.
- Use least-privilege IAM permissions for Route53 record management.
- Use health checks for production failover routing.
- Be careful with `force_destroy`; it can delete DNS records when destroying a hosted zone.
- Avoid hardcoding hosted zone IDs inside reusable modules.
- Keep hosted zone IDs in root module variables or environment-specific `terraform.tfvars`.
- Use alias records for AWS resources such as ALBs and CloudFront distributions.
- Use separate hosted zones where environment isolation is required.

---

## 💡 Design Decisions

- The module can create a hosted zone or use an existing hosted zone.
- Hosted zone IDs are passed from root modules, not hardcoded inside the reusable module.
- DNS records are modeled as a map for stable Terraform resource addressing.
- Alias records and standard records share the same `records` input object.
- Routing policies are optional nested objects.
- Route53 health checks are optional and can be associated with records.
- Private hosted zone VPC associations are supported through the `vpcs` input.
- The module is designed to be consumed by the CloudHustler networking root module.

---

## 🧪 Testing

Run the following commands from the module directory:

```bash
terraform fmt
terraform validate
```

For integration testing, consume this module from a root module and run:

```bash
terraform init
terraform plan
```

Before applying Route53 changes, confirm:

- The hosted zone name is correct.
- The hosted zone ID belongs to the correct AWS account.
- Public and private hosted zones are not confused.
- Alias target hosted zone IDs are correct.
- Health checks point to valid endpoints.
- Routing policies include required `set_identifier` values.

---

## 📖 Next Steps

This module is designed to be consumed by the CloudHustler networking root module.

Typical downstream usage:

```text
ACM Certificate
    │
    ▼
Application Load Balancer
    │
    ▼
Route53 Alias Record
    │
    ▼
Application Domain
```

After this module is complete, the next step is to build the `networking/` root module that composes:

- VPC
- Security Groups
- ACM
- ALB
- Route53