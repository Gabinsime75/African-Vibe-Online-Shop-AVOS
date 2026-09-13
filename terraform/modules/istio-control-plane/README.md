# Istio Control Plane Module

## 🚀 Overview

This module installs the Istio service-mesh control plane into an existing Kubernetes cluster using the official Istio Helm charts.

It installs:

1. The `istio/base` chart, which provides Istio Custom Resource Definitions and cluster-scoped foundation resources.
2. The `istio/istiod` chart, which deploys the Istio control plane.

The Istio ingress gateway is intentionally excluded from this module and will be deployed independently.

## 🎯 Purpose

The purpose of this module is to provide the control-plane foundation for the CloudHustler Commerce Platform service mesh.

Istiod provides:

- xDS configuration distribution
- Service discovery
- Workload identity
- mTLS certificate issuance
- Sidecar injection
- Gateway configuration
- Traffic-management configuration
- Authorization-policy distribution
- Telemetry configuration

## 🏗 Architecture

```text
Amazon EKS Cluster
│
├── istio-system
│   ├── Istio CRDs
│   └── Istiod
│       ├── Service discovery
│       ├── xDS configuration
│       ├── Workload certificates
│       ├── Injection configuration
│       └── Policy distribution
│
├── Istio Ingress Gateway       Deployed separately
│
└── Commerce Microservices
    └── Envoy sidecars
```

## 🚀 Features

- Installs official Istio Helm charts
- Installs Istio CRDs before Istiod
- Pins both charts to the same Istio version
- Supports multiple Istiod replicas
- Supports Horizontal Pod Autoscaling
- Enables Kubernetes Gateway API support
- Supports revision-based upgrades
- Enables mesh access logs
- Enables distributed tracing
- Configures sidecar resource defaults
- Supports strict outbound traffic registration
- Supports additional Helm values
- Protects the Istio base release from accidental destruction

## 📦 Resources Created

Terraform creates:

- `helm_release.base`
- `helm_release.istiod`

The Helm charts create Kubernetes resources including:

- Istio Custom Resource Definitions
- ClusterRoles and ClusterRoleBindings
- ServiceAccounts
- Istiod Deployment
- Istiod Service
- MutatingWebhookConfiguration
- ValidatingWebhookConfiguration
- HorizontalPodAutoscaler
- ConfigMaps
- PodDisruptionBudget, depending on chart configuration

## 📁 Module Structure

```text
modules/istio-control-plane/
├── helm.tf
├── variables.tf
├── outputs.tf
└── README.md
```

## 📥 Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `chart_repository` | Official Istio Helm repository | `string` | Official repository URL |
| `chart_version` | Pinned Istio version | `string` | `1.30.1` |
| `namespace` | Istio control-plane namespace | `string` | `istio-system` |
| `revision` | Control-plane revision | `string` | `default` |
| `enable_autoscaling` | Enable Istiod autoscaling | `bool` | `true` |
| `autoscale_min_replicas` | Minimum Istiod replicas | `number` | `2` |
| `autoscale_max_replicas` | Maximum Istiod replicas | `number` | `5` |
| `autoscaling_cpu_target_percentage` | HPA CPU target | `number` | `80` |
| `enable_gateway_api` | Enable Kubernetes Gateway API | `bool` | `true` |
| `enable_native_sidecars` | Enable native sidecar support | `bool` | `true` |
| `enable_tracing` | Enable distributed tracing | `bool` | `true` |
| `tracing_sampling_percentage` | Trace sampling percentage | `number` | `1.0` |
| `enable_access_logging` | Enable proxy access logs | `bool` | `true` |
| `access_log_encoding` | Access-log encoding | `string` | `JSON` |
| `outbound_traffic_policy_mode` | Unregistered outbound traffic policy | `string` | `REGISTRY_ONLY` |
| `additional_base_values` | Additional base-chart YAML values | `list(string)` | `[]` |
| `additional_istiod_values` | Additional Istiod YAML values | `list(string)` | `[]` |

## 📤 Outputs

| Name | Description |
|---|---|
| `base_release_name` | Istio base Helm release |
| `base_release_namespace` | Istio base namespace |
| `base_release_status` | Istio base release status |
| `istiod_release_name` | Istiod Helm release |
| `istiod_release_namespace` | Istiod namespace |
| `istiod_release_status` | Istiod release status |
| `chart_version` | Installed Istio chart version |
| `revision` | Istio control-plane revision |
| `namespace` | Istio system namespace |

## 💻 Example Usage

```hcl
module "istio_control_plane" {
  source = "../modules/istio-control-plane"

  chart_version = "1.30.1"
  namespace     = "istio-system"

  enable_autoscaling      = true
  autoscale_min_replicas  = 2
  autoscale_max_replicas  = 5

  enable_gateway_api     = true
  enable_native_sidecars = true

  enable_tracing                = true
  tracing_sampling_percentage   = 1.0
  enable_access_logging         = true
  access_log_encoding           = "JSON"

  outbound_traffic_policy_mode = "REGISTRY_ONLY"
}
```

## 🔒 Security Considerations

The Istio control plane is installed in the dedicated `istio-system` namespace.

The module supports a restrictive `REGISTRY_ONLY` outbound policy. With this setting, external destinations should be explicitly represented through Istio `ServiceEntry` resources.

Istio workload identity uses the configured trust domain, which defaults to `cluster.local`.

Istiod should not be exposed publicly.

The ingress gateway is deployed separately so that its lifecycle, scaling, network exposure, service ports, and ALB integration can be managed independently.

The base Helm release has Terraform lifecycle protection because deleting Istio CRDs can impact all mesh configuration resources.

## 💡 Design Decisions

### Separate base and Istiod releases

Istio requires its base CRDs and cluster-scoped resources before the control plane is installed.

### Separate ingress gateway module

The ingress gateway has a different lifecycle from Istiod. It requires independent scaling, security settings, service ports, readiness checks, and TargetGroupBinding integration.

### Autoscaling

Istiod runs with at least two replicas and can scale horizontally based on CPU utilization.

### Revision support

The module accepts a control-plane revision to support future canary upgrades.

### Gateway API

Kubernetes Gateway API support is enabled because it is the strategic Kubernetes-native direction for gateway and routing configuration.

### Outbound traffic

`REGISTRY_ONLY` is the default to prevent uncontrolled outbound traffic from mesh workloads. External dependencies must be declared explicitly.

## 📖 Next Steps

After deploying this module:

1. Verify that the Istio CRDs exist.
2. Verify that Istiod is available.
3. Verify the validating and mutating webhooks.
4. Create the Istio ingress gateway module.
5. Deploy the Istio ingress gateway.
6. Create the TargetGroupBinding.
7. Verify the dedicated ALB target-group health.
8. Configure mesh-wide mTLS and authorization policies.