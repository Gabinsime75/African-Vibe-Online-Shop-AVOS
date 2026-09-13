# Karpenter Module

## Purpose

This module installs Karpenter and creates the AWS resources required for
dynamic EKS worker-node provisioning.

Karpenter observes pods that cannot be scheduled on the existing cluster
capacity, evaluates their scheduling requirements, launches suitable EC2
instances, and removes unnecessary capacity when it is no longer needed.

## Resources Created

- Karpenter Helm release
- Karpenter controller IAM role
- Karpenter controller IAM policy
- EKS Pod Identity association
- Karpenter worker-node IAM role
- EKS worker-node access entry
- SQS interruption queue
- SQS queue policy
- EventBridge interruption rules
- EventBridge SQS targets

## Architecture

```text
Unschedulable Pod
        |
        v
Karpenter Controller
        |
        +----------------------+
        |                      |
        v                      v
EC2 APIs                 SQS Interruption Queue
        |                      ^
        v                      |
Dynamic EC2 Node       EventBridge Lifecycle Events
        |
        v
Pod Scheduled