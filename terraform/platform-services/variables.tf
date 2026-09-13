###############################################################
# Project Configuration
###############################################################

variable "project_name" {
  description = "Name of the CloudHustler project."
  type        = string

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name cannot be empty."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition = contains(
      ["dev", "staging", "prod"],
      var.environment
    )

    error_message = "environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "AWS region containing the EKS cluster."
  type        = string

  validation {
    condition     = length(trimspace(var.aws_region)) > 0
    error_message = "aws_region cannot be empty."
  }
}

###############################################################
# EKS Configuration
###############################################################

variable "cluster_name" {
  description = "Name of the existing EKS cluster."
  type        = string

  validation {
    condition     = length(trimspace(var.cluster_name)) > 0
    error_message = "cluster_name cannot be empty."
  }
}

variable "vpc_id" {
  description = "VPC ID containing the EKS cluster and ALB."
  type        = string

  validation {
    condition     = can(regex("^vpc-[0-9a-f]+$", var.vpc_id))
    error_message = "vpc_id must be a valid AWS VPC ID."
  }
}

###############################################################
# Existing Istio Target Group
###############################################################

# platform-services/variables.tf

variable "istio_ingress_target_group_arn" {
  description = "ARN of the existing Istio ingress gateway target group."
  type        = string

  validation {
    condition = can(regex(
      "^arn:[^:]+:elasticloadbalancing:[^:]+:[0-9]{12}:targetgroup/.+/.+$",
      var.istio_ingress_target_group_arn
    ))

    error_message = "istio_ingress_target_group_arn must be a valid target group ARN."
  }
}
###############################################################
# AWS Load Balancer Controller
###############################################################

variable "aws_load_balancer_controller_namespace" {
  description = "Kubernetes namespace for the AWS Load Balancer Controller."
  type        = string
  default     = "kube-system"
}

variable "aws_load_balancer_controller_service_account_name" {
  description = "Kubernetes service account used by the AWS Load Balancer Controller."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "aws_load_balancer_controller_release_name" {
  description = "Helm release name for the AWS Load Balancer Controller."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "aws_load_balancer_controller_chart_version" {
  description = "Pinned Helm chart version for the AWS Load Balancer Controller."
  type        = string
  default     = null
}

variable "aws_load_balancer_controller_replica_count" {
  description = "Number of AWS Load Balancer Controller replicas."
  type        = number
  default     = 2

  validation {
    condition     = var.aws_load_balancer_controller_replica_count >= 2
    error_message = "At least two controller replicas are required."
  }
}

variable "aws_load_balancer_controller_helm_timeout" {
  description = "Helm installation timeout in seconds."
  type        = number
  default     = 600

  validation {
    condition = (
      var.aws_load_balancer_controller_helm_timeout >= 300 &&
      var.aws_load_balancer_controller_helm_timeout <= 1800
    )

    error_message = "The Helm timeout must be between 300 and 1800 seconds."
  }
}

###############################################################
# Tags
###############################################################

variable "tags" {
  description = "Additional tags applied to AWS resources."
  type        = map(string)
  default     = {}
}

###############################################################
# Metrics Server
###############################################################

variable "metrics_server_namespace" {
  description = "Kubernetes namespace for Metrics Server."
  type        = string
  default     = "kube-system"
}

variable "metrics_server_release_name" {
  description = "Metrics Server Helm release name."
  type        = string
  default     = "metrics-server"
}

variable "metrics_server_chart_version" {
  description = "Pinned Metrics Server Helm chart version."
  type        = string
  default     = "3.13.1"
}

variable "metrics_server_replica_count" {
  description = "Number of Metrics Server replicas."
  type        = number
  default     = 2
}

variable "metrics_server_helm_timeout" {
  description = "Metrics Server Helm timeout in seconds."
  type        = number
  default     = 600
}

###############################################################
# Istio Control Plane
###############################################################

variable "istio_chart_version" {
  description = "Pinned Istio Helm chart version."
  type        = string
  default     = "1.30.1"
}

variable "istio_namespace" {
  description = "Namespace containing the Istio control plane."
  type        = string
  default     = "istio-system"
}

variable "istio_revision" {
  description = "Istio control-plane revision."
  type        = string
  default     = "default"
  nullable    = false

  validation {
    condition     = length(trimspace(var.istio_revision)) > 0
    error_message = "istio_revision cannot be empty."
  }
}

variable "istiod_autoscale_min_replicas" {
  description = "Minimum number of Istiod replicas."
  type        = number
  default     = 2
}

variable "istiod_autoscale_max_replicas" {
  description = "Maximum number of Istiod replicas."
  type        = number
  default     = 5
}

variable "istiod_autoscaling_cpu_target_percentage" {
  description = "Target CPU utilization for Istiod autoscaling."
  type        = number
  default     = 80
}

variable "istio_tracing_sampling_percentage" {
  description = "Percentage of requests sampled for tracing."
  type        = number
  default     = 1.0
}

variable "istio_outbound_traffic_policy_mode" {
  description = "Istio policy for outbound traffic not registered in the mesh."
  type        = string
  default     = "REGISTRY_ONLY"
}

###############################################################
# Istio Ingress Gateway
###############################################################

variable "istio_ingress_gateway_release_name" {
  description = "Istio ingress gateway Helm release name."
  type        = string
  default     = "istio-ingress"
}

variable "istio_ingress_gateway_name" {
  description = "Istio ingress gateway resource name."
  type        = string
  default     = "istio-ingress"
}

variable "istio_ingress_gateway_namespace" {
  description = "Namespace containing the Istio ingress gateway."
  type        = string
  default     = "istio-ingress"
}

variable "istio_ingress_autoscale_min_replicas" {
  description = "Minimum ingress gateway replicas."
  type        = number
  default     = 2
}

variable "istio_ingress_autoscale_max_replicas" {
  description = "Maximum ingress gateway replicas."
  type        = number
  default     = 5
}

variable "istio_ingress_autoscaling_cpu_target_percentage" {
  description = "Ingress gateway HPA CPU target."
  type        = number
  default     = 70
}

variable "istio_ingress_autoscaling_memory_target_percentage" {
  description = "Ingress gateway HPA memory target."
  type        = number
  default     = 80
}

variable "istio_ingress_cpu_request" {
  description = "Ingress gateway CPU request."
  type        = string
  default     = "200m"
}

variable "istio_ingress_memory_request" {
  description = "Ingress gateway memory request."
  type        = string
  default     = "256Mi"
}

variable "istio_ingress_cpu_limit" {
  description = "Ingress gateway CPU limit."
  type        = string
  default     = "1000m"
}

variable "istio_ingress_memory_limit" {
  description = "Ingress gateway memory limit."
  type        = string
  default     = "1024Mi"
}

variable "istiod_cpu_request" {
  description = "CPU request for each Istiod pod."
  type        = string
  default     = "250m"
}

variable "istiod_memory_request" {
  description = "Memory request for each Istiod pod."
  type        = string
  default     = "512Mi"
}

variable "istiod_cpu_limit" {
  description = "CPU limit for each Istiod pod."
  type        = string
  default     = "1000m"
}

variable "istiod_memory_limit" {
  description = "Memory limit for each Istiod pod."
  type        = string
  default     = "1024Mi"
}

################################################################################
# Terraform Remote State
################################################################################

variable "terraform_state_bucket" {
  description = "Name of the S3 bucket containing the CloudHustler Terraform state files."
  type        = string

  validation {
    condition     = length(trimspace(var.terraform_state_bucket)) > 0
    error_message = "terraform_state_bucket cannot be empty."
  }
}

variable "networking_state_key" {
  description = "S3 object key for the networking Terraform state."
  type        = string

  validation {
    condition     = length(trimspace(var.networking_state_key)) > 0
    error_message = "networking_state_key cannot be empty."
  }
}

variable "terraform_state_lock_table" {
  description = "Name of the DynamoDB table used for Terraform state locking."
  type        = string
  default     = null
}

variable "terraform_state_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt Terraform state."
  type        = string
  default     = null
}

################################################################################
# ExternalDNS Configuration
#
# These variables configure the ExternalDNS platform service, including its
# Kubernetes deployment, Route 53 authorization, synchronization behavior,
# Helm release, scheduling rules, and observability integration.
################################################################################


################################################################################
# ExternalDNS Core Configuration
################################################################################

variable "external_dns_namespace" {
  description = "Kubernetes namespace in which ExternalDNS will be deployed."
  type        = string
  default     = "external-dns"

  validation {
    condition = (
      length(var.external_dns_namespace) > 0 &&
      can(regex(
        "^[a-z0-9]([-a-z0-9]*[a-z0-9])?$",
        var.external_dns_namespace
      ))
    )

    error_message = "external_dns_namespace must be a valid Kubernetes namespace name."
  }
}

variable "external_dns_service_account_name" {
  description = "Kubernetes service account used by ExternalDNS through EKS Pod Identity."
  type        = string
  default     = "external-dns"

  validation {
    condition = (
      length(var.external_dns_service_account_name) > 0 &&
      can(regex(
        "^[a-z0-9]([-a-z0-9]*[a-z0-9])?$",
        var.external_dns_service_account_name
      ))
    )

    error_message = "external_dns_service_account_name must be a valid Kubernetes service account name."
  }
}


################################################################################
# Route 53 Configuration
################################################################################

variable "route53_hosted_zone_id" {
  description = "Route 53 hosted zone ID that ExternalDNS is authorized to manage."
  type        = string

  validation {
    condition     = length(trimspace(var.route53_hosted_zone_id)) > 0
    error_message = "route53_hosted_zone_id must not be empty."
  }
}

variable "external_dns_domain_filters" {
  description = "List of DNS domains that ExternalDNS is permitted to manage."
  type        = list(string)

  validation {
    condition = (
      length(var.external_dns_domain_filters) > 0 &&
      alltrue([
        for domain in var.external_dns_domain_filters :
        length(trimspace(domain)) > 0
      ])
    )

    error_message = "external_dns_domain_filters must contain at least one valid domain."
  }
}

variable "external_dns_aws_zone_type" {
  description = "Route 53 hosted-zone type managed by ExternalDNS."
  type        = string
  default     = "public"

  validation {
    condition = contains(
      [
        "public",
        "private"
      ],
      var.external_dns_aws_zone_type
    )

    error_message = "external_dns_aws_zone_type must be either public or private."
  }
}


################################################################################
# DNS Synchronization Configuration
################################################################################

variable "external_dns_sources" {
  description = "Kubernetes resource types watched by ExternalDNS."
  type        = list(string)

  default = [
    "service",
    "ingress",
    "istio-gateway",
    "istio-virtualservice"
  ]

  validation {
    condition = alltrue([
      for source in var.external_dns_sources :
      contains(
        [
          "service",
          "ingress",
          "gateway-httproute",
          "istio-gateway",
          "istio-virtualservice"
        ],
        source
      )
    ])

    error_message = "external_dns_sources contains an unsupported ExternalDNS source."
  }
}

variable "external_dns_policy" {
  description = "DNS synchronization policy used by ExternalDNS."
  type        = string
  default     = "sync"

  validation {
    condition = contains(
      [
        "sync",
        "upsert-only"
      ],
      var.external_dns_policy
    )

    error_message = "external_dns_policy must be sync or upsert-only."
  }
}

variable "external_dns_registry" {
  description = "ExternalDNS ownership registry."
  type        = string
  default     = "txt"

  validation {
    condition = contains(
      [
        "txt",
        "noop"
      ],
      var.external_dns_registry
    )

    error_message = "external_dns_registry must be txt or noop."
  }
}

variable "external_dns_txt_owner_id" {
  description = "Unique ownership identifier written to ExternalDNS TXT records."
  type        = string

  validation {
    condition     = length(trimspace(var.external_dns_txt_owner_id)) > 0
    error_message = "external_dns_txt_owner_id must not be empty."
  }
}

variable "external_dns_txt_prefix" {
  description = "Optional prefix applied to ExternalDNS ownership TXT records."
  type        = string
  default     = ""
}

variable "external_dns_interval" {
  description = "Interval between full ExternalDNS synchronization cycles."
  type        = string
  default     = "1m"

  validation {
    condition = can(regex(
      "^[0-9]+(s|m|h)$",
      var.external_dns_interval
    ))

    error_message = "external_dns_interval must use a duration such as 30s, 1m, or 1h."
  }
}

variable "external_dns_trigger_loop_on_event" {
  description = "Whether Kubernetes events trigger immediate ExternalDNS reconciliation."
  type        = bool
  default     = true
}

variable "external_dns_aws_batch_change_size" {
  description = "Maximum number of Route 53 record changes submitted in one batch."
  type        = number
  default     = 1000

  validation {
    condition = (
      var.external_dns_aws_batch_change_size >= 1 &&
      var.external_dns_aws_batch_change_size <= 1000
    )

    error_message = "external_dns_aws_batch_change_size must be between 1 and 1000."
  }
}


################################################################################
# ExternalDNS Helm Configuration
################################################################################

variable "external_dns_helm_repository" {
  description = "Helm repository containing the ExternalDNS chart."
  type        = string
  default     = "https://kubernetes-sigs.github.io/external-dns/"
}

variable "external_dns_chart_name" {
  description = "Name of the ExternalDNS Helm chart."
  type        = string
  default     = "external-dns"
}

variable "external_dns_chart_version" {
  description = "Version of the ExternalDNS Helm chart."
  type        = string
}

variable "external_dns_replica_count" {
  description = "Number of ExternalDNS controller replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.external_dns_replica_count >= 1
    error_message = "external_dns_replica_count must be at least 1."
  }
}


