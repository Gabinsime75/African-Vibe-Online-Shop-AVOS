# Grafana Loki Terraform Module

## Overview

This Terraform module deploys **Grafana Loki** into an Amazon EKS cluster using the official Grafana Helm chart.

Loki provides centralized log aggregation for the CloudHustler Commerce Platform by storing Kubernetes container logs collected by Fluent Bit. Grafana queries Loki to provide searchable application, infrastructure, and platform logs.

This implementation is designed for the **development environment** and uses the **SingleBinary** deployment mode with persistent Amazon EBS storage.

---

# Architecture

```
                    Kubernetes Cluster
                           │
                           │
                 Container stdout/stderr
                           │
                           ▼
                    Fluent Bit DaemonSet
                           │
                           │
                    HTTP Push API
                           │
                           ▼
                   Loki Gateway Service
                           │
                           ▼
                  Loki SingleBinary Pod
                           │
                           ▼
                 Persistent Volume (gp3)
                           │
                           ▼
                     Grafana Explore
```

---

# Features

- Official Grafana Loki Helm Chart
- Terraform managed deployment
- SingleBinary deployment mode
- Persistent EBS (gp3) storage
- Seven-day log retention
- Internal ClusterIP gateway
- Prometheus ServiceMonitor
- Loki Canary validation
- Grafana integration
- Fluent Bit integration
- Production-ready Terraform structure

---

# Module Structure

```
modules/loki/

├── README.md
├── main.tf
├── variables.tf
└── outputs.tf
```

---

# Deployment Mode

This module uses:

```
deploymentMode = "SingleBinary"
```

SingleBinary is recommended for development and smaller Kubernetes clusters because all Loki components run inside a single workload.

For production environments, Loki should migrate to:

- Simple Scalable Deployment
- Amazon S3 object storage
- Multiple replicas
- High Availability

---

# Storage

Current storage backend:

- Filesystem
- Amazon EBS (gp3)
- PersistentVolumeClaim

Default configuration:

| Setting | Value |
|---------|------|
| StorageClass | gp3 |
| Size | 20Gi |
| Access Mode | ReadWriteOnce |

---

# Log Flow

```
Application Pods

        │

stdout / stderr

        │

        ▼

Fluent Bit

        │

        ▼

Loki Gateway

        │

        ▼

Loki Storage

        │

        ▼

Grafana Explore
```

---

# Monitoring

The module automatically enables:

- Prometheus ServiceMonitor
- Loki metrics endpoint
- Loki Canary
- Helm release monitoring

Prometheus discovers Loki automatically through the ServiceMonitor.

---

# Validation

Verify the namespace:

```bash
kubectl get ns logging
```

Verify the deployment:

```bash
kubectl get pods -n logging
```

Expected:

```
loki-0
loki-gateway
loki-canary
```

Verify the services:

```bash
kubectl get svc -n logging
```

Verify the persistent volume:

```bash
kubectl get pvc -n logging
```

Verify Helm:

```bash
helm list -n logging
```

Verify ServiceMonitor:

```bash
kubectl get servicemonitor -A | grep loki
```

---

# Terraform Outputs

The module exports:

- Release name
- Namespace
- Release status
- Chart version
- Gateway URL
- Push endpoint
- Query endpoint
- Ready endpoint
- Storage configuration
- Monitoring configuration

---

# Dependencies

This module should be deployed after:

- Amazon EKS
- EBS CSI Driver
- Prometheus
- Fluent Bit

Terraform dependency:

```hcl
depends_on = [
  module.prometheus,
  module.fluent_bit
]
```

---

# Future Production Enhancements

When promoting the CloudHustler Commerce Platform to production, this module should be updated to include:

- Amazon S3 object storage
- High Availability deployment
- Multiple replicas
- Zone awareness
- Query caching
- Results cache
- Chunks cache
- Alertmanager integration
- Multi-tenant authentication
- Long-term retention
- Backup strategy

---

# References

Grafana Loki Documentation

https://grafana.com/docs/loki/

Grafana Helm Charts

https://github.com/grafana/helm-charts

Fluent Bit Loki Output

https://docs.fluentbit.io/manual/pipeline/outputs/loki

Prometheus Operator

https://prometheus-operator.dev/

---

# CloudHustler Commerce Platform

**Project:** CloudHustler Commerce Platform

**Component:** Platform Services

**Service:** Grafana Loki

**Managed By:** Terraform

**Environment:** Development