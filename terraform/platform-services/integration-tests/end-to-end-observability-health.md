# End-to-End Observability Health

## Purpose

The End-to-End Observability Health test validates the complete observability architecture of the CloudHustler Commerce Platform.

The objective is not simply to verify that individual observability components are running. The goal is to prove that the platform can generate telemetry, collect it, process it, query it, visualize it, and generate operational alerts as one integrated observability system.

---

## End-to-End Observability Flow

```text
                         CLOUDHUSTLER APPLICATION
                                  │
                ┌─────────────────┼─────────────────┐
                │                 │                 │
              Metrics            Logs             Traces
                │                 │                 │
                ▼                 ▼                 ▼
          Prometheus         Fluent Bit      OpenTelemetry
                │                 │             Collector
                │                 ▼                 │
                │               Loki                │
                │                                   ▼
                │                            Trace Exporter
                │
        ┌───────┴────────┐
        │                │
        ▼                ▼
     Grafana           Kiali
                         ▲
                         │
                  Istio Telemetry


                PrometheusRule
                      │
                      ▼
                 Prometheus
                      │
                      ▼
                 Alertmanager
```

---

## Validation Matrix

| Layer | What We Prove | Expected Result |
|---|---|---|
| Kubernetes | Test workload healthy | Pods `Running/Ready` |
| Prometheus | Metrics collection works | Workload and cluster metrics returned |
| Loki | Log pipeline works | Test logs searchable |
| OpenTelemetry | OTLP pipeline works | `otelcol_receiver_accepted_* > 0` |
| Istio | Sidecar/data plane works | Workload has Envoy sidecar |
| Kiali | Mesh visibility works | Workload/service visible |
| Alerting | Rule evaluation works | Test alert reaches Alertmanager |
| Grafana | Unified visualization works | Prometheus + Loki queries succeed |

---

# 1. Kubernetes Workload Health

## Validation

The Kubernetes workloads supporting the observability platform were verified to be running and ready.

The validation confirms that the core monitoring, logging, telemetry, service mesh, visualization, and alerting components are operational inside the EKS cluster.

Example validation commands:

```bash
kubectl get pods -n monitoring
kubectl get pods -n logging
kubectl get pods -n observability
kubectl get pods -n istio-system
kubectl get pods -n istio-ingress
```

### Expected Result

```text
Pods = Running
Containers = Ready
Critical workloads = Healthy
```

**Result: ✅ PASS**

### Screenshot Evidence

> **Screenshot 1 – Kubernetes Observability Workload Health**
>
> Add screenshot showing the observability workloads in `Running/Ready` state.

<!--
SCREENSHOT PLACEHOLDER

Recommended evidence:
kubectl get pods -A
or individual monitoring/logging/observability namespace pod status.

![Kubernetes Workload Health](./screenshots/01-kubernetes-workload-health.png)
-->

---

# 2. Prometheus Metrics Ingestion

## Validation

Prometheus successfully discovers and scrapes monitoring targets across the platform.

Metrics from Kubernetes, Istio, and the OpenTelemetry Collector were successfully queried.

Example queries:

```promql
up{namespace="observability"}
```

```promql
up{job="opentelemetry-collector"}
```

Healthy targets returned:

```text
up = 1
```

This confirms that Prometheus service discovery, ServiceMonitor integration, and metric ingestion are operational.

**Result: ✅ PASS**

### Screenshot Evidence

> **Screenshot 2 – Prometheus Metrics Query**
>
> Add screenshot showing a successful Prometheus query returning healthy targets.

<!--
SCREENSHOT PLACEHOLDER

Recommended evidence:
Prometheus query showing up = 1.

![Prometheus Metrics Ingestion](./screenshots/02-prometheus-metrics.png)
-->

---

# 3. Loki Log Ingestion

## Validation

The centralized Kubernetes logging pipeline was validated through the following path:

```text
Kubernetes Pods
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

Fluent Bit collects container logs from Kubernetes nodes and forwards them to Loki.

Grafana Explore was then used to query Loki.

Example LogQL queries:

```logql
{namespace="kube-system"}
```

```logql
{namespace="monitoring"}
```

Logs were successfully returned with Kubernetes metadata including namespace, pod, container, node, and application information.

**Result: ✅ PASS**

### Screenshot Evidence

> **Screenshot 3 – Grafana Loki Log Query**
>
> Add screenshot showing Kubernetes logs returned through Grafana Explore using Loki.

<!--
SCREENSHOT PLACEHOLDER

Recommended evidence:
Grafana → Explore → Loki
Query: {namespace="monitoring"}

![Loki Log Ingestion](./screenshots/03-loki-log-ingestion.png)
-->

---

# 4. OpenTelemetry Collector Health

## Validation

The OpenTelemetry Collector was validated through its Kubernetes service and internal telemetry endpoint.

The Collector exposes internal metrics on:

```text
Port: 8888
Path: /metrics
```

Collector telemetry included:

```text
otelcol_receiver_accepted_spans
otelcol_receiver_failed_spans
otelcol_receiver_refused_spans
otelcol_exporter_sent_spans
otelcol_process_memory_rss
otelcol_process_uptime
```

Prometheus successfully discovered and scraped the Collector through its ServiceMonitor.

**Result: ✅ PASS**

### Screenshot Evidence

> **Screenshot 4 – OpenTelemetry Collector Metrics**
>
> Add screenshot showing `otelcol_*` metrics returned by Prometheus.

<!--
SCREENSHOT PLACEHOLDER

Recommended evidence:
Prometheus query for:
otelcol_receiver_accepted_spans

![OpenTelemetry Collector Metrics](./screenshots/04-opentelemetry-metrics.png)
-->

---

# 5. OTLP Trace Acceptance

## Validation

A test trace was submitted directly to the OpenTelemetry Collector using OTLP over HTTP.

The request was sent to:

```text
opentelemetry-collector.observability.svc.cluster.local:4318/v1/traces
```

The Collector returned:

```text
HTTP/1.1 200 OK