################################################################################
# Logging and Observability
################################################################################

variable "external_dns_log_level" {
  description = "ExternalDNS logging verbosity."
  type        = string
  default     = "info"

  validation {
    condition = contains(
      [
        "panic",
        "debug",
        "info",
        "warning",
        "error",
        "fatal"
      ],
      var.external_dns_log_level
    )

    error_message = "external_dns_log_level contains an unsupported value."
  }
}

variable "external_dns_log_format" {
  description = "ExternalDNS log output format."
  type        = string
  default     = "json"

  validation {
    condition = contains(
      [
        "text",
        "json"
      ],
      var.external_dns_log_format
    )

    error_message = "external_dns_log_format must be text or json."
  }
}

variable "external_dns_enable_service_monitor" {
  description = "Whether to create a Prometheus Operator ServiceMonitor."
  type        = bool
  default     = false
}

variable "external_dns_service_monitor_namespace" {
  description = "Namespace in which the ExternalDNS ServiceMonitor is created."
  type        = string
  default     = ""
}


################################################################################
# Kubernetes Resource and Scheduling Configuration
################################################################################

variable "external_dns_resources" {
  description = "CPU and memory requests and limits assigned to ExternalDNS."
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })

    limits = object({
      cpu    = string
      memory = string
    })
  })

  default = {
    requests = {
      cpu    = "50m"
      memory = "64Mi"
    }

    limits = {
      cpu    = "200m"
      memory = "256Mi"
    }
  }
}

variable "external_dns_pod_labels" {
  description = "Additional labels applied to ExternalDNS Pods."
  type        = map(string)
  default     = {}
}

variable "external_dns_pod_annotations" {
  description = "Additional annotations applied to ExternalDNS Pods."
  type        = map(string)
  default     = {}
}

variable "external_dns_node_selector" {
  description = "Node selector used to schedule ExternalDNS Pods."
  type        = map(string)
  default     = {}
}

variable "external_dns_tolerations" {
  description = "Kubernetes tolerations applied to ExternalDNS Pods."
  type        = list(any)
  default     = []
}

variable "external_dns_affinity" {
  description = "Kubernetes affinity configuration applied to ExternalDNS Pods."
  type        = any
  default     = {}
}

variable "external_dns_priority_class_name" {
  description = "Optional Kubernetes priority class assigned to ExternalDNS Pods."
  type        = string
  default     = ""
}

variable "external_dns_additional_helm_values" {
  description = "Additional Helm values merged into the ExternalDNS deployment."
  type        = any
  default     = {}
}

# =============================================================================
# Karpenter Configuration
# =============================================================================
# Defines the platform-services root inputs used to configure the reusable
# Karpenter module.
# =============================================================================

# -----------------------------------------------------------------------------
# Kubernetes Configuration
# -----------------------------------------------------------------------------

variable "karpenter_namespace" {
  description = "Kubernetes namespace where Karpenter is installed."
  type        = string
  default     = "kube-system"
}

variable "karpenter_service_account_name" {
  description = "Kubernetes service account used by the Karpenter controller."
  type        = string
  default     = "karpenter"
}

# -----------------------------------------------------------------------------
# Helm Configuration
# -----------------------------------------------------------------------------

variable "karpenter_chart_version" {
  description = "Pinned version of the Karpenter Helm chart."
  type        = string
}

variable "karpenter_controller_replicas" {
  description = "Number of Karpenter controller replicas."
  type        = number
  default     = 2

  validation {
    condition     = var.karpenter_controller_replicas >= 1
    error_message = "Karpenter must have at least one controller replica."
  }
}

# -----------------------------------------------------------------------------
# Controller Resource Configuration
# -----------------------------------------------------------------------------

variable "karpenter_controller_cpu_request" {
  description = "CPU request for each Karpenter controller pod."
  type        = string
  default     = "500m"
}

variable "karpenter_controller_memory_request" {
  description = "Memory request for each Karpenter controller pod."
  type        = string
  default     = "512Mi"
}

variable "karpenter_controller_cpu_limit" {
  description = "CPU limit for each Karpenter controller pod."
  type        = string
  default     = "1"
}

variable "karpenter_controller_memory_limit" {
  description = "Memory limit for each Karpenter controller pod."
  type        = string
  default     = "1Gi"
}

# -----------------------------------------------------------------------------
# Interruption Handling
# -----------------------------------------------------------------------------

variable "karpenter_enable_interruption_handling" {
  description = "Whether to create the Karpenter SQS interruption queue and EventBridge rules."
  type        = bool
  default     = true
}

# =============================================================================
# External Secrets Operator Configuration
# =============================================================================
# Defines the root-module inputs used to configure External Secrets Operator,
# AWS Secrets Manager integration, Parameter Store integration, and the
# cluster-wide secret store.
# =============================================================================

# -----------------------------------------------------------------------------
# AWS Secret Backend Configuration
# -----------------------------------------------------------------------------

variable "enable_secrets_manager" {
  description = "Whether External Secrets Operator can retrieve secrets from AWS Secrets Manager."
  type        = bool
  default     = true
}

