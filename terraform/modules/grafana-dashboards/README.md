# Grafana Dashboards Module

## Overview

This module provisions the standard Grafana dashboards used by the CloudHustler Commerce Platform.

Rather than storing dashboard definitions inside Terraform code, each dashboard is maintained as an individual JSON file and automatically imported into Grafana through the kube-prometheus-stack dashboard sidecar.

This approach follows production best practices by separating dashboard content from infrastructure code while allowing Terraform to manage the complete dashboard lifecycle.

---

# Architecture

```
Terraform
        │
        ▼
Dashboard JSON Files
        │
        ▼
Kubernetes ConfigMaps
        │
        ▼
Grafana Dashboard Sidecar
        │
        ▼
Grafana Dashboards
```

---

# Module Structure

```
grafana-dashboards/
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
└── dashboards/
    ├── kubernetes-cluster.json
    ├── kubernetes-nodes.json
    ├── prometheus-overview.json
    ├── istio-mesh.json
    ├── istio-workloads.json
    ├── loki-logs.json
    ├── opentelemetry.json
    └── cloudwatch.json
```

---

# Dashboards

## Kubernetes Cluster

Provides an overall view of the Kubernetes platform including:

- Cluster health
- API server availability
- Pod count
- Namespace utilization
- Resource usage
- Node status

---

## Kubernetes Nodes

Displays:

- CPU utilization
- Memory utilization
- Disk utilization
- Network throughput
- Node readiness
- Pod capacity

---

## Prometheus Overview

Displays:

- Scrape targets
- Active series
- Rule evaluation
- Storage utilization
- Alert status
- Query performance

---

## Istio Mesh

Displays:

- Request rate
- Request latency
- Error rate
- Service traffic
- Control plane health
- Sidecar metrics

---

## Istio Workloads

Displays:

- Workload traffic
- Success rate
- Request duration
- Workload health
- Namespace traffic
- Service communication

---

## Loki Logs

Displays:

- Log ingestion
- Log volume
- Error logs
- Warning logs
- Log rate
- Fluent Bit pipeline status

---

## OpenTelemetry Collector

Displays:

- OTLP requests
- Export success rate
- Export failures
- Processor throughput
- Receiver metrics
- Collector health

---

## CloudWatch

Displays:

- EKS metrics
- Application Load Balancer metrics
- EBS metrics
- EC2 metrics
- Network metrics
- AWS infrastructure health

---

# Grafana Sidecar

The dashboards are automatically imported through the kube-prometheus-stack Grafana dashboard sidecar.

Terraform creates one ConfigMap per dashboard.

Each ConfigMap includes:

- Dashboard JSON
- Discovery labels
- Metadata
- Platform annotations

The sidecar continuously watches for ConfigMaps labeled:

```
grafana_dashboard = "1"
```

No Grafana API credentials are required.

---

# Dashboard Organization

Dashboards are organized under the Grafana folder:

```
CloudHustler Platform
```

This keeps all platform dashboards separated from Grafana's built-in dashboards.

---

# Terraform Resources

This module creates:

- Kubernetes ConfigMaps
- Dashboard metadata
- Dashboard labels
- Dashboard annotations

No additional namespaces or Grafana deployments are created.

---

# Inputs

| Name | Description |
|------|-------------|
| project_name | Project name |
| environment | Deployment environment |
| namespace | Dashboard namespace |
| configmap_name_prefix | ConfigMap naming prefix |
| sidecar_label | Grafana discovery label |
| sidecar_label_value | Grafana discovery label value |
| dashboard_folder | Logical dashboard folder |

---

# Outputs

| Output | Description |
|---------|-------------|
| dashboard_files | Dashboard JSON files |
| dashboard_names | Dashboard names |
| dashboard_count | Number of dashboards |
| configmap_names | ConfigMap names |
| namespace | Dashboard namespace |

---

# Validation

Verify ConfigMaps:

```bash
kubectl get configmaps -n monitoring
```

Verify dashboard labels:

```bash
kubectl get configmaps -n monitoring --show-labels
```

Verify Grafana sidecar:

```bash
kubectl logs \
deployment/kube-prometheus-stack-grafana \
-c grafana-sc-dashboard \
-n monitoring
```

Verify dashboards are imported:

```bash
kubectl port-forward \
svc/kube-prometheus-stack-grafana \
3000:80 \
-n monitoring
```

Open:

```
http://localhost:3000
```

Navigate to:

```
Dashboards

↓

CloudHustler Platform
```

---

# Best Practices

- Store dashboards as JSON files.
- Keep one dashboard per ConfigMap.
- Version dashboards in Git.
- Import dashboards automatically through the Grafana sidecar.
- Keep Terraform focused on infrastructure rather than dashboard content.
- Validate dashboard imports after every deployment.
- Review dashboard performance after Prometheus upgrades.