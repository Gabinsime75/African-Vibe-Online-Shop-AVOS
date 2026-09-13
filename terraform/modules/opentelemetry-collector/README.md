# OpenTelemetry Collector Terraform Module

## Overview

This Terraform module deploys the OpenTelemetry Collector into the CloudHustler Commerce Platform using the official OpenTelemetry Helm chart.

The Collector provides a vendor-neutral telemetry pipeline for application metrics and distributed traces. Applications send telemetry using the OpenTelemetry Protocol, commonly called OTLP, and the Collector receives, enriches, processes, and exports that data to the configured observability backends.

Fluent Bit remains responsible for collecting Kubernetes container logs. The OpenTelemetry Collector focuses primarily on application metrics and distributed traces.

---

# Architecture

```text
Application Pods
      │
      ├── OTLP gRPC :4317
      └── OTLP HTTP :4318
              │
              ▼
OpenTelemetry Collector
              │
              ├── Memory Limiter
              ├── Kubernetes Metadata Enrichment
              ├── Resource Attribute Enrichment
              └── Batch Processing
                      │
          ┌───────────┴───────────┐
          │                       │
          ▼                       ▼
Prometheus Exporter          Trace Exporter
    :8889                   Debug or AWS X-Ray
          │                       │
          ▼                       ▼
     Prometheus                AWS X-Ray
          │
          ▼
       Grafana
```

---

# Purpose in the Project

The OpenTelemetry Collector provides the distributed telemetry pipeline for the CloudHustler Commerce Platform.

It enables future application services to send telemetry using a consistent vendor-neutral protocol without integrating directly with individual monitoring backends.

The Collector provides:

- OTLP telemetry ingestion
- Kubernetes metadata enrichment
- Application metrics export
- Distributed trace processing
- Optional AWS X-Ray integration
- Collector health monitoring
- Prometheus operational metrics
- Centralized telemetry routing

---

# Module Structure

```text
modules/opentelemetry-collector/
├── main.tf
├── iam.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

# Deployment Mode

The Collector is deployed using:

```hcl
mode = "deployment"
```

A Kubernetes Deployment provides a stable centralized OTLP gateway for application telemetry.

This approach is appropriate because application services send telemetry to one internal Kubernetes Service rather than requiring one Collector pod on every worker node.

The Collector can later be scaled horizontally using additional replicas or a Horizontal Pod Autoscaler.

---

# Telemetry Responsibilities

## Metrics

Applications send metrics through OTLP:

```text
Application
    │
    ▼
OpenTelemetry Collector
    │
    ▼
Prometheus Exporter
    │
    ▼
Prometheus
    │
    ▼
Grafana
```

The Collector exposes received application metrics on:

```text
http://opentelemetry-collector.observability.svc.cluster.local:8889/metrics
```

Prometheus scrapes this endpoint.

## Traces

Applications send distributed traces through OTLP:

```text
Application
    │
    ▼
OpenTelemetry Collector
    │
    ├── Debug Exporter
    └── AWS X-Ray Exporter
```

When AWS X-Ray is disabled, traces are written to the Collector logs through the debug exporter.

When AWS X-Ray is enabled, traces are exported using EKS Pod Identity.

## Logs

Kubernetes container logs continue to use:

```text
Application stdout/stderr
        │
        ▼
Fluent Bit
        │
        ▼
Loki
        │
        ▼
Grafana
```

This avoids duplicating log collection responsibilities.

---

# OTLP Endpoints

The module exposes two OpenTelemetry Protocol endpoints.

## OTLP over gRPC

```text
opentelemetry-collector.observability.svc.cluster.local:4317
```

Application environment variable:

```text
OTEL_EXPORTER_OTLP_ENDPOINT=http://opentelemetry-collector.observability.svc.cluster.local:4317
```

## OTLP over HTTP

```text
http://opentelemetry-collector.observability.svc.cluster.local:4318
```

Trace endpoint:

```text
http://opentelemetry-collector.observability.svc.cluster.local:4318/v1/traces
```

Metrics endpoint:

```text
http://opentelemetry-collector.observability.svc.cluster.local:4318/v1/metrics
```

---

# Collector Pipeline

The Collector uses the following pipeline:

```text
Receiver
   │
   ▼