variable "enable_parameter_store" {
  description = "Whether External Secrets Operator can retrieve parameters from AWS Systems Manager Parameter Store."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# ClusterSecretStore Configuration
# -----------------------------------------------------------------------------

variable "create_cluster_secret_store" {
  description = "Whether to create a cluster-wide External Secrets ClusterSecretStore."
  type        = bool
  default     = true
}

variable "cluster_secret_store_name" {
  description = "Name of the External Secrets ClusterSecretStore."
  type        = string
  default     = "aws-secrets-manager"
}

variable "secret_store_service" {
  description = "AWS secret backend used by the ClusterSecretStore."
  type        = string
  default     = "SecretsManager"

  validation {
    condition = contains(
      ["SecretsManager", "ParameterStore"],
      var.secret_store_service
    )

    error_message = "secret_store_service must be either SecretsManager or ParameterStore."
  }
}

# -----------------------------------------------------------------------------
# Kubernetes Configuration
# -----------------------------------------------------------------------------

variable "external_secrets_namespace" {
  description = "Kubernetes namespace where External Secrets Operator is installed."
  type        = string
  default     = "external-secrets"
}

variable "external_secrets_service_account" {
  description = "Kubernetes service account used by External Secrets Operator."
  type        = string
  default     = "external-secrets"
}

# -----------------------------------------------------------------------------
# Controller Configuration
# -----------------------------------------------------------------------------

variable "external_secrets_replica_count" {
  description = "Number of External Secrets Operator controller replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.external_secrets_replica_count >= 1
    error_message = "External Secrets Operator must have at least one controller replica."
  }
}

variable "external_secrets_log_level" {
  description = "Log level used by the External Secrets Operator controller."
  type        = string
  default     = "info"
}

variable "external_secrets_concurrent" {
  description = "Maximum number of concurrent External Secrets reconciliations."
  type        = number
  default     = 1

  validation {
    condition     = var.external_secrets_concurrent >= 1
    error_message = "external_secrets_concurrent must be at least 1."
  }
}

# -----------------------------------------------------------------------------
# Webhook Configuration
# -----------------------------------------------------------------------------

variable "external_secrets_enable_webhook" {
  description = "Whether to enable the External Secrets admission webhook."
  type        = bool
  default     = true
}

