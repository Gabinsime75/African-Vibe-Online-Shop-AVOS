> **Screenshot 3.1:** NodePool and EC2NodeClass Ready

# 03 - Karpenter Provisioning Test Workload

## Purpose

The purpose of this validation is to verify that Karpenter can automatically provision and deprovision Kubernetes worker nodes in response to application demand.

This test validates the complete Karpenter provisioning lifecycle by deploying a workload that cannot be scheduled on the existing managed node group. Once Kubernetes marks the pods as unschedulable, Karpenter should provision a new EC2 instance, register it with the EKS cluster, schedule the workload, and later terminate the instance after the workload is removed.

This serves as the final validation that the CloudHustler Commerce Platform is capable of dynamic, event-driven infrastructure scaling.

---

# Architecture Flow

```
                Deploy Test Workload
                        │
                        ▼
              Pods Become Pending
                        │
                        ▼
            Kubernetes Scheduler
                        │
        No Existing Node Can Run Pod
                        │
                        ▼
             Karpenter Controller
                        │
                        ▼
               Evaluate NodePool
                        │
                        ▼
             Resolve EC2NodeClass
                        │
                        ▼
             Create NodeClaim
                        │
                        ▼
          Launch EC2 Instance (AWS)
                        │
                        ▼
           Node Joins EKS Cluster
                        │
                        ▼
          Pods Scheduled Successfully
                        │
                        ▼
          Delete Test Deployment
                        │
                        ▼
             Node Becomes Empty
                        │
                        ▼
        Karpenter Consolidation Engine
                        │
                        ▼
          Terminate EC2 Instance
```

---

# Prerequisites

Before beginning the provisioning test, verify the following components are healthy.

- Karpenter Controller
- EC2NodeClass
- NodePool
- EKS Cluster
- Existing Managed Node Group

---

# Step 1 - Verify Karpenter Components

## Verify EC2NodeClass

```bash
kubectl get ec2nodeclass
```

Expected Output

```
NAME      READY
default   True
```

📷 **Screenshot 03-01** – EC2NodeClass Ready

---

## Verify NodePool

```bash
kubectl get nodepool
```

Expected Output

```
NAME      READY
default   True
```

📷 **Screenshot 03-02** – NodePool Ready

---

## Verify Existing Nodes

```bash
kubectl get nodes -o wide
```

Expected Output

The cluster should only contain the original managed node group.

📷 **Screenshot 03-03** – Existing Worker Nodes

---

## Verify NodeClaims

```bash
kubectl get nodeclaims
```

Expected Output

```
No resources found
```

No Karpenter nodes should exist before the workload is deployed.

📷 **Screenshot 03-04** – No Existing NodeClaims

---

# Step 2 - Create the Test Workload

Create the following manifest.

```
tests/karpenter-provisioning-test.yaml
```

The workload uses the custom node selector:

```yaml
nodeSelector:
  node.cloudhusller.com/node-pool: default
```

This ensures the deployment cannot run on the managed node group and must be provisioned by Karpenter.

---

# Step 3 - Start Live Monitoring

Open four terminals before deploying the workload.

---

## Terminal 1 - Watch Pods

```bash
kubectl get pods -n karpenter-test -o wide --watch
```

📷 **Screenshot 03-05** – Pod Watch

---

## Terminal 2 - Watch NodeClaims

```bash
kubectl get nodeclaims --watch
```

📷 **Screenshot 03-06** – NodeClaim Watch

---

## Terminal 3 - Watch Nodes

```bash
kubectl get nodes \
-L karpenter.sh/nodepool,node.cloudhusller.com/node-pool,karpenter.sh/capacity-type \
--watch
```

📷 **Screenshot 03-07** – Node Watch

---

## Terminal 4 - Watch Karpenter Logs

```bash
kubectl logs \
-n kube-system \
deployment/karpenter \
--all-containers=true \
--since=5m \
--follow
```

📷 **Screenshot 03-08** – Karpenter Logs

---

# Step 4 - Deploy the Workload

```bash
kubectl apply -f tests/karpenter-provisioning-test.yaml
```

Expected Output

```
namespace/karpenter-test created

deployment.apps/inflate created
```

📷 **Screenshot 03-09** – Deployment Created

---

# Step 5 - Observe Pending Pods

```bash
kubectl get pods -n karpenter-test -o wide
```

Initially, the pods should remain Pending.

Example

```
NAME                 READY   STATUS
inflate-xxxxx        0/1     Pending
```

This confirms Kubernetes cannot schedule the workload using existing cluster capacity.

📷 **Screenshot 03-10** – Pending Pods

---

# Step 6 - Observe NodeClaim Creation

Karpenter detects the pending workload and creates a NodeClaim.

```bash
kubectl get nodeclaims
```

Example

```
NAME            TYPE         CAPACITY    ZONE         READY

default-f7j55   c6a.xlarge   on-demand   us-east-2b   True
```

📷 **Screenshot 03-11** – NodeClaim Created

---

## View NodeClaim Details

```bash
kubectl describe nodeclaim
```

📷 **Screenshot 03-12** – NodeClaim Details

---

## Custom NodeClaim View

```bash
kubectl get nodeclaims \
-o custom-columns='NAME:.metadata.name,INSTANCE:.status.instanceType,CAPACITY:.metadata.labels.karpenter\.sh/capacity-type,ZONE:.metadata.labels.topology\.kubernetes\.io/zone,NODE:.status.nodeName,READY:.status.conditions[?(@.type=="Ready")].status'
```