{"partialSuccess":{}}
```

Collector telemetry subsequently showed:

```text
otelcol_receiver_accepted_spans = 1
otelcol_receiver_failed_spans   = 0
otelcol_receiver_refused_spans  = 0
otelcol_exporter_sent_spans     = 1
```

This confirms successful OTLP trace reception and processing through the Collector pipeline.

```text
Test Trace
    │
    │ OTLP/HTTP :4318
    ▼
OpenTelemetry Collector
    │
    ├── Receiver
    ├── Processor
    └── Exporter
```

**Result: ✅ PASS**

### Screenshot Evidence

> **Screenshot 5 – OTLP Trace Integration Test**
>
> Add screenshot showing the `HTTP/1.1 200 OK` response from the OpenTelemetry Collector.

<!--
SCREENSHOT PLACEHOLDER

Recommended evidence:
Terminal showing OTLP POST request and HTTP 200 response.

![OTLP Trace Acceptance](./screenshots/05-otlp-trace-test.png)
-->

### Screenshot Evidence

> **Screenshot 6 – OTLP Metrics Confirmation**
>
> Add screenshot showing `otelcol_receiver_accepted_spans` or `otelcol_exporter_sent_spans` in Prometheus.

<!--
SCREENSHOT PLACEHOLDER

![OTLP Metrics Confirmation](./screenshots/06-otlp-prometheus-confirmation.png)
-->

---

# 6. Istio Control Plane and Data Plane Health

## Validation

Istio control-plane and ingress monitoring targets were successfully discovered by Prometheus.

Example queries:

```promql
up{namespace="istio-system"}
```

```promql
up{namespace="istio-ingress"}
```

A dedicated `istio-test` workload was also deployed with automatic Istio sidecar injection enabled.

The workload reported:

```text
READY 2/2
```

This confirms that both the application container and Envoy sidecar were running.

Traffic was successfully generated between test workloads inside the mesh.

```text
curl + Envoy
      │
      │ HTTP / mTLS
      ▼
httpbin + Envoy
```

Envoy was also confirmed to generate Istio request telemetry locally.

**Result: ✅ PASS**

### Screenshot Evidence

> **Screenshot 7 – Istio Prometheus Targets**
>
> Add screenshot showing healthy Istio targets in Prometheus.

<!--
SCREENSHOT PLACEHOLDER

Recommended evidence:
up{namespace="istio-system"}
or
up{namespace="istio-ingress"}

![Istio Prometheus Targets](./screenshots/07-istio-prometheus.png)
-->

### Screenshot Evidence

> **Screenshot 8 – Istio Sidecar Injection**
>
> Add screenshot showing the `httpbin` workload running `2/2`.

<!--
SCREENSHOT PLACEHOLDER

Recommended evidence:
kubectl get pods -n istio-test

![Istio Sidecar Injection](./screenshots/08-istio-sidecar.png)
-->

---

# 7. Kiali Mesh Visibility

## Validation

Kiali successfully connected to the Kubernetes cluster and Istio environment.

The Kiali dashboard discovered:

- Kubernetes cluster
- Istio control plane
- Istio data plane
- Applications
- Services
- Workloads
- Sidecar-enabled workloads

This confirms that Kiali can inspect the deployed Istio service mesh and provide centralized service-mesh visibility.

**Result: ✅ PASS**

### Screenshot Evidence

> **Screenshot 9 – Kiali Overview**
>
> Add screenshot showing the Kiali Overview page with the cluster, control plane, data plane, and application health.

<!--
SCREENSHOT PLACEHOLDER

![Kiali Mesh Overview](./screenshots/09-kiali-overview.png)
-->

---

# 8. PrometheusRule Evaluation

## Validation

A temporary integration-test `PrometheusRule` was deployed to validate rule discovery and evaluation.

The test alert was:

```text
CloudHustlerAlertingPipelineTest
```

Prometheus successfully loaded the rule under:

```text
cloudhusller.integration-test
```

The rule transitioned through the Prometheus alert lifecycle and reached:

```text
FIRING
```

This confirms that custom PrometheusRule resources are discovered and evaluated successfully.

```text
PrometheusRule
      │
      ▼
