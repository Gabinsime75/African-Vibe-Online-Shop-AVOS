# Kiali Terraform Module

## Overview

This Terraform module deploys **Kiali** into the Amazon EKS cluster using the official Kiali Server Helm chart.

Kiali provides the observability and management interface for the Istio service mesh. It connects to the existing Prometheus and Grafana deployments to visualize service-to-service traffic, request rates, error rates, latency, mesh health, mTLS status, and Istio configuration.

This module is part of Phase 6 of the CloudHustler Commerce Platform.

---

# Architecture

```text
Application Pods
      │
      ▼
Istio Sidecars and Gateways
      │
      ▼
Prometheus Metrics
      │
      ▼
Kiali
      │
      ├── Traffic Graph
      ├── Request Rates
      ├── Error Rates
      ├── Latency
      ├── mTLS Status
      └── Istio Configuration Validation
```

Grafana remains available for deeper dashboard analysis:

```text
Kiali
  │
  └── Grafana dashboard links
```

---

# Features

* Official Kiali Server Helm chart
* Terraform-managed Helm deployment
* Existing `istio-system` namespace reuse
* Prometheus integration
* Grafana integration
* Istio namespace discovery
* Internal ClusterIP service
* Configurable authentication
* Configurable resource requests and limits
* Configurable node scheduling
* Kiali Prometheus metrics
* Support for future tracing integration

---

# Module Structure

```text
modules/kiali/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

# Deployment Location

By default, Kiali is deployed into:

```text
istio-system
```

The namespace is normally created and managed by the Istio control-plane module.

The Kiali module therefore uses:

```hcl
create_namespace = false
```

This prevents multiple Terraform modules from attempting to manage the same namespace.

---

# Dependencies

Kiali should be deployed after:

* Amazon EKS
* Istio Base
* Istiod
* Istio Ingress Gateway
* Prometheus
* Grafana
* Istio ServiceMonitor
* Istio Ingress PodMonitor

Recommended Terraform dependency:

```hcl
depends_on = [
  module.istio_control_plane,
  module.istio_ingress_gateway,
  module.prometheus
]
```

---

# Prometheus Integration

Kiali uses Prometheus as its primary metrics source.

The expected internal Prometheus URL is:

```text
http://kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090
```

Prometheus provides Kiali with:

* Istio request metrics
* Request duration metrics
* Response-code metrics
* Workload health information
* Control-plane metrics
* Gateway metrics

Without Prometheus, Kiali can inspect Istio configuration but cannot provide complete traffic graphs and health information.

---

# Grafana Integration

Kiali connects to the existing Grafana deployment using the internal service URL:

```text
http://kube-prometheus-stack-grafana.monitoring.svc.cluster.local
```

This integration allows users to navigate from Kiali metric views to Grafana dashboards for deeper analysis.

The Grafana integration can be disabled using:

```hcl
grafana_enabled = false
```

---

# Authentication

The development environment initially uses:

```hcl
auth_strategy = "anonymous"
```

Anonymous access is acceptable only while Kiali remains internal to the cluster.

For staging or production, use a supported identity provider such as OpenID Connect.

Kiali should not be exposed publicly with anonymous authentication enabled.

---

# Service Exposure

Kiali is deployed using:

```hcl
service_type = "ClusterIP"
```

This keeps the service internal to Kubernetes.

Initial access can be provided with port forwarding:

```bash
kubectl port-forward \
  -n istio-system \
  service/kiali \
  20001:20001
```

Then open:

```text
http://localhost:20001
```

Future external access should use the existing Istio ingress architecture:

```text
ALB
  │
  ▼
Istio Ingress Gateway
  │
  ▼
Kiali VirtualService
  │
  ▼
Kiali Service
```

A separate Kubernetes Ingress or public LoadBalancer is not required.

---

# Tracing Integration

Tracing integration is initially disabled:

```hcl
tracing_enabled = false
```

It will be enabled after the OpenTelemetry Collector and a compatible trace backend are available.

Once tracing is configured, Kiali can link service-mesh traffic to distributed traces.

---

# Example Usage

```hcl
module "kiali" {
  source = "../modules/kiali"

  project_name = "cloudhusller-commerce-platform"
  environment  = "dev"
  cluster_name = "cloudhusller-commerce-platform-dev-eks"

  namespace        = "istio-system"
  create_namespace = false

  release_name  = "kiali"
  chart_version = "REPLACE_WITH_PINNED_VERSION"

  auth_strategy = "anonymous"
  replica_count = 1

  accessible_namespaces = [
    "**"
  ]

  istio_namespace = "istio-system"

  prometheus_url = "http://kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090"

  grafana_enabled        = true
  grafana_in_cluster_url = "http://kube-prometheus-stack-grafana.monitoring.svc.cluster.local"
  grafana_external_url   = ""

  tracing_enabled = false

  service_type = "ClusterIP"

  cpu_request    = "100m"
  memory_request = "128Mi"
  cpu_limit      = "500m"
  memory_limit   = "512Mi"
}
```

---

# Validation

## Verify the Helm release

```bash
helm list -n istio-system
```

Expected result:

```text
kiali   istio-system   deployed
```

## Verify the deployment

```bash
kubectl get deployment -n istio-system kiali
```

Expected result:

```text
READY   UP-TO-DATE   AVAILABLE
1/1     1            1
```

## Verify the pod

```bash
kubectl get pods -n istio-system \
  -l app.kubernetes.io/name=kiali
```

Expected result:

```text
1/1 Running
```

## Verify the service

```bash
kubectl get service -n istio-system kiali
```

Expected service type:

```text
ClusterIP
```

## Check logs

```bash
kubectl logs \
  -n istio-system \
  deployment/kiali \
  --tail=100
```

Check for:

* Successful Kubernetes API connection
* Successful Prometheus connection
* Successful Istio discovery
* No authentication errors
* No configuration validation errors

---

# Prometheus Validation

Port-forward Kiali:

```bash
kubectl port-forward \
  -n istio-system \
  service/kiali \
  20001:20001
```

Open:

```text
http://localhost:20001
```

Validate:

* Applications are visible
* Workloads are visible
* Services are visible
* Traffic graph loads
* Istio control-plane health is available
* Metrics are displayed
* Istio configuration is detected

Traffic graphs require active traffic between mesh workloads.

---

# Troubleshooting

## Kiali shows no traffic

Verify Istio metrics are reaching Prometheus:

```bash
kubectl get servicemonitor -n monitoring
kubectl get podmonitor -n monitoring
```

Run a PromQL query:

```promql
istio_requests_total
```

If no data is returned, the issue is with Istio telemetry collection rather than Kiali.

---

## Prometheus connection failure

Verify the Prometheus service:

```bash
kubectl get service -n monitoring \
  kube-prometheus-stack-prometheus
```

Test connectivity from inside the cluster:

```bash
kubectl run prometheus-test \
  --image=curlimages/curl \
  --restart=Never \
  --rm -it \
  -- \
  curl -I \
  http://kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090
```

---

## Kiali pod remains Pending

Inspect scheduling events:

```bash
kubectl describe pod \
  -n istio-system \
  -l app.kubernetes.io/name=kiali
```

Check for:

* Too many pods
* Insufficient CPU
* Insufficient memory
* Node affinity conflicts
* Taints without matching tolerations

---

## Kiali cannot access namespaces

Verify:

```hcl
accessible_namespaces = [
  "**"
]
```

Also inspect the Kiali ClusterRole and ClusterRoleBinding:

```bash
kubectl get clusterrole | grep kiali
kubectl get clusterrolebinding | grep kiali
```

---

# Terraform Outputs

The module exports:

* Helm release name
* Helm release status
* Chart name
* Chart version
* Namespace
* Namespace management status
* Service name
* Service type
* Internal Kiali URL
* Prometheus URL
* Grafana URL
* Authentication strategy
* Replica count
* Tracing status
* Metrics status
* Accessible namespaces

---

# Production Enhancements

Before using Kiali in production, implement:

* OpenID Connect authentication
* TLS through Istio Gateway
* Restricted namespace access
* Multiple replicas
* PodDisruptionBudget
* Topology spread constraints
* Resource tuning
* Network policies
* External URL configuration
* Distributed tracing integration
* Backup and configuration recovery procedures

---

# CloudHustler Commerce Platform

**Project:** CloudHustler Commerce Platform
**Phase:** Platform Services
**Component:** Kiali
**Managed By:** Terraform
**Environment:** Development