📷 **Screenshot 03-13** – NodeClaim Summary

---

# Step 7 - Observe New Worker Node

```bash
kubectl get nodes \
-L karpenter.sh/nodepool,node.cloudhusller.com/node-pool,karpenter.sh/capacity-type \
-o wide
```

Expected Output

A new worker node appears.

Example

```
ip-10-0-3-117.us-east-2.compute.internal
```

📷 **Screenshot 03-14** – New Worker Node

---

## Verify Node Labels

```bash
kubectl get node ip-10-0-3-117.us-east-2.compute.internal \
-L karpenter.sh/nodepool,karpenter.sh/capacity-type,node.kubernetes.io/instance-type,topology.kubernetes.io/zone
```

Expected Labels

```
karpenter.sh/nodepool=default

karpenter.sh/capacity-type=on-demand

node.kubernetes.io/instance-type=c6a.xlarge
```

📷 **Screenshot 03-15** – Node Labels

---

# Step 8 - Verify Running Workload

```bash
kubectl get deployment inflate -n karpenter-test
```

Expected Output

```
READY

3/3
```

📷 **Screenshot 03-16** – Deployment Ready

---

## Verify Pod Placement

```bash
kubectl get pods \
-n karpenter-test \
-o wide
```

All pods should now be Running.

Example

```
STATUS

Running
Running
Running
```

📷 **Screenshot 03-17** – Running Pods

---

# Step 9 - Delete the Test Workload

```bash
kubectl delete -f tests/karpenter-provisioning-test.yaml
```

Expected Output

```
namespace "karpenter-test" deleted
```

📷 **Screenshot 03-18** – Deployment Deleted

---

# Step 10 - Observe Automatic Node Consolidation

Watch NodeClaims.

```bash
kubectl get nodeclaims --watch
```

Eventually the NodeClaim disappears.

📷 **Screenshot 03-19** – NodeClaim Deleted

---

Watch Nodes.

```bash
kubectl get nodes \
-l karpenter.sh/nodepool=default \
--watch
```

Eventually the Karpenter worker node disappears.

📷 **Screenshot 03-20** – Node Removed

---

Verify the namespace has been removed.

```bash
kubectl get namespace karpenter-test
```

Expected Output

```
Error from server (NotFound): namespaces "karpenter-test" not found
```

📷 **Screenshot 03-21** – Namespace Deleted

---

# Final Validation Checklist

| Validation | Status |
|------------|--------|
| EC2NodeClass Ready | ✅ |
| NodePool Ready | ✅ |
| Pods Pending | ✅ |
| NodeClaim Created | ✅ |
| EC2 Instance Provisioned | ✅ |
| Worker Node Joined Cluster | ✅ |
| Pods Scheduled | ✅ |
| Deployment Running | ✅ |
| Workload Deleted | ✅ |
| NodeClaim Removed | ✅ |
| EC2 Instance Terminated | ✅ |
| Worker Node Removed | ✅ |

---

# Commands Used During Validation

```bash
kubectl get ec2nodeclass

kubectl get nodepool

kubectl get nodes -o wide

kubectl get nodeclaims

kubectl apply -f tests/karpenter-provisioning-test.yaml

kubectl get pods -n karpenter-test -o wide

kubectl get pods -n karpenter-test -o wide --watch

kubectl get nodeclaims --watch

kubectl get nodes \
-L karpenter.sh/nodepool,node.cloudhusller.com/node-pool,karpenter.sh/capacity-type \
--watch

kubectl logs \
-n kube-system \
deployment/karpenter \
--all-containers=true \
--since=5m \
--follow

kubectl describe nodeclaim

kubectl get nodeclaims \
-o custom-columns='NAME:.metadata.name,INSTANCE:.status.instanceType,CAPACITY:.metadata.labels.karpenter\.sh/capacity-type,ZONE:.metadata.labels.topology\.kubernetes\.io/zone,NODE:.status.nodeName,READY:.status.conditions[?(@.type=="Ready")].status'

kubectl get node ip-10-0-3-117.us-east-2.compute.internal \
-L karpenter.sh/nodepool,karpenter.sh/capacity-type,node.kubernetes.io/instance-type,topology.kubernetes.io/zone

kubectl get deployment inflate -n karpenter-test

kubectl delete -f tests/karpenter-provisioning-test.yaml

kubectl get namespace karpenter-test
```

---

# Interview Talking Points

- Demonstrated event-driven infrastructure provisioning using Karpenter.
- Verified NodePool and EC2NodeClass configuration before workload deployment.
- Confirmed Kubernetes generated unschedulable pods when no existing node satisfied scheduling constraints.
- Observed Karpenter automatically create a NodeClaim and provision a new EC2 instance.
- Verified the new node successfully joined the EKS cluster and scheduled the application workload.
- Confirmed automatic node consolidation by deleting the workload and validating that Karpenter removed the NodeClaim, terminated the EC2 instance, and removed the worker node from the cluster.
- Validated the complete provisioning and deprovisioning lifecycle without manual infrastructure intervention.

---

# Conclusion

The provisioning test successfully validated the complete Karpenter lifecycle within the CloudHustler Commerce Platform.

The platform demonstrated the ability to provision compute resources on demand, automatically integrate new worker nodes into the EKS cluster, schedule application workloads, and reclaim unused infrastructure after the workload was removed.

This confirms that the platform is capable of dynamic, cost-efficient Kubernetes scaling suitable for production environments.