Prometheus Operator
      │
      ▼
Prometheus
      │
      ▼
Rule Evaluation
      │
      ▼
FIRING
```

**Result: ✅ PASS**

### Screenshot Evidence

> **Screenshot 10 – Prometheus Alert FIRING**
>
> Add screenshot showing `CloudHustlerAlertingPipelineTest` in the `FIRING` state.

<!--
SCREENSHOT PLACEHOLDER

![Prometheus Alert Firing](./screenshots/10-prometheus-alert-firing.png)
-->

---

# 9. Alertmanager Delivery

## Validation

The firing integration-test alert was successfully forwarded from Prometheus to Alertmanager.

Alertmanager received the expected alert:

```text
alertname="CloudHustlerAlertingPipelineTest"
component="observability"
environment="dev"
severity="warning"
```

This validates the complete core alerting path:

```text
PrometheusRule
      │
      ▼
Prometheus Operator
      │
      ▼
Prometheus
      │
      │ FIRING
      ▼
Alertmanager
      │
      ▼
Alert Received
```

**Result: ✅ PASS**

### Screenshot Evidence

> **Screenshot 11 – Alertmanager Alert Delivery**
>
> Add screenshot showing `CloudHustlerAlertingPipelineTest` received by Alertmanager.

<!--
SCREENSHOT PLACEHOLDER

![Alertmanager Alert Delivery](./screenshots/11-alertmanager-delivery.png)
-->

---

# 10. Grafana Datasource Connectivity

## Validation

Grafana was validated as the centralized visualization and exploration layer for the observability platform.

Successful queries against Prometheus and Loki confirmed datasource connectivity.

```text
Prometheus ─────────┐
                    │
                    ▼
                 Grafana
                    ▲
                    │
Loki ───────────────┘
```

Grafana can therefore provide centralized access to platform metrics and logs.

**Result: ✅ PASS**

### Screenshot Evidence

> **Screenshot 12 – Grafana Prometheus Datasource**
>
> Add screenshot showing a successful Prometheus query from Grafana.

<!--
SCREENSHOT PLACEHOLDER

![Grafana Prometheus](./screenshots/12-grafana-prometheus.png)
-->

### Screenshot Evidence

> **Screenshot 13 – Grafana Loki Datasource**
>
> Add screenshot showing a successful Loki query from Grafana Explore.

<!--
SCREENSHOT PLACEHOLDER

![Grafana Loki](./screenshots/13-grafana-loki.png)
-->

---

# Known Observation

During the Istio integration test, Envoy proxies were confirmed to generate request statistics locally, including `istio_requests_total`.

However, workload-level `istio_requests_total` was not successfully exposed through the current Prometheus workload scraping configuration.

As a result, Kiali discovered the mesh, workloads, applications, and health information, but its traffic graph did not display measurable workload traffic during the validation window.

This does not block the overall observability validation because the following were independently confirmed:

- Istio control-plane health
- Istio ingress health
- Envoy sidecar injection
- Workload-to-workload communication
- mTLS communication
- Envoy telemetry generation
- Prometheus monitoring
- Kiali cluster discovery
- Kiali control-plane discovery
- Kiali data-plane discovery

The workload-level Istio Prometheus scraping behavior is retained as a future observability enhancement.

---

# End-to-End Validation Results

| Component | Validation | Status |
|---|---|---|
| Kubernetes | Workload health | ✅ PASS |
| Prometheus | Metrics ingestion | ✅ PASS |
| Loki | Log ingestion | ✅ PASS |
| OpenTelemetry | Collector health | ✅ PASS |
| OTLP | Trace acceptance | ✅ PASS |
| Istio | Control/data-plane health | ✅ PASS |
| Kiali | Mesh visibility | ✅ PASS |
| PrometheusRule | Rule evaluation | ✅ PASS |
| Alertmanager | Alert delivery | ✅ PASS |
| Grafana | Datasource connectivity | ✅ PASS |

---

## Final Health Check

```text
Kubernetes workload health              ✅
Prometheus metrics ingestion            ✅
Loki log ingestion                      ✅
OpenTelemetry Collector health          ✅
OTLP trace acceptance                   ✅
Istio control/data-plane health         ✅
Kiali mesh visibility                   ✅
PrometheusRule evaluation               ✅
Alertmanager delivery                   ✅
Grafana datasource connectivity         ✅
------------------------------------------------
END-TO-END OBSERVABILITY HEALTH          ✅ PASS
```

---

# Final Result

The CloudHustler Commerce Platform observability stack successfully demonstrates an integrated operational telemetry pipeline covering:

- Metrics collection
- Centralized logging
- Distributed telemetry collection
- Kubernetes monitoring
- Service mesh observability
- Centralized visualization
- Alert evaluation
- Alert delivery

The validation demonstrates that the individual observability services are not simply deployed, but are integrated and functioning together as part of the CloudHustler Commerce Platform.

**END-TO-END OBSERVABILITY HEALTH: ✅ PASS**