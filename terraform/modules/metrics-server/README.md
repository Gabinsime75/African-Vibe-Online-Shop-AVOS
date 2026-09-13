# Metrics Server Module

## 🚀 Overview

This module installs Kubernetes Metrics Server into an existing Kubernetes cluster using the official Helm chart.

Metrics Server collects CPU and memory usage from Kubernetes nodes and pods and exposes them through the Kubernetes resource metrics API.

## 🎯 Purpose

Metrics Server provides the resource metrics required by:

- `kubectl top nodes`
- `kubectl top pods`
- Horizontal Pod Autoscaler
- Vertical Pod Autoscaler recommendations
- Platform capacity and workload diagnostics

Metrics Server is not intended to replace Prometheus or a full observability platform.

## 🏗 Architecture

```text
Kubelets
   ↓
Metrics Server
   ↓
metrics.k8s.io APIService
   ↓
kubectl top / HPA
```

## 🚀 Features

- Installs the official Metrics Server Helm chart
- Supports high-availability replicas
- Creates the Kubernetes metrics APIService
- Creates required RBAC resources
- Creates a dedicated service account
- Supports pinned chart versions
- Supports additional Helm values
- Supports atomic Helm rollback

## 📦 Resources Created

Resources are created through the Helm chart and include:

- Deployment
- Service
- ServiceAccount
- ClusterRole
- ClusterRoleBinding
- APIService
- PodDisruptionBudget, depending on chart configuration

Terraform creates:

- `helm_release`

## 📁 Module Structure

```text
modules/metrics-server/
├── helm.tf
├── variables.tf
├── outputs.tf
└── README.md
```

## 📥 Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `release_name` | Helm release name | `string` | `metrics-server` |
| `namespace` | Kubernetes namespace | `string` | `kube-system` |
| `chart_repository` | Official chart repository | `string` | Official repository URL |
| `chart_name` | Helm chart name | `string` | `metrics-server` |
| `chart_version` | Pinned chart version | `string` | `3.13.1` |
| `replica_count` | Number of replicas | `number` | `2` |
| `create_api_service` | Create metrics APIService | `bool` | `true` |
| `create_rbac` | Create RBAC resources | `bool` | `true` |
| `create_service_account` | Create service account | `bool` | `true` |
| `service_account_name` | Service account name | `string` | `metrics-server` |
| `helm_timeout` | Helm timeout | `number` | `600` |
| `additional_set_values` | Additional set values | `map(string)` | `{}` |
| `values` | Raw YAML values | `list(string)` | `[]` |

## 📤 Outputs

| Name | Description |
|---|---|
| `release_name` | Helm release name |
| `release_namespace` | Helm release namespace |
| `release_status` | Helm release status |
| `chart_version` | Installed chart version |
| `service_account_name` | Metrics Server service account |

## 💻 Example Usage

```hcl
module "metrics_server" {
  source = "../modules/metrics-server"

  namespace     = "kube-system"
  replica_count = 2

  chart_version = "3.13.1"
}
```

## 🔒 Security Considerations

Metrics Server reads resource metrics from kubelets and exposes aggregated metrics through the Kubernetes API aggregation layer.

Do not enable `--kubelet-insecure-tls` in EKS unless there is a confirmed certificate-validation issue. EKS normally supports secure kubelet communication without this workaround.

Access to the metrics API is controlled through Kubernetes RBAC.

## 💡 Design Decisions

Metrics Server is installed separately from the EKS module because it is an in-cluster platform service with an independent lifecycle.

Two replicas are used for availability.

The official Kubernetes SIGs Helm chart is used instead of a third-party chart.

## 📖 Next Steps

After deployment:

1. Verify the Metrics Server deployment.
2. Verify the `metrics.k8s.io` APIService.
3. Run `kubectl top nodes`.
4. Run `kubectl top pods -A`.
5. Continue to the Istio control-plane module.