variable "external_secrets_webhook_replica_count" {
  description = "Number of External Secrets webhook replicas."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Certificate Controller Configuration
# -----------------------------------------------------------------------------

variable "external_secrets_enable_cert_controller" {
  description = "Whether to enable the External Secrets certificate controller."
  type        = bool
  default     = true
}

variable "external_secrets_cert_controller_replica_count" {
  description = "Number of External Secrets certificate-controller replicas."
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Monitoring and Availability Configuration
# -----------------------------------------------------------------------------

variable "external_secrets_enable_service_monitor" {
  description = "Whether to create a Prometheus ServiceMonitor for External Secrets Operator."
  type        = bool
  default     = false
}

variable "external_secrets_metrics_service_enabled" {
  description = "Whether to enable the External Secrets metrics service."
  type        = bool
  default     = true
}

variable "external_secrets_pdb_enabled" {
  description = "Whether to create a PodDisruptionBudget for External Secrets Operator."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Helm Configuration
# -----------------------------------------------------------------------------

variable "external_secrets_chart_version" {
  description = "Pinned version of the External Secrets Operator Helm chart."
  type        = string
}

# =============================================================================
# Karpenter EC2NodeClass Configuration
# =============================================================================
# Defines the AWS-specific configuration used by Karpenter when creating
# dynamically provisioned EKS worker nodes.
# =============================================================================

# -----------------------------------------------------------------------------
# EC2NodeClass Identity
# -----------------------------------------------------------------------------

variable "karpenter_ec2_node_class_name" {
  description = "Name of the Karpenter EC2NodeClass."
  type        = string
  default     = "default"
}

# -----------------------------------------------------------------------------
# EKS Cluster Networking
# -----------------------------------------------------------------------------

variable "cluster_security_group_id" {
  description = "EKS cluster security group attached to Karpenter-managed nodes."
  type        = string
}

# -----------------------------------------------------------------------------
# AMI Configuration
# -----------------------------------------------------------------------------

variable "karpenter_ami_family" {
  description = "AMI family used by Karpenter-managed worker nodes."
  type        = string
  default     = "AL2023"

  validation {
    condition = contains(
      [
        "AL2",
        "AL2023",
        "Bottlerocket",
        "Custom",
        "Windows2019",
        "Windows2022"
      ],
      var.karpenter_ami_family
    )

    error_message = "karpenter_ami_family must be a supported Karpenter AMI family."
  }
}

variable "karpenter_ami_alias" {
  description = "AMI alias used to select an EKS-optimized AMI for Karpenter nodes."
  type        = string
  default     = "al2023@latest"
}

# -----------------------------------------------------------------------------
# Root Volume Configuration
# -----------------------------------------------------------------------------

variable "karpenter_root_volume_type" {
  description = "EBS root-volume type used by Karpenter-managed nodes."
  type        = string
  default     = "gp3"
}

variable "karpenter_root_volume_size" {
  description = "Root-volume size assigned to Karpenter-managed nodes."
  type        = string
  default     = "50Gi"
}

variable "karpenter_root_volume_iops" {
  description = "Provisioned IOPS assigned to Karpenter node root volumes."
  type        = number
  default     = 3000

  validation {
    condition     = var.karpenter_root_volume_iops >= 3000
    error_message = "GP3 root-volume IOPS must be at least 3000."
  }
}

variable "karpenter_root_volume_throughput" {
  description = "Provisioned throughput in MiB/s assigned to Karpenter node root volumes."
  type        = number
  default     = 125

  validation {
    condition     = var.karpenter_root_volume_throughput >= 125
    error_message = "GP3 root-volume throughput must be at least 125 MiB/s."
  }
}

# =============================================================================
# Karpenter NodePool Configuration
# =============================================================================
# Defines scheduling constraints, resource limits, capacity types, and
# disruption behavior for Karpenter-managed worker nodes.
# =============================================================================

# -----------------------------------------------------------------------------
# NodePool Identity
# -----------------------------------------------------------------------------

variable "karpenter_node_pool_name" {
  description = "Name of the default Karpenter NodePool."
  type        = string
  default     = "default"
}

variable "karpenter_node_pool_weight" {
  description = "Scheduling weight assigned to the Karpenter NodePool."
  type        = number
  default     = 10

  validation {
    condition     = var.karpenter_node_pool_weight >= 0
    error_message = "karpenter_node_pool_weight must be zero or greater."
  }
}

# -----------------------------------------------------------------------------
# Operating System and Architecture
# -----------------------------------------------------------------------------

variable "karpenter_operating_systems" {
  description = "Operating systems allowed for Karpenter-managed nodes."
  type        = list(string)
  default     = ["linux"]
}

variable "karpenter_architectures" {
  description = "CPU architectures allowed for Karpenter-managed nodes."
  type        = list(string)
  default     = ["amd64"]
}

# -----------------------------------------------------------------------------
# Karpenter Capacity Types
# -----------------------------------------------------------------------------

variable "karpenter_capacity_types" {
  description = "EC2 capacity types allowed for Karpenter-managed nodes."
  type        = list(string)

  default = [
    "on-demand"
  ]

  validation {
    condition = (
      length(var.karpenter_capacity_types) > 0 &&
      alltrue([
        for capacity_type in var.karpenter_capacity_types :
        contains(["on-demand"], capacity_type)
      ])
    )

    error_message = "Karpenter capacity types must contain only \"on-demand\"."
  }
}

variable "karpenter_instance_categories" {
  description = "EC2 instance categories allowed for Karpenter-managed nodes."
  type        = list(string)
  default     = ["c", "m", "r"]
}

variable "karpenter_minimum_instance_generation" {
  description = "Karpenter permits EC2 instance generations greater than this value."
  type        = number
  default     = 2

  validation {
    condition     = var.karpenter_minimum_instance_generation >= 1
    error_message = "karpenter_minimum_instance_generation must be at least 1."
  }
}

variable "karpenter_instance_cpu_options" {
  description = "Allowed vCPU counts for Karpenter-provisioned EC2 instances."
  type        = list(number)
  default     = [2, 4, 8, 16]
}

# -----------------------------------------------------------------------------
# NodePool Limits
# -----------------------------------------------------------------------------

variable "karpenter_node_pool_cpu_limit" {
  description = "Maximum total vCPU capacity that Karpenter may provision through this NodePool."
  type        = number
  default     = 100

  validation {
    condition     = var.karpenter_node_pool_cpu_limit > 0
    error_message = "karpenter_node_pool_cpu_limit must be greater than zero."
  }
}

variable "karpenter_node_pool_memory_limit" {
  description = "Maximum total memory capacity that Karpenter may provision through this NodePool."
  type        = string
  default     = "400Gi"
}

# -----------------------------------------------------------------------------
# Node Lifecycle
# -----------------------------------------------------------------------------

variable "karpenter_node_expire_after" {
  description = "Maximum lifetime of a Karpenter-managed node."
  type        = string
  default     = "720h"
}

# -----------------------------------------------------------------------------
# Consolidation and Disruption
# -----------------------------------------------------------------------------

variable "karpenter_consolidation_policy" {
  description = "Policy governing when Karpenter may consolidate nodes."
  type        = string
  default     = "WhenEmptyOrUnderutilized"

  validation {
    condition = contains(
      ["WhenEmpty", "WhenEmptyOrUnderutilized"],
      var.karpenter_consolidation_policy
    )

    error_message = "karpenter_consolidation_policy must be WhenEmpty or WhenEmptyOrUnderutilized."
  }
}

variable "karpenter_consolidate_after" {
  description = "Time Karpenter waits before attempting node consolidation."
  type        = string
  default     = "1m"
}

variable "karpenter_disruption_budget" {
  description = "Maximum percentage or number of NodePool nodes that may be disrupted simultaneously."
  type        = string
  default     = "10%"
}

# =============================================================================
# Prometheus Monitoring Foundation Variables
# =============================================================================
# These variables configure the Phase 1 Prometheus monitoring foundation,
# including Prometheus Operator, Prometheus Server, Alertmanager,
# kube-state-metrics, Node Exporter, and Kubernetes monitoring rules.
#
# Grafana and application-specific monitoring are intentionally excluded from
# this phase.
# =============================================================================

# -----------------------------------------------------------------------------
# Prometheus Namespace Configuration
# -----------------------------------------------------------------------------

variable "prometheus_namespace" {
  description = "Kubernetes namespace in which the Prometheus monitoring stack is deployed."
  type        = string
  default     = "monitoring"

  validation {
    condition     = length(trimspace(var.prometheus_namespace)) > 0
    error_message = "prometheus_namespace must not be empty."
  }
}

variable "prometheus_create_namespace" {
  description = "Determines whether Terraform creates the Prometheus namespace."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Prometheus Helm Release Configuration
# -----------------------------------------------------------------------------

variable "prometheus_release_name" {
  description = "Helm release name for kube-prometheus-stack."
  type        = string
  default     = "kube-prometheus-stack"

  validation {
    condition     = length(trimspace(var.prometheus_release_name)) > 0
    error_message = "prometheus_release_name must not be empty."
  }
}

variable "prometheus_chart_repository" {
  description = "Helm repository containing kube-prometheus-stack."
  type        = string
  default     = "https://prometheus-community.github.io/helm-charts"

  validation {
    condition     = can(regex("^https://", var.prometheus_chart_repository))
    error_message = "prometheus_chart_repository must be a valid HTTPS URL."
  }
}

variable "prometheus_chart_name" {
  description = "Name of the kube-prometheus-stack Helm chart."
  type        = string
  default     = "kube-prometheus-stack"

  validation {
    condition     = length(trimspace(var.prometheus_chart_name)) > 0
    error_message = "prometheus_chart_name must not be empty."
  }
}

variable "prometheus_chart_version" {
  description = "Pinned kube-prometheus-stack Helm chart version."
  type        = string
  default     = "87.19.1"

  validation {
    condition = can(
      regex(
        "^[0-9]+\\.[0-9]+\\.[0-9]+$",
        var.prometheus_chart_version
      )
    )

    error_message = "prometheus_chart_version must use semantic version format."
  }
}

variable "prometheus_helm_timeout" {
  description = "Maximum number of seconds Terraform waits for the Prometheus Helm operation."
  type        = number
  default     = 1200

  validation {
    condition     = var.prometheus_helm_timeout >= 300
    error_message = "prometheus_helm_timeout must be at least 300 seconds."
  }
}

variable "prometheus_helm_wait" {
  description = "Determines whether Terraform waits for the Prometheus resources to become ready."
  type        = bool
  default     = true
}

variable "prometheus_helm_atomic" {
  description = "Determines whether Helm rolls back a failed Prometheus installation or upgrade."
  type        = bool
  default     = true
}

variable "prometheus_helm_cleanup_on_fail" {
  description = "Determines whether Helm removes newly created resources after a failed upgrade."
  type        = bool
  default     = true
}

variable "prometheus_helm_force_update" {
  description = "Determines whether Helm forces Prometheus resource updates."
  type        = bool
  default     = false
}

variable "prometheus_helm_recreate_pods" {
  description = "Determines whether Helm recreates Prometheus pods during an upgrade."
  type        = bool
  default     = false
}

variable "prometheus_helm_dependency_update" {
  description = "Determines whether Helm updates chart dependencies before installation."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Prometheus Server Configuration
# -----------------------------------------------------------------------------

variable "prometheus_enabled" {
  description = "Determines whether the Prometheus server is enabled."
  type        = bool
  default     = true
}

variable "prometheus_replicas" {
  description = "Number of Prometheus server replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.prometheus_replicas >= 1
    error_message = "prometheus_replicas must be at least 1."
  }
}

variable "prometheus_retention" {
  description = "Length of time Prometheus retains metrics."
  type        = string
  default     = "15d"

  validation {
    condition     = can(regex("^[0-9]+(h|d|w|y)$", var.prometheus_retention))
    error_message = "prometheus_retention must use a duration such as 15d."
  }
}

variable "prometheus_retention_size" {
  description = "Maximum amount of disk space Prometheus may use for retained metrics."
  type        = string
  default     = "45GB"

  validation {
    condition = can(
      regex(
        "^[0-9]+(MB|GB|TB)$",
        var.prometheus_retention_size
      )
    )

    error_message = "prometheus_retention_size must use a value such as 45GB."
  }
}

variable "prometheus_scrape_interval" {
  description = "Default interval at which Prometheus scrapes monitoring targets."
  type        = string
  default     = "30s"

  validation {
    condition = can(
      regex(
        "^[0-9]+(s|m|h)$",
        var.prometheus_scrape_interval
      )
    )

    error_message = "prometheus_scrape_interval must use a duration such as 30s."
  }
}

variable "prometheus_evaluation_interval" {
  description = "Default interval at which Prometheus evaluates alerting and recording rules."
  type        = string
  default     = "30s"

  validation {
    condition = can(
      regex(
        "^[0-9]+(s|m|h)$",
        var.prometheus_evaluation_interval
      )
    )

    error_message = "prometheus_evaluation_interval must use a duration such as 30s."
  }
}

variable "prometheus_enable_admin_api" {
  description = "Determines whether the Prometheus administrative API is enabled."
  type        = bool
  default     = false
}

variable "prometheus_external_url" {
  description = "Optional external URL used by Prometheus when generating links."
  type        = string
  default     = ""
}

variable "prometheus_route_prefix" {
  description = "HTTP route prefix used by the Prometheus web interface."
  type        = string
  default     = "/"
}

# -----------------------------------------------------------------------------
# Prometheus Resource Configuration
# -----------------------------------------------------------------------------

variable "prometheus_cpu_request" {
  description = "CPU requested by the Prometheus server."
  type        = string
  default     = "500m"
}

variable "prometheus_memory_request" {
  description = "Memory requested by the Prometheus server."
  type        = string
  default     = "2Gi"
}

variable "prometheus_cpu_limit" {
  description = "Maximum CPU available to the Prometheus server."
  type        = string
  default     = "2"
}

variable "prometheus_memory_limit" {
  description = "Maximum memory available to the Prometheus server."
  type        = string
  default     = "4Gi"
}

# -----------------------------------------------------------------------------
# Prometheus Persistent Storage Configuration
# -----------------------------------------------------------------------------

variable "prometheus_persistence_enabled" {
  description = "Determines whether persistent storage is enabled for Prometheus."
  type        = bool
  default     = true
}

variable "prometheus_storage_class_name" {
  description = "Kubernetes StorageClass used by the Prometheus persistent volume."
  type        = string
  default     = "gp3"
}

variable "prometheus_storage_size" {
  description = "Persistent volume size allocated to Prometheus."
  type        = string
  default     = "50Gi"

  validation {
    condition = can(
      regex(
        "^[0-9]+(Mi|Gi|Ti)$",
        var.prometheus_storage_size
      )
    )

    error_message = "prometheus_storage_size must use a value such as 50Gi."
  }
}

variable "prometheus_storage_access_modes" {
  description = "Kubernetes access modes assigned to the Prometheus persistent volume."
  type        = list(string)
  default     = ["ReadWriteOnce"]
}

# -----------------------------------------------------------------------------
# Prometheus Resource Discovery Configuration
# -----------------------------------------------------------------------------

variable "prometheus_service_monitor_selector_nil_uses_helm_values" {
  description = "Determines whether an empty ServiceMonitor selector uses Helm release labels."
  type        = bool
  default     = false
}

variable "prometheus_pod_monitor_selector_nil_uses_helm_values" {
  description = "Determines whether an empty PodMonitor selector uses Helm release labels."
  type        = bool
  default     = false
}

variable "prometheus_rule_selector_nil_uses_helm_values" {
  description = "Determines whether an empty PrometheusRule selector uses Helm release labels."
  type        = bool
  default     = false
}

variable "prometheus_service_monitor_namespace_selector" {
  description = "Namespace labels used to select ServiceMonitor resources."
  type        = map(string)
  default     = {}
}

variable "prometheus_pod_monitor_namespace_selector" {
  description = "Namespace labels used to select PodMonitor resources."
  type        = map(string)
  default     = {}
}

variable "prometheus_rule_namespace_selector" {
  description = "Namespace labels used to select PrometheusRule resources."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Prometheus Operator Configuration
# -----------------------------------------------------------------------------

variable "prometheus_operator_enabled" {
  description = "Determines whether the Prometheus Operator is enabled."
  type        = bool
  default     = true
}

variable "prometheus_operator_cpu_request" {
  description = "CPU requested by the Prometheus Operator."
  type        = string
  default     = "100m"
}

variable "prometheus_operator_memory_request" {
  description = "Memory requested by the Prometheus Operator."
  type        = string
  default     = "128Mi"
}

variable "prometheus_operator_cpu_limit" {
  description = "Maximum CPU available to the Prometheus Operator."
  type        = string
  default     = "500m"
}

variable "prometheus_operator_memory_limit" {
  description = "Maximum memory available to the Prometheus Operator."
  type        = string
  default     = "512Mi"
}

# -----------------------------------------------------------------------------
# Alertmanager Configuration
# -----------------------------------------------------------------------------

variable "alertmanager_enabled" {
  description = "Determines whether Alertmanager is enabled."
  type        = bool
  default     = true
}

variable "alertmanager_replicas" {
  description = "Number of Alertmanager replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.alertmanager_replicas >= 1
    error_message = "alertmanager_replicas must be at least 1."
  }
}

variable "alertmanager_cpu_request" {
  description = "CPU requested by Alertmanager."
  type        = string
  default     = "100m"
}

variable "alertmanager_memory_request" {
  description = "Memory requested by Alertmanager."
  type        = string
  default     = "128Mi"
}

variable "alertmanager_cpu_limit" {
  description = "Maximum CPU available to Alertmanager."
  type        = string
  default     = "500m"
}

variable "alertmanager_memory_limit" {
  description = "Maximum memory available to Alertmanager."
  type        = string
  default     = "512Mi"
}

variable "alertmanager_persistence_enabled" {
  description = "Determines whether persistent storage is enabled for Alertmanager."
  type        = bool
  default     = true
}

variable "alertmanager_storage_class_name" {
  description = "Kubernetes StorageClass used by the Alertmanager persistent volume."
  type        = string
  default     = "gp3"
}

variable "alertmanager_storage_size" {
  description = "Persistent volume size allocated to Alertmanager."
  type        = string
  default     = "10Gi"

  validation {
    condition = can(
      regex(
        "^[0-9]+(Mi|Gi|Ti)$",
        var.alertmanager_storage_size
      )
    )

    error_message = "alertmanager_storage_size must use a value such as 10Gi."
  }
}

# -----------------------------------------------------------------------------
# Kubernetes Monitoring Components
# -----------------------------------------------------------------------------

variable "prometheus_default_rules_enabled" {
  description = "Determines whether default Kubernetes recording and alerting rules are enabled."
  type        = bool
  default     = true
}

variable "prometheus_kube_state_metrics_enabled" {
  description = "Determines whether kube-state-metrics is enabled."
  type        = bool
  default     = true
}

variable "prometheus_node_exporter_enabled" {
  description = "Determines whether Prometheus Node Exporter is enabled."
  type        = bool
  default     = true
}

variable "prometheus_kube_api_server_monitoring_enabled" {
  description = "Determines whether Kubernetes API server monitoring is enabled."
  type        = bool
  default     = true
}

variable "prometheus_kubelet_monitoring_enabled" {
  description = "Determines whether kubelet monitoring is enabled."
  type        = bool
  default     = true
}

variable "prometheus_core_dns_monitoring_enabled" {
  description = "Determines whether CoreDNS monitoring is enabled."
  type        = bool
  default     = true
}

variable "prometheus_kube_controller_manager_monitoring_enabled" {
  description = "Determines whether controller manager monitoring is enabled."
  type        = bool
  default     = false
}

variable "prometheus_kube_scheduler_monitoring_enabled" {
  description = "Determines whether Kubernetes scheduler monitoring is enabled."
  type        = bool
  default     = false
}

variable "prometheus_kube_proxy_monitoring_enabled" {
  description = "Determines whether kube-proxy monitoring is enabled."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# kube-state-metrics Resource Configuration
# -----------------------------------------------------------------------------

variable "prometheus_kube_state_metrics_cpu_request" {
  description = "CPU requested by kube-state-metrics."
  type        = string
  default     = "50m"
}

variable "prometheus_kube_state_metrics_memory_request" {
  description = "Memory requested by kube-state-metrics."
  type        = string
  default     = "128Mi"
}

variable "prometheus_kube_state_metrics_cpu_limit" {
  description = "Maximum CPU available to kube-state-metrics."
  type        = string
  default     = "250m"
}

variable "prometheus_kube_state_metrics_memory_limit" {
  description = "Maximum memory available to kube-state-metrics."
  type        = string
  default     = "256Mi"
}

# -----------------------------------------------------------------------------
# Node Exporter Resource Configuration
# -----------------------------------------------------------------------------

variable "prometheus_node_exporter_cpu_request" {
  description = "CPU requested by Prometheus Node Exporter."
  type        = string
  default     = "50m"
}

variable "prometheus_node_exporter_memory_request" {
  description = "Memory requested by Prometheus Node Exporter."
  type        = string
  default     = "64Mi"
}

variable "prometheus_node_exporter_cpu_limit" {
  description = "Maximum CPU available to Prometheus Node Exporter."
  type        = string
  default     = "200m"
}

variable "prometheus_node_exporter_memory_limit" {
  description = "Maximum memory available to Prometheus Node Exporter."
  type        = string
  default     = "128Mi"
}

# =============================================================================
# Grafana Phase 2 Configuration
# =============================================================================
# The following variables configure Grafana as the visualization layer for the
# CloudHustler Commerce Platform monitoring stack.
#
# Grafana is deployed through the kube-prometheus-stack Helm chart and uses
# Prometheus as its default metrics data source.
# =============================================================================

# -----------------------------------------------------------------------------
# Grafana Deployment
# -----------------------------------------------------------------------------

variable "grafana_enabled" {
  description = "Controls whether Grafana is deployed as part of the monitoring stack."
  type        = bool
  default     = true
}

variable "grafana_replicas" {
  description = "Number of Grafana replicas to deploy."
  type        = number
  default     = 1

  validation {
    condition     = var.grafana_replicas >= 1
    error_message = "grafana_replicas must be at least 1."
  }
}

# -----------------------------------------------------------------------------
# Grafana Administrative Credentials
# -----------------------------------------------------------------------------

variable "grafana_admin_user" {
  description = "Grafana administrator username stored in the Kubernetes Secret."
  type        = string
  default     = "admin"

  validation {
    condition     = length(trimspace(var.grafana_admin_user)) > 0
    error_message = "grafana_admin_user cannot be empty."
  }
}

variable "grafana_admin_password" {
  description = "Grafana administrator password stored in the Kubernetes Secret."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.grafana_admin_password) >= 12
    error_message = "grafana_admin_password must contain at least 12 characters."
  }
}

# -----------------------------------------------------------------------------
# Grafana Persistent Storage
# -----------------------------------------------------------------------------

variable "grafana_persistence_enabled" {
  description = "Controls whether Grafana uses persistent storage."
  type        = bool
  default     = true
}

variable "grafana_storage_class_name" {
  description = "Kubernetes StorageClass used by the Grafana persistent volume."
  type        = string
  default     = "gp3"

  validation {
    condition     = length(trimspace(var.grafana_storage_class_name)) > 0
    error_message = "grafana_storage_class_name cannot be empty."
  }
}

variable "grafana_storage_access_modes" {
  description = "Access modes requested by the Grafana persistent volume claim."
  type        = list(string)
  default     = ["ReadWriteOnce"]

  validation {
    condition     = length(var.grafana_storage_access_modes) > 0
    error_message = "grafana_storage_access_modes must contain at least one access mode."
  }
}

variable "grafana_storage_size" {
  description = "Persistent volume capacity requested for Grafana."
  type        = string
  default     = "10Gi"

  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi|Ti)$", var.grafana_storage_size))
    error_message = "grafana_storage_size must use a Kubernetes quantity such as 10Gi."
  }
}

# -----------------------------------------------------------------------------
# Grafana Service and Access
# -----------------------------------------------------------------------------

variable "grafana_service_type" {
  description = "Kubernetes Service type used to expose Grafana."
  type        = string
  default     = "ClusterIP"

  validation {
    condition = contains(
      ["ClusterIP", "NodePort", "LoadBalancer"],
      var.grafana_service_type
    )

    error_message = "grafana_service_type must be ClusterIP, NodePort, or LoadBalancer."
  }
}

variable "grafana_service_port" {
  description = "Port exposed by the Grafana Kubernetes Service."
  type        = number
  default     = 80

  validation {
    condition = (
      var.grafana_service_port >= 1 &&
      var.grafana_service_port <= 65535
    )

    error_message = "grafana_service_port must be between 1 and 65535."
  }
}

variable "grafana_ingress_enabled" {
  description = "Controls whether the Grafana Helm subchart creates a Kubernetes Ingress."
  type        = bool
  default     = false
}

variable "grafana_root_url" {
  description = "Externally accessible Grafana URL. Leave empty while using port forwarding."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Grafana Dashboard Provisioning
# -----------------------------------------------------------------------------

variable "grafana_default_dashboards_enabled" {
  description = "Controls whether kube-prometheus-stack Kubernetes dashboards are provisioned."
  type        = bool
  default     = true
}

variable "grafana_default_dashboards_timezone" {
  description = "Timezone used by the default Kubernetes Grafana dashboards."
  type        = string
  default     = "browser"

  validation {
    condition     = length(trimspace(var.grafana_default_dashboards_timezone)) > 0
    error_message = "grafana_default_dashboards_timezone cannot be empty."
  }
}

variable "grafana_sidecar_dashboards_enabled" {
  description = "Enables the Grafana sidecar that discovers dashboard ConfigMaps."
  type        = bool
  default     = true
}

variable "grafana_sidecar_datasources_enabled" {
  description = "Enables the Grafana sidecar that discovers datasource ConfigMaps."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Grafana Security Configuration
# -----------------------------------------------------------------------------

variable "grafana_disable_initial_admin_creation" {
  description = "Disables creation of the initial Grafana administrator account."
  type        = bool
  default     = false
}

variable "grafana_allow_sign_up" {
  description = "Controls whether anonymous users may register Grafana accounts."
  type        = bool
  default     = false
}

variable "grafana_anonymous_access_enabled" {
  description = "Controls whether Grafana permits anonymous access."
  type        = bool
  default     = false
}

variable "grafana_user_auto_assign_org_role" {
  description = "Default organization role assigned to automatically created Grafana users."
  type        = string
  default     = "Viewer"

  validation {
    condition = contains(
      ["Viewer", "Editor", "Admin"],
      var.grafana_user_auto_assign_org_role
    )

    error_message = "grafana_user_auto_assign_org_role must be Viewer, Editor, or Admin."
  }
}

# -----------------------------------------------------------------------------
# Grafana Resource Allocation
# -----------------------------------------------------------------------------

variable "grafana_cpu_request" {
  description = "CPU requested by the Grafana container."
  type        = string
  default     = "100m"
}

variable "grafana_memory_request" {
  description = "Memory requested by the Grafana container."
  type        = string
  default     = "256Mi"
}

variable "grafana_cpu_limit" {
  description = "Maximum CPU available to the Grafana container."
  type        = string
  default     = "500m"
}

variable "grafana_memory_limit" {
  description = "Maximum memory available to the Grafana container."
  type        = string
  default     = "512Mi"
}

# =============================================================================
# Istio Monitoring
# =============================================================================

variable "istiod_service_monitor_enabled" {
  description = "Controls whether the Istiod ServiceMonitor is created."
  type        = bool
  default     = true
}


variable "istiod_metrics_port_name" {
  description = "Name of the Istiod Service port exposing Prometheus metrics."
  type        = string
  default     = "http-monitoring"
}

variable "istiod_metrics_path" {
  description = "HTTP path used to scrape Istiod metrics."
  type        = string
  default     = "/metrics"
}

variable "istiod_scrape_interval" {
  description = "Interval at which Prometheus scrapes Istiod metrics."
  type        = string
  default     = "30s"
}

variable "istiod_scrape_timeout" {
  description = "Maximum duration allowed for each Istiod metrics scrape."
  type        = string
  default     = "10s"
}

# =============================================================================
# Istio Ingress Gateway Monitoring
# =============================================================================

variable "istio_ingress_pod_monitor_enabled" {
  description = "Controls whether the Istio ingress gateway PodMonitor is created."
  type        = bool
  default     = true
}

variable "istio_ingress_namespace" {
  description = "Kubernetes namespace containing the Istio ingress gateway."
  type        = string
  default     = "istio-ingress"
  nullable    = false
}

variable "istio_ingress_app_name" {
  description = "Application label used to select the Istio ingress gateway pods."
  type        = string
  default     = "istio-ingress"
  nullable    = false
}

variable "istio_ingress_metrics_port" {
  description = "Container port exposing Istio ingress gateway Prometheus metrics."
  type        = number
  default     = 15020
}

variable "istio_ingress_metrics_path" {
  description = "HTTP path exposing Istio ingress gateway Prometheus metrics."
  type        = string
  default     = "/stats/prometheus"
  nullable    = false
}

variable "istio_ingress_scrape_interval" {
  description = "Interval at which Prometheus scrapes Istio ingress gateway metrics."
  type        = string
  default     = "30s"
  nullable    = false
}

variable "istio_ingress_scrape_timeout" {
  description = "Maximum duration allowed for each ingress gateway scrape."
  type        = string
  default     = "10s"
  nullable    = false
}

# =============================================================================
# Fluent Bit
# =============================================================================

variable "fluent_bit_release_name" {
  type    = string
  default = "fluent-bit"
}

variable "fluent_bit_namespace" {
  type    = string
  default = "logging"
}

variable "fluent_bit_chart_version" {
  type    = string
  default = "0.57.9"
}

variable "fluent_bit_create_namespace" {
  type    = bool
  default = true
}

variable "fluent_bit_log_level" {
  type    = string
  default = "info"
}

variable "fluent_bit_service_monitor_enabled" {
  type    = bool
  default = true
}

variable "fluent_bit_scrape_interval" {
  type    = string
  default = "30s"
}

variable "fluent_bit_cpu_request" {
  type    = string
  default = "50m"
}

variable "fluent_bit_memory_request" {
  type    = string
  default = "64Mi"
}

variable "fluent_bit_cpu_limit" {
  type    = string
  default = "200m"
}

variable "fluent_bit_memory_limit" {
  type    = string
  default = "256Mi"
}

variable "fluent_bit_timeout" {
  type    = number
  default = 900
}

variable "fluent_bit_atomic" {
  type    = bool
  default = false
}

# -----------------------------------------------------------------------------
# Loki Namespace Configuration
# -----------------------------------------------------------------------------

variable "loki_namespace" {
  description = "Kubernetes namespace where Loki will be deployed."
  type        = string
  default     = "logging"
}

# -----------------------------------------------------------------------------
# Loki Helm Configuration
# -----------------------------------------------------------------------------

variable "loki_release_name" {
  description = "Name of the Loki Helm release."
  type        = string
  default     = "loki"
}

variable "loki_chart_version" {
  description = "Pinned version of the Grafana Loki Helm chart."
  type        = string
  default     = "7.2.0"
}

variable "loki_timeout" {
  description = "Maximum time in seconds allowed for the Loki Helm deployment."
  type        = number
  default     = 1200
}

variable "loki_atomic" {
  description = "Whether Helm should automatically roll back the Loki release when deployment fails."
  type        = bool
  default     = false
}

variable "loki_cleanup_on_fail" {
  description = "Whether Helm should remove newly created Loki resources after a failed deployment."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Loki Storage Configuration
# -----------------------------------------------------------------------------

variable "loki_storage_class_name" {
  description = "Kubernetes StorageClass used for Loki persistent storage."
  type        = string
  default     = "gp3"
}

variable "loki_storage_size" {
  description = "Persistent volume size allocated to Loki."
  type        = string
  default     = "20Gi"
}

variable "loki_retention_period" {
  description = "Length of time Loki retains log data."
  type        = string
  default     = "168h"
}

variable "loki_schema_start_date" {
  description = "Start date used by the Loki TSDB schema configuration."
  type        = string
  default     = "2024-01-01"
}

# -----------------------------------------------------------------------------
# Loki Ingestion and Query Limits
# -----------------------------------------------------------------------------

variable "loki_ingestion_rate_mb" {
  description = "Maximum sustained Loki log ingestion rate in megabytes per second."
  type        = number
  default     = 4
}

variable "loki_ingestion_burst_size_mb" {
  description = "Maximum Loki log ingestion burst size in megabytes."
  type        = number
  default     = 8
}

variable "loki_max_query_parallelism" {
  description = "Maximum number of Loki query operations that can run in parallel."
  type        = number
  default     = 16
}

variable "loki_max_query_series" {
  description = "Maximum number of series returned by a Loki metric query."
  type        = number
  default     = 500
}

variable "loki_reject_old_samples_max_age" {
  description = "Maximum accepted age for incoming Loki log entries."
  type        = string
  default     = "168h"
}

variable "loki_per_stream_rate_limit" {
  description = "Maximum sustained ingestion rate allowed for an individual Loki log stream."
  type        = string
  default     = "5MB"
}

variable "loki_per_stream_rate_limit_burst" {
  description = "Maximum ingestion burst allowed for an individual Loki log stream."
  type        = string
  default     = "15MB"
}

# -----------------------------------------------------------------------------
# Loki Retention and Compaction
# -----------------------------------------------------------------------------

variable "loki_compaction_interval" {
  description = "Interval at which the Loki compactor runs."
  type        = string
  default     = "10m"
}

variable "loki_retention_delete_delay" {
  description = "Delay between identifying expired Loki data and deleting it."
  type        = string
  default     = "2h"
}

# -----------------------------------------------------------------------------
# Loki Replica Configuration
# -----------------------------------------------------------------------------

variable "loki_replica_count" {
  description = "Number of Loki SingleBinary replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.loki_replica_count >= 1
    error_message = "loki_replica_count must be at least 1."
  }
}

# -----------------------------------------------------------------------------
# Loki Resource Configuration
# -----------------------------------------------------------------------------

variable "loki_cpu_request" {
  description = "CPU requested by the Loki SingleBinary container."
  type        = string
  default     = "200m"
}

variable "loki_memory_request" {
  description = "Memory requested by the Loki SingleBinary container."
  type        = string
  default     = "512Mi"
}

variable "loki_cpu_limit" {
  description = "Maximum CPU available to the Loki SingleBinary container."
  type        = string
  default     = "1000m"
}

variable "loki_memory_limit" {
  description = "Maximum memory available to the Loki SingleBinary container."
  type        = string
  default     = "2Gi"
}

# -----------------------------------------------------------------------------
# Loki Gateway Resource Configuration
# -----------------------------------------------------------------------------

variable "loki_gateway_cpu_request" {
  description = "CPU requested by the Loki gateway container."
  type        = string
  default     = "50m"
}

variable "loki_gateway_memory_request" {
  description = "Memory requested by the Loki gateway container."
  type        = string
  default     = "64Mi"
}

variable "loki_gateway_cpu_limit" {
  description = "Maximum CPU available to the Loki gateway container."
  type        = string
  default     = "250m"
}

variable "loki_gateway_memory_limit" {
  description = "Maximum memory available to the Loki gateway container."
  type        = string
  default     = "256Mi"
}

# -----------------------------------------------------------------------------
# Loki Canary Resource Configuration
# -----------------------------------------------------------------------------

variable "loki_canary_cpu_request" {
  description = "CPU requested by each Loki Canary container."
  type        = string
  default     = "25m"
}

variable "loki_canary_memory_request" {
  description = "Memory requested by each Loki Canary container."
  type        = string
  default     = "64Mi"
}

variable "loki_canary_cpu_limit" {
  description = "Maximum CPU available to each Loki Canary container."
  type        = string
  default     = "200m"
}

variable "loki_canary_memory_limit" {
  description = "Maximum memory available to each Loki Canary container."
  type        = string
  default     = "128Mi"
}

# -----------------------------------------------------------------------------
# Loki Kubernetes Scheduling Configuration
# -----------------------------------------------------------------------------

variable "loki_node_selector" {
  description = "Node labels used to control Loki pod placement."
  type        = map(string)
  default     = {}
}

variable "loki_tolerations" {
  description = "Kubernetes tolerations assigned to Loki pods."
  type        = list(any)
  default     = []
}

variable "loki_affinity" {
  description = "Kubernetes affinity configuration assigned to Loki pods."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# Loki Monitoring Configuration
# -----------------------------------------------------------------------------

variable "loki_service_monitor_enabled" {
  description = "Whether Loki should create a Prometheus ServiceMonitor."
  type        = bool
  default     = true
}

variable "loki_service_monitor_interval" {
  description = "Prometheus scrape interval used by the Loki ServiceMonitor."
  type        = string
  default     = "30s"
}

variable "loki_canary_enabled" {
  description = "Whether the Loki Canary workload should be deployed."
  type        = bool
  default     = true
}

# =============================================================================
# Kiali Configuration
#
# These variables configure the Kiali deployment used to visualize and manage
# the Istio service mesh for the CloudHustler Commerce Platform.
# =============================================================================

# -----------------------------------------------------------------------------
# Namespace Configuration
# -----------------------------------------------------------------------------

variable "kiali_namespace" {
  description = "Kubernetes namespace where Kiali will be deployed."
  type        = string
  default     = "istio-system"
}

# -----------------------------------------------------------------------------
# Helm Configuration
# -----------------------------------------------------------------------------

variable "kiali_release_name" {
  description = "Name of the Kiali Helm release."
  type        = string
  default     = "kiali"
}

variable "kiali_chart_version" {
  description = "Pinned version of the Kiali Server Helm chart."
  type        = string
}

variable "kiali_timeout" {
  description = "Maximum time in seconds allowed for the Kiali Helm deployment."
  type        = number
  default     = 900
}

variable "kiali_atomic" {
  description = "Whether Helm should automatically roll back the Kiali release when deployment fails."
  type        = bool
  default     = false
}

variable "kiali_cleanup_on_fail" {
  description = "Whether Helm should remove newly created Kiali resources after a failed deployment."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Authentication Configuration
# -----------------------------------------------------------------------------

variable "kiali_auth_strategy" {
  description = "Authentication strategy used by Kiali."
  type        = string
  default     = "anonymous"

  validation {
    condition = contains(
      [
        "anonymous",
        "openid"
      ],
      var.kiali_auth_strategy
    )

    error_message = "kiali_auth_strategy must be either anonymous or openid."
  }
}

# -----------------------------------------------------------------------------
# Deployment Configuration
# -----------------------------------------------------------------------------

variable "kiali_instance_name" {
  description = "Logical Kiali instance name."
  type        = string
  default     = "kiali"
}

variable "kiali_replica_count" {
  description = "Number of Kiali server replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.kiali_replica_count >= 1
    error_message = "kiali_replica_count must be at least 1."
  }
}

variable "kiali_accessible_namespaces" {
  description = "Namespaces Kiali is allowed to monitor."
  type        = list(string)

  default = [
    "**"
  ]
}

# -----------------------------------------------------------------------------
# Resource Configuration
# -----------------------------------------------------------------------------

variable "kiali_cpu_request" {
  description = "CPU requested by the Kiali container."
  type        = string
  default     = "100m"
}

variable "kiali_memory_request" {
  description = "Memory requested by the Kiali container."
  type        = string
  default     = "128Mi"
}

variable "kiali_cpu_limit" {
  description = "Maximum CPU available to the Kiali container."
  type        = string
  default     = "500m"
}

variable "kiali_memory_limit" {
  description = "Maximum memory available to the Kiali container."
  type        = string
  default     = "512Mi"
}

# -----------------------------------------------------------------------------
# Kubernetes Scheduling Configuration
# -----------------------------------------------------------------------------

variable "kiali_node_selector" {
  description = "Node labels used to control Kiali pod placement."
  type        = map(string)
  default     = {}
}

variable "kiali_tolerations" {
  description = "Kubernetes tolerations assigned to Kiali pods."
  type        = list(any)
  default     = []
}

variable "kiali_affinity" {
  description = "Kubernetes affinity configuration assigned to Kiali pods."
  type        = any
  default     = {}
}

# -----------------------------------------------------------------------------
# Istio Configuration
# -----------------------------------------------------------------------------

variable "kiali_istio_namespace" {
  description = "Namespace containing the Istio control plane."
  type        = string
  default     = "istio-system"
}

# -----------------------------------------------------------------------------
# Prometheus Integration
# -----------------------------------------------------------------------------

variable "kiali_prometheus_url" {
  description = "Internal Prometheus URL used by Kiali."
  type        = string

  default = "http://kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090"
}

# -----------------------------------------------------------------------------
# Grafana Integration
# -----------------------------------------------------------------------------

variable "kiali_grafana_enabled" {
  description = "Whether Kiali should integrate with Grafana."
  type        = bool
  default     = true
}

variable "kiali_grafana_in_cluster_url" {
  description = "Internal Grafana URL used by Kiali."
  type        = string

  default = "http://kube-prometheus-stack-grafana.monitoring.svc.cluster.local"
}

variable "kiali_grafana_external_url" {
  description = "Browser-accessible Grafana URL used in Kiali links."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Distributed Tracing Configuration
# -----------------------------------------------------------------------------

variable "kiali_tracing_enabled" {
  description = "Whether Kiali tracing integration is enabled."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Server Configuration
# -----------------------------------------------------------------------------

variable "kiali_server_port" {
  description = "Port exposed by the Kiali server."
  type        = number
  default     = 20001
}

variable "kiali_web_root" {
  description = "Base path used by the Kiali web application."
  type        = string
  default     = "/"
}

variable "kiali_metrics_enabled" {
  description = "Whether Kiali exposes Prometheus metrics."
  type        = bool
  default     = true
}

variable "kiali_metrics_port" {
  description = "Port used for Kiali Prometheus metrics."
  type        = number
  default     = 9090
}

# -----------------------------------------------------------------------------
# Kubernetes Service Configuration
# -----------------------------------------------------------------------------

variable "kiali_service_type" {
  description = "Kubernetes Service type used for Kiali."
  type        = string
  default     = "ClusterIP"

  validation {
    condition = contains(
      [
        "ClusterIP",
        "NodePort",
        "LoadBalancer"
      ],
      var.kiali_service_type
    )

    error_message = "kiali_service_type must be ClusterIP, NodePort, or LoadBalancer."
  }
}

variable "kiali_service_annotations" {
  description = "Additional annotations applied to the Kiali Service."
  type        = map(string)
  default     = {}
}

# =============================================================================
# OpenTelemetry Collector Configuration
#
# These variables configure the centralized OpenTelemetry Collector gateway
# used to receive, enrich, process, and export application metrics and traces.
# =============================================================================

# -----------------------------------------------------------------------------
# Namespace Configuration
# -----------------------------------------------------------------------------

variable "otel_namespace" {
  description = "Kubernetes namespace where the OpenTelemetry Collector is deployed."
  type        = string
  default     = "observability"
}

variable "otel_create_namespace" {
  description = "Whether Terraform should create the OpenTelemetry namespace."
  type        = bool
  default     = true
}

variable "otel_namespace_labels" {
  description = "Additional labels applied to the OpenTelemetry namespace."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Helm Configuration
# -----------------------------------------------------------------------------

variable "otel_release_name" {
  description = "Name of the OpenTelemetry Collector Helm release."
  type        = string
  default     = "opentelemetry-collector"
}

variable "otel_chart_version" {
  description = "Pinned OpenTelemetry Collector Helm chart version."
  type        = string
}

variable "otel_timeout" {
  description = "Maximum time in seconds allowed for the OpenTelemetry Helm deployment."
  type        = number
  default     = 900
}

variable "otel_atomic" {
  description = "Whether Helm should automatically roll back the release when deployment fails."
  type        = bool
  default     = false
}

variable "otel_cleanup_on_fail" {
  description = "Whether Helm should remove newly created resources after a failed deployment."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Collector Image Configuration
# -----------------------------------------------------------------------------

variable "otel_image_repository" {
  description = "OpenTelemetry Collector container image repository."
  type        = string
  default     = "otel/opentelemetry-collector-contrib"
}

variable "otel_image_tag" {
  description = "Pinned OpenTelemetry Collector container image tag."
  type        = string
}

variable "otel_image_pull_policy" {
  description = "Kubernetes image pull policy for the Collector image."
  type        = string
  default     = "IfNotPresent"

  validation {
    condition = contains(
      [
        "Always",
        "IfNotPresent",
        "Never"
      ],
      var.otel_image_pull_policy
    )

    error_message = "otel_image_pull_policy must be Always, IfNotPresent, or Never."
  }
}

# -----------------------------------------------------------------------------
# Deployment Configuration
# -----------------------------------------------------------------------------

variable "otel_replica_count" {
  description = "Number of OpenTelemetry Collector replicas."
  type        = number
  default     = 1

  validation {
    condition     = var.otel_replica_count >= 1
    error_message = "otel_replica_count must be at least 1."
  }
}

variable "otel_service_account_name" {
  description = "Kubernetes service account used by the Collector."
  type        = string
  default     = "opentelemetry-collector"
}

variable "otel_service_account_annotations" {
  description = "Additional annotations applied to the Collector service account."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# OTLP Receiver Ports
# -----------------------------------------------------------------------------

variable "otel_otlp_grpc_port" {
  description = "Port used to receive OTLP telemetry over gRPC."
  type        = number
  default     = 4317
}

variable "otel_otlp_http_port" {
  description = "Port used to receive OTLP telemetry over HTTP."
  type        = number
  default     = 4318
}

# -----------------------------------------------------------------------------
# Collector Operational Ports
# -----------------------------------------------------------------------------

variable "otel_prometheus_exporter_port" {
  description = "Port exposing OTLP application metrics for Prometheus."
  type        = number
  default     = 8889
}

variable "otel_internal_metrics_port" {
  description = "Port exposing Collector internal operational metrics."
  type        = number
  default     = 8888
}

variable "otel_health_check_port" {
  description = "Port used by the Collector health-check extension."
  type        = number
  default     = 13133
}

variable "otel_zpages_enabled" {
  description = "Whether the Collector zPages diagnostic extension is enabled."
  type        = bool
  default     = true
}

variable "otel_zpages_port" {
  description = "Port used by the Collector zPages extension."
  type        = number
  default     = 55679
}

# -----------------------------------------------------------------------------
# Memory Limiter Configuration
# -----------------------------------------------------------------------------

variable "otel_memory_limiter_check_interval" {
  description = "Interval at which the Collector memory limiter checks usage."
  type        = string
  default     = "5s"
}

variable "otel_memory_limiter_limit_percentage" {
  description = "Maximum percentage of available memory the Collector may use."
  type        = number
  default     = 80

  validation {
    condition = (
      var.otel_memory_limiter_limit_percentage > 0 &&
      var.otel_memory_limiter_limit_percentage <= 100
    )

    error_message = "otel_memory_limiter_limit_percentage must be between 1 and 100."
  }
}

variable "otel_memory_limiter_spike_limit_percentage" {
  description = "Percentage of memory reserved for temporary usage spikes."
  type        = number
  default     = 25

  validation {
    condition = (
      var.otel_memory_limiter_spike_limit_percentage >= 0 &&
      var.otel_memory_limiter_spike_limit_percentage <= 100
    )

    error_message = "otel_memory_limiter_spike_limit_percentage must be between 0 and 100."
  }
}

# -----------------------------------------------------------------------------
# Batch Processor Configuration
# -----------------------------------------------------------------------------

variable "otel_batch_timeout" {
  description = "Maximum time telemetry remains in a batch before export."
  type        = string
  default     = "5s"
}

variable "otel_batch_send_size" {
  description = "Preferred number of telemetry items sent per batch."
  type        = number
  default     = 512
}

variable "otel_batch_max_size" {
  description = "Maximum number of telemetry items allowed in one batch."
  type        = number
  default     = 1024
}

# -----------------------------------------------------------------------------
# Prometheus Integration
# -----------------------------------------------------------------------------

variable "otel_prometheus_namespace" {
  description = "Metric prefix used by the Collector Prometheus exporter."
  type        = string
  default     = "cloudhusller"
}

variable "otel_prometheus_scrape_enabled" {
  description = "Whether Prometheus pod-scrape annotations are enabled."
  type        = bool
  default     = true
}

variable "otel_service_monitor_enabled" {
  description = "Whether the Collector creates a Prometheus ServiceMonitor."
  type        = bool
  default     = true
}

variable "otel_service_monitor_interval" {
  description = "Prometheus scrape interval for Collector operational metrics."
  type        = string
  default     = "30s"
}

# -----------------------------------------------------------------------------
# AWS X-Ray Integration
# -----------------------------------------------------------------------------

variable "otel_aws_xray_enabled" {
  description = "Whether distributed traces are exported to AWS X-Ray."
  type        = bool
  default     = false
}

variable "otel_aws_xray_indexed_attributes" {
  description = "Trace attributes indexed as AWS X-Ray annotations."
  type        = list(string)

  default = [
    "service.name",
    "service.namespace",
    "deployment.environment.name",
    "k8s.namespace.name",
    "k8s.pod.name"
  ]
}

variable "otel_debug_exporter_verbosity" {
  description = "Debug trace exporter verbosity when AWS X-Ray is disabled."
  type        = string
  default     = "basic"

  validation {
    condition = contains(
      [
        "basic",
        "normal",
        "detailed"
      ],
      var.otel_debug_exporter_verbosity
    )

    error_message = "otel_debug_exporter_verbosity must be basic, normal, or detailed."
  }
}

# -----------------------------------------------------------------------------
# IAM Configuration
# -----------------------------------------------------------------------------

variable "otel_iam_role_name" {
  description = "IAM role used by the Collector for AWS X-Ray export."
  type        = string
}

variable "otel_iam_policy_name" {
  description = "IAM policy used by the Collector for AWS X-Ray export."
  type        = string
}

variable "otel_permissions_boundary_arn" {
  description = "Optional IAM permissions boundary applied to the Collector role."
  type        = string
  default     = null
}

variable "otel_iam_tags" {
  description = "Additional tags applied to Collector IAM resources."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Collector Logging
# -----------------------------------------------------------------------------

variable "otel_collector_log_level" {
  description = "OpenTelemetry Collector internal log level."
  type        = string
  default     = "info"

  validation {
    condition = contains(
      [
        "debug",
        "info",
        "warn",
        "error"
      ],
      var.otel_collector_log_level
    )

    error_message = "otel_collector_log_level must be debug, info, warn, or error."
  }
}

# -----------------------------------------------------------------------------
# Kubernetes Service Configuration
# -----------------------------------------------------------------------------

variable "otel_service_type" {
  description = "Kubernetes Service type used by the Collector."
  type        = string
  default     = "ClusterIP"

  validation {
    condition = contains(
      [
        "ClusterIP",
        "NodePort",
        "LoadBalancer"
      ],
      var.otel_service_type
    )

    error_message = "otel_service_type must be ClusterIP, NodePort, or LoadBalancer."
  }
}

# -----------------------------------------------------------------------------
# Resource Configuration
# -----------------------------------------------------------------------------

variable "otel_cpu_request" {
  description = "CPU requested by each Collector pod."
  type        = string
  default     = "100m"
}

variable "otel_memory_request" {
  description = "Memory requested by each Collector pod."
  type        = string
  default     = "256Mi"
}

variable "otel_cpu_limit" {
  description = "Maximum CPU available to each Collector pod."
  type        = string
  default     = "500m"
}

variable "otel_memory_limit" {
  description = "Maximum memory available to each Collector pod."
  type        = string
  default     = "512Mi"
}

# -----------------------------------------------------------------------------
# Horizontal Pod Autoscaling
# -----------------------------------------------------------------------------

variable "otel_autoscaling_enabled" {
  description = "Whether Horizontal Pod Autoscaling is enabled."
  type        = bool
  default     = false
}

variable "otel_autoscaling_min_replicas" {
  description = "Minimum Collector replicas when autoscaling is enabled."
  type        = number
  default     = 1
}

variable "otel_autoscaling_max_replicas" {
  description = "Maximum Collector replicas when autoscaling is enabled."
  type        = number
  default     = 3
}

variable "otel_autoscaling_cpu_target" {
  description = "Target average CPU utilization percentage for autoscaling."
  type        = number
  default     = 70
}

# -----------------------------------------------------------------------------
# Kubernetes Scheduling Configuration
# -----------------------------------------------------------------------------

variable "otel_node_selector" {
  description = "Node labels used to control Collector pod placement."
  type        = map(string)
  default     = {}
}

variable "otel_tolerations" {
  description = "Kubernetes tolerations assigned to Collector pods."
  type        = list(any)
  default     = []
}

variable "otel_affinity" {
  description = "Kubernetes affinity configuration assigned to Collector pods."
  type        = any
  default     = {}
}

# =============================================================================
# Grafana Dashboards
# =============================================================================

# -----------------------------------------------------------------------------
# Namespace Configuration
# -----------------------------------------------------------------------------

variable "grafana_dashboards_namespace" {
  description = "Namespace containing Grafana dashboard ConfigMaps."
  type        = string
  default     = "monitoring"
}

# -----------------------------------------------------------------------------
# ConfigMap Naming
# -----------------------------------------------------------------------------

variable "grafana_dashboard_configmap_prefix" {
  description = "Prefix applied to every Grafana dashboard ConfigMap."
  type        = string
  default     = "cloudhusller-dashboard"
}

# -----------------------------------------------------------------------------
# Dashboard Folder
# -----------------------------------------------------------------------------

variable "grafana_dashboard_folder" {
  description = "Grafana folder containing the CloudHustler dashboards."
  type        = string
  default     = "CloudHustler Platform"
}

# -----------------------------------------------------------------------------
# Dashboard Sidecar Discovery
# -----------------------------------------------------------------------------

variable "grafana_dashboard_sidecar_label" {
  description = "ConfigMap label watched by the Grafana dashboard sidecar."
  type        = string
  default     = "grafana_dashboard"
}

variable "grafana_dashboard_sidecar_label_value" {
  description = "Value assigned to the Grafana dashboard discovery label."
  type        = string
  default     = "1"
}

# -----------------------------------------------------------------------------
# Dashboard Metadata
# -----------------------------------------------------------------------------

variable "grafana_dashboard_labels" {
  description = "Additional labels applied to all Grafana dashboard ConfigMaps."
  type        = map(string)

  default = {}
}

variable "grafana_dashboard_annotations" {
  description = "Additional annotations applied to all Grafana dashboard ConfigMaps."
  type        = map(string)

  default = {}
}