# AWS Load Balancer Controller - TargetGroupBinding Module

---

# 🚀 Overview

This module creates an AWS Load Balancer Controller **TargetGroupBinding** resource inside Kubernetes.

A TargetGroupBinding associates an **existing AWS Application Load Balancer Target Group** with a Kubernetes Service. The AWS Load Balancer Controller automatically registers and deregisters Pod IPs in the target group as Pods are created, deleted, or rescheduled.

Unlike an Ingress resource, this module does **not** create a new Application Load Balancer. Instead, it integrates Kubernetes workloads with an ALB that is already managed by Terraform.

---

# 🎯 Purpose

This module enables CloudHustler Commerce Platform to use a centrally managed AWS Application Load Balancer while routing traffic into the Istio service mesh.

It provides:

- Existing ALB integration
- Existing Target Group integration
- Automatic Pod registration
- Automatic Pod deregistration
- Native AWS Load Balancer Controller integration

---

# 🏗 Architecture

```
                    Internet
                         │
                    Route53 DNS
                         │
                         ▼
                 AWS WAF (Regional)
                         │
                         ▼
             Application Load Balancer
                         │
                         ▼
            Existing AWS Target Group
                         │
                         ▼
                TargetGroupBinding
                         │
                         ▼
           Kubernetes Service (ClusterIP)
                         │
                         ▼
              Istio Ingress Gateway Pods
                         │
                         ▼
              Istio Gateway / VirtualService
                         │
                         ▼
                  Kubernetes Workloads
```

---

# 🚀 Features

- Supports existing AWS ALBs
- Supports existing Target Groups
- IP target registration
- Instance target registration
- Automatic Pod lifecycle management
- Compatible with Istio Ingress Gateway
- Kubernetes-native implementation
- Terraform managed
- Enterprise ready

---

# 📦 Resources Created

| Resource | Purpose |
|----------|---------|
| TargetGroupBinding | Associates an AWS Target Group with a Kubernetes Service |

---

# 📁 Module Structure

```
modules/
└── target-group-binding/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

---

# 📥 Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| name | TargetGroupBinding name | string | Yes |
| namespace | Kubernetes namespace | string | Yes |
| service_name | Kubernetes Service name | string | Yes |
| service_port | Kubernetes Service port | number | Yes |
| target_group_arn | Existing AWS Target Group ARN | string | Yes |
| target_type | AWS target type (ip or instance) | string | No (default: ip) |
| labels | Kubernetes labels | map(string) | No |
| annotations | Kubernetes annotations | map(string) | No |

---

# 📤 Outputs

| Output | Description |
|---------|-------------|
| name | TargetGroupBinding name |
| namespace | Namespace |
| service_name | Kubernetes Service |
| service_port | Service port |
| target_group_arn | Target Group ARN |
| target_type | Target registration type |
| resource_id | Namespace/name identifier |

---

# 💻 Example Usage

```hcl
module "target_group_binding" {
  source = "../modules/target-group-binding"

  name             = "istio-ingress"
  namespace        = "istio-ingress"

  service_name     = "istio-ingress"
  service_port     = 80

  target_group_arn = data.terraform_remote_state.networking.outputs.istio_ingress_target_group_arn

  target_type = "ip"
}
```

---

# 🔒 Security Considerations

- Uses an existing AWS Target Group.
- Does not create or modify ALB security groups.
- Does not expose Kubernetes Nodes directly.
- Works with ClusterIP Services.
- Traffic enters the cluster only through the Istio Ingress Gateway.
- Compatible with AWS WAF attached to the ALB.
- Supports least-privilege IAM through the AWS Load Balancer Controller.

---

# 💡 Design Decisions

## Existing Infrastructure

This module intentionally **does not create**:

- Application Load Balancers
- Target Groups
- Listeners
- Listener Rules

Those resources are owned by the **networking** Terraform root.

---

## Separation of Responsibilities

Networking owns:

- ALB
- Listeners
- Target Groups
- WAF
- ACM
- Route53

Platform Services owns:

- Kubernetes
- Istio
- TargetGroupBinding

This separation prevents infrastructure duplication and follows enterprise infrastructure ownership boundaries.

---

## IP Target Mode

CloudHustler uses:

```
target_type = "ip"
```

instead of:

```
instance
```

Benefits include:

- Direct Pod registration
- Better load balancing
- No NodePort dependency
- Faster failover
- Better compatibility with EKS and Istio

---

## Health Checks

Application traffic is forwarded to:

```
Service Port 80
```

Istio gateway health checks use:

```
Port: 15021
Path: /healthz/ready
```

Health checks are configured in the Target Group and are **not managed** by this module.

---

## Why TargetGroupBinding?

Without TargetGroupBinding:

```
ALB
  │
  X
```

The ALB has no knowledge of Kubernetes Pods.

With TargetGroupBinding:

```
ALB
   │
Target Group
   │
TargetGroupBinding
   │
Istio Service
   │
Pods
```

The AWS Load Balancer Controller continuously synchronizes Pod IPs with the Target Group.

---

# 📖 Next Steps

After deploying this module, the next components of the CloudHustler Commerce Platform are:

- ExternalDNS
- External Secrets Operator
- Karpenter
- Cert-Manager (if required)
- Prometheus
- Grafana
- Loki
- Kiali
- Jaeger
- OpenTelemetry
- AWS X-Ray

These components complete the production-grade Kubernetes platform before application deployment.

---

# ✅ Expected Result

After deployment:

- The existing ALB forwards traffic to the existing AWS Target Group.
- The AWS Load Balancer Controller registers Istio Gateway Pod IPs.
- Healthy gateway Pods receive traffic.
- Unhealthy or terminated Pods are automatically deregistered.
- Traffic enters the Istio service mesh through the Ingress Gateway without requiring an additional Application Load Balancer.