Memory Limiter
   │
   ▼
Kubernetes Attributes Processor
   │
   ▼
Resource Processor
   │
   ▼
Batch Processor
   │
   ▼
Exporter
```

## OTLP Receiver

Receives metrics and traces over:

- gRPC port `4317`
- HTTP port `4318`

## Memory Limiter

Protects the Collector from excessive memory usage.

Default configuration:

```text
Limit: 80%
Spike limit: 25%
Check interval: 5s
```

## Kubernetes Attributes Processor

Adds Kubernetes metadata to telemetry.

Examples include:

- Namespace
- Pod name
- Pod UID
- Deployment name
- StatefulSet name
- DaemonSet name
- Node name
- Container name
- Application labels
- Environment labels

## Resource Processor

Adds platform-level metadata.

Examples:

```text
cloud.provider = aws
cloud.platform = aws_eks
cloud.region = us-east-2
k8s.cluster.name = cloudhusller-commerce-platform-dev-eks
deployment.environment.name = dev
```

## Batch Processor

Groups telemetry before export to improve performance and reduce backend requests.

---

# Prometheus Integration

The Collector exposes two categories of metrics.

## Application Metrics

Metrics received through OTLP are exposed through the Prometheus exporter:

```text
Port: 8889
Path: /metrics
```

## Collector Operational Metrics

The Collector exposes its own internal telemetry:

```text
Port: 8888
Path: /metrics
```

Operational metrics include:

- Received spans
- Exported spans
- Failed exports
- Receiver errors
- Export queue size
- Memory usage
- Processor performance
- Dropped telemetry

A Prometheus ServiceMonitor is enabled by default.

---

# AWS X-Ray Integration

AWS X-Ray export is optional.

Enable it using:

```hcl
aws_xray_enabled = true
```

When enabled, the module creates:

- IAM role
- IAM policy
- Policy attachment
- EKS Pod Identity association

The Collector receives temporary AWS credentials through EKS Pod Identity.

No static access keys are stored in Kubernetes.

Required AWS permissions:

```text
xray:PutTraceSegments
xray:PutTelemetryRecords
```

When X-Ray is disabled, the Collector uses the debug exporter.

---

# IAM Resources

The optional `iam.tf` file creates IAM resources only when:

```hcl
aws_xray_enabled = true
```

When disabled:

```text
IAM Role: Not created
IAM Policy: Not created
Pod Identity Association: Not created
Trace Exporter: Debug
```

When enabled:

```text
IAM Role: Created
IAM Policy: Created
Pod Identity Association: Created
Trace Exporter: AWS X-Ray
```

---

# Kubernetes Namespace

The default namespace is:

```text
observability
```

The module can create the namespace:

```hcl
create_namespace = true
```

This separates telemetry services from:

- `monitoring`
- `logging`
- `istio-system`
- `kube-system`

---

# Service Account

The default service account is:

```text
opentelemetry-collector
```

The service account is used by:

- Kubernetes API authentication
- Kubernetes metadata enrichment
- EKS Pod Identity
- AWS X-Ray export

---

# Kubernetes Permissions

The Collector creates a ClusterRole that permits read-only access to Kubernetes metadata.

Resources include:

```text
pods
namespaces
nodes
replicasets
deployments
statefulsets
daemonsets
jobs
cronjobs
```

Allowed operations:

```text
get
list
watch
```

The Collector does not modify Kubernetes workloads.

---

# Resource Configuration

Default Collector resources:

| Setting | Value |
|---|---:|
| CPU request | 100m |
| Memory request | 256Mi |
| CPU limit | 500m |
| Memory limit | 512Mi |

These values are suitable for the current development environment.

Production values should be based on:

- Span ingestion rate
- Metric volume
- Export latency
- Number of application services
- Batch size
- Backend performance

---

# Autoscaling

Horizontal Pod Autoscaling is disabled by default:

```hcl
autoscaling_enabled = false
```

It can be enabled using:

```hcl
autoscaling_enabled      = true
autoscaling_min_replicas = 2
autoscaling_max_replicas = 5
autoscaling_cpu_target   = 70
```

Production deployments should generally use at least two Collector replicas.

---

# Health and Diagnostics

## Health Endpoint

```text
http://opentelemetry-collector.observability.svc.cluster.local:13133/
```

## zPages

zPages is enabled by default:

```text
http://opentelemetry-collector.observability.svc.cluster.local:55679/debug/servicez
```

zPages provides internal diagnostic information for:

- Collector services
- Pipelines
- Receivers
- Exporters
- Span processing

zPages should remain internal and should not be exposed publicly.

---

# Example Module Usage

```hcl
module "opentelemetry_collector" {
  source = "../modules/opentelemetry-collector"

  project_name = "cloudhusller-commerce-platform"
  environment  = "dev"
  cluster_name = "cloudhusller-commerce-platform-dev-eks"
  aws_region   = "us-east-2"

  namespace        = "observability"
  create_namespace = true

  release_name  = "opentelemetry-collector"
  chart_version = "REPLACE_WITH_PINNED_VERSION"

  image_repository = "otel/opentelemetry-collector-contrib"
  image_tag        = "REPLACE_WITH_PINNED_VERSION"

  replica_count       = 1
  service_account_name = "opentelemetry-collector"

  aws_xray_enabled = false

  iam_role_name = "cloudhusller-commerce-platform-dev-otel-xray-role"

  iam_policy_name = "cloudhusller-commerce-platform-dev-otel-xray-policy"

  service_monitor_enabled = true
  prometheus_release_name = "kube-prometheus-stack"

  cpu_request    = "100m"
  memory_request = "256Mi"
  cpu_limit      = "500m"
  memory_limit   = "512Mi"
}
```

---

# Application Configuration

Applications should configure the Collector endpoint using environment variables.

Example:

```yaml
env:
  - name: OTEL_SERVICE_NAME
    value: product-service

  - name: OTEL_EXPORTER_OTLP_ENDPOINT
    value: http://opentelemetry-collector.observability.svc.cluster.local:4317

  - name: OTEL_EXPORTER_OTLP_PROTOCOL
    value: grpc

  - name: OTEL_RESOURCE_ATTRIBUTES
    value: deployment.environment.name=dev
```

Application code must also include the appropriate OpenTelemetry SDK or auto-instrumentation package.

---

# Validation

## Verify the namespace

```bash
kubectl get namespace observability
```

## Verify the Helm release

```bash
helm list -n observability
```

Expected:

```text
opentelemetry-collector   observability   deployed
```

## Verify the deployment

```bash
kubectl get deployment -n observability
```

## Verify the pod

```bash
kubectl get pods -n observability -o wide
```

Expected:

```text
1/1 Running
```

## Verify the service

```bash
kubectl get service -n observability
```

Verify ports:

```text
4317
4318
8889
13133
55679
```

## Verify Collector logs

```bash
kubectl logs \
  -n observability \
  deployment/opentelemetry-collector \
  --tail=100
```

Check for:

- Collector configuration loaded
- OTLP receiver started
- Prometheus exporter started
- Health extension started
- Trace exporter started
- No pipeline errors

## Verify ServiceMonitor

```bash
kubectl get servicemonitor -A | grep opentelemetry
```

## Verify health

```bash
kubectl port-forward \
  -n observability \
  service/opentelemetry-collector \
  13133:13133
```

Then:

```bash
curl http://localhost:13133/
```

Expected:

```text
Server available
```

## Verify Prometheus exporter

```bash
kubectl port-forward \
  -n observability \
  service/opentelemetry-collector \
  8889:8889
```

Then:

```bash
curl http://localhost:8889/metrics
```

---

# AWS X-Ray Validation

When X-Ray export is enabled, verify the Pod Identity association:

```bash
aws eks list-pod-identity-associations \
  --region us-east-2 \
  --cluster-name cloudhusller-commerce-platform-dev-eks
```

Verify the IAM role:

```bash
aws iam get-role \
  --role-name cloudhusller-commerce-platform-dev-otel-xray-role
```

Verify Collector logs:

```bash
kubectl logs \
  -n observability \
  deployment/opentelemetry-collector \
  | grep -i xray
```

Then verify traces in the AWS X-Ray console.

---

# Troubleshooting

## Collector Pod CrashLoopBackOff

Inspect the logs:

```bash
kubectl logs \
  -n observability \
  deployment/opentelemetry-collector \
  --previous
```

Common causes:

- Invalid receiver name
- Unsupported exporter
- Incorrect Collector image
- Invalid YAML configuration
- Incorrect pipeline references
- Unsupported chart value

## OTLP Connection Refused

Verify the service:

```bash
kubectl get svc -n observability
```

Verify endpoints:

```bash
kubectl get endpointslice -n observability
```

Test DNS:

```bash
kubectl run otel-test \
  --image=curlimages/curl \
  --restart=Never \
  --rm -it \
  -- \
  curl http://opentelemetry-collector.observability.svc.cluster.local:13133/
```

## Prometheus Does Not Discover the Collector

Verify the ServiceMonitor:

```bash
kubectl get servicemonitor -A | grep opentelemetry
```

Verify its labels:

```bash
kubectl get servicemonitor \
  -n observability \
  -o yaml
```

Ensure it includes:

```yaml
release: kube-prometheus-stack
```

## AWS X-Ray AccessDenied

Check the Collector logs:

```bash
kubectl logs \
  -n observability \
  deployment/opentelemetry-collector \
  | grep -i -E "xray|accessdenied|credential"
```

Verify:

- Pod Identity association
- IAM trust policy
- IAM role attachment
- X-Ray write permissions
- Correct Kubernetes service account
- Correct namespace

## Kubernetes Metadata Missing

Verify the Collector ClusterRole:

```bash
kubectl get clusterrole | grep opentelemetry
```

Inspect permissions:

```bash
kubectl describe clusterrole <collector-clusterrole-name>
```

Verify the `k8sattributes` processor is included in both pipelines.

---

# Security Considerations

- Keep OTLP endpoints internal to the cluster.
- Use ClusterIP rather than LoadBalancer.
- Do not expose zPages publicly.
- Use EKS Pod Identity for AWS access.
- Do not store AWS credentials in Kubernetes Secrets.
- Run the Collector as a non-root user.
- Drop all Linux capabilities.
- Use a read-only root filesystem.
- Limit Kubernetes permissions to read-only access.
- Restrict namespace access where possible.

---

# Production Enhancements

Before production deployment, consider:

- Multiple Collector replicas
- Horizontal Pod Autoscaling
- PodDisruptionBudget
- Topology spread constraints
- Queue retry configuration
- Persistent sending queues
- TLS for OTLP
- Authentication for OTLP receivers
- NetworkPolicy restrictions
- Dedicated gateway and agent Collectors
- Tail-based sampling
- Trace sampling policies
- Grafana Tempo integration
- AWS X-Ray trace validation
- Alerting on dropped telemetry
- Alerting on export failures
- Collector capacity dashboards

---

# Future Architecture

A production environment may use two Collector tiers:

```text
Application Pods
      │
      ▼
Node-level Collector Agents
      │
      ▼
Central Collector Gateway
      │
      ├── Prometheus
      ├── Grafana Tempo
      ├── AWS X-Ray
      └── Additional Backends
```

The current Deployment provides the central gateway layer.

---

# CloudHustler Commerce Platform

**Project:** CloudHustler Commerce Platform  
**Phase:** Platform Services  
**Component:** OpenTelemetry Collector  
**Managed By:** Terraform  
**Environment:** Development