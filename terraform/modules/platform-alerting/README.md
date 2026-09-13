# Platform Alerting Module

## Overview

The `platform-alerting` module deploys custom Prometheus alerting rules for the CloudHustler Commerce Platform.

It extends the existing `kube-prometheus-stack` deployment by creating `PrometheusRule` resources for:

- Kubernetes
- Prometheus
- Loki
- OpenTelemetry Collector
- Istio
- Application workloads

Terraform manages which rule groups are deployed, while the alert definitions themselves remain in standard YAML files under the `rules/` directory.

This keeps the design simple and maintainable:

```text
Terraform
    │
    ├── Controls deployment lifecycle
    └── Enables or disables rule groups

YAML
    │
    ├── Defines PromQL expressions
    ├── Defines thresholds
    ├── Defines alert durations
    ├── Defines severity
    └── Defines annotations
    