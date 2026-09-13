# Istio Ingress Gateway Module

## 🚀 Overview

This module installs a dedicated Istio ingress gateway into an existing Kubernetes cluster using the official Istio `gateway` Helm chart.

The gateway is deployed as a Kubernetes `ClusterIP` Service.

It does not create a Kubernetes `LoadBalancer` Service and therefore does not create another AWS Application Load Balancer.

## 🎯 Purpose

The ingress gateway provides the entry point into the CloudHustler service mesh.

The gateway will eventually receive traffic through the existing Terraform-managed AWS ALB and dedicated Istio target group.

```text
Route 53
   ↓
AWS WAF
   ↓
Existing ALB
   ↓
Dedicated Istio IP target group
   ↓
TargetGroupBinding
   ↓
Istio ingress gateway
   ↓
Commerce microservices
```

## 🏗 Architecture

```text
Networking Root
├── Existing public ALB
└── Istio IP target group
          │
          │ TargetGroupBinding
          ▼
Amazon EKS Cluster
└── istio-ingress namespace
    ├── ClusterIP Service
    │   ├── 15021 → 15021 readiness
    │   ├── 80 → 8080 HTTP
    │   └── 443 → 8443 HTTPS
    │
    └── Istio ingress gateway pods
        └── Envoy proxy
```

## 🚀 Features

- Installs the official Istio gateway Helm chart
- Uses the same pinned version as Istiod
- Deploys the gateway as a ClusterIP Service
- Avoids creating a second AWS load balancer
- Exposes HTTP port 80
- Exposes HTTPS port 443
- Exposes readiness port 15021
- Supports horizontal autoscaling
- Supports highly available replicas
- Supports PodDisruptionBudget configuration
- Supports topology spread across nodes and Availability Zones
- Applies hardened container security settings
- Supports additional Helm values

## 📦 Resources Created

Terraform creates:

- `helm_release.this`

The Helm chart creates Kubernetes resources including:

- Deployment
- ClusterIP Service
- ServiceAccount
- Role and RoleBinding
- HorizontalPodAutoscaler
- PodDisruptionBudget

## 📁 Module Structure

```text
modules/istio-ingress-gateway/
├── helm.tf
├── variables.tf
├── outputs.tf
└── README.md
```

## 📥 Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `chart_version` | Pinned Istio gateway version | `string` | `1.30.1` |
| `release_name` | Helm release name | `string` | `istio-ingress` |
| `gateway_name` | Gateway resource name | `string` | `istio-ingress` |
| `namespace` | Gateway namespace | `string` | `istio-ingress` |
| `revision` | Istio control-plane revision | `string` | `default` |
| `enable_autoscaling` | Enable gateway autoscaling | `bool` | `true` |
| `autoscale_min_replicas` | Minimum replicas | `number` | `2` |
| `autoscale_max_replicas` | Maximum replicas | `number` | `5` |
| `cpu_request` | CPU request | `string` | `200m` |
| `memory_request` | Memory request | `string` | `256Mi` |
| `cpu_limit` | CPU limit | `string` | `1000m` |
| `memory_limit` | Memory limit | `string` | `1024Mi` |
| `service_annotations` | Service annotations | `map(string)` | `{}` |
| `pod_annotations` | Pod annotations | `map(string)` | `{}` |
| `additional_values` | Additional raw YAML values | `list(string)` | `[]` |

## 📤 Outputs

| Name | Description |
|---|---|
| `release_name` | Helm release name |
| `release_namespace` | Gateway namespace |
| `release_status` | Helm release status |
| `chart_version` | Installed chart version |
| `gateway_name` | Gateway name |
| `service_name` | Kubernetes Service name |
| `service_type` | Kubernetes Service type |
| `http_service_port` | HTTP Service port |
| `https_service_port` | HTTPS Service port |
| `status_service_port` | Status Service port |

## 💻 Example Usage

```hcl
module "istio_ingress_gateway" {
  source = "../modules/istio-ingress-gateway"

  chart_version = "1.30.1"

  release_name = "istio-ingress"
  gateway_name = "istio-ingress"
  namespace    = "istio-ingress"

  revision = "default"

  enable_autoscaling     = true
  autoscale_min_replicas = 2
  autoscale_max_replicas = 5
}
```

## 🔒 Security Considerations

The gateway Service uses `ClusterIP`, which prevents Kubernetes from creating an externally accessible AWS load balancer.

External traffic reaches the gateway only through the existing ALB and approved Istio target group.

The gateway container runs as a non-root user, disables privilege escalation, and drops Linux capabilities.

TLS currently terminates at the existing ALB using the ACM certificate. The ALB forwards HTTP traffic to the Istio gateway target group.

If end-to-end TLS is introduced later, the target group and gateway configuration can be extended to use HTTPS.

## 💡 Design Decisions

### ClusterIP instead of LoadBalancer

The networking Terraform root already owns the public ALB, listeners, WAF association, ACM certificate, Route 53 records, and target groups.

Creating a Kubernetes LoadBalancer Service would create a separate AWS load balancer and break the intended ownership model.

### Separate gateway namespace

The ingress gateway is installed in `istio-ingress`, separate from the control plane in `istio-system`.

This provides clearer lifecycle, RBAC, scaling, and security boundaries.

### Separate gateway module

The ingress gateway has an independent lifecycle from Istiod and can be upgraded, scaled, or replaced without modifying the control plane.

### Health checking

The gateway exposes:

```text
15021/healthz/ready
```

which matches the health check configured on the dedicated ALB target group.

## 📖 Next Steps

After deploying this module:

1. Verify the gateway Deployment.
2. Verify the ClusterIP Service.
3. Confirm ports 80, 443, and 15021.
4. Create the TargetGroupBinding module.
5. Bind the gateway Service to the dedicated Istio target group.
6. Confirm gateway pod IPs register as healthy targets.
7. Update the existing HTTPS listener to forward traffic to Istio.