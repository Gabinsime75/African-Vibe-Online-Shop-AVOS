# AVOS Development Reconciliation

## Synchronization

The development ApplicationSet template and standalone load-generator
Application enable automated sync, pruning, and self-healing.
Empty-application pruning is disabled.

FailOnSharedResource prevents taking over another Application's resources.
PruneLast defers pruning until the final wave after successful synchronization.
Failed syncs have five retries with exponential backoff, starting at five
seconds, a factor of two, and a maximum delay of three minutes.

The Terraform-owned root Application remains manually synchronized.
ApplicationSet-managed policies must be changed in the Git template.

## Resource ordering and health

The shared dev-reconciliation component applies resource-level annotations:

- Wave -20: ServiceAccounts, ConfigMaps, NetworkPolicies, ExternalSecrets.
- Wave -10: Services and PodDisruptionBudgets.
- Wave 0: Deployments, CronJobs, and HorizontalPodAutoscalers.

Waves order resources within each Application. They do not coordinate
startup across separate Applications or prove external dependencies ready.

Argo CD uses built-in resource health assessment. Existing readiness probes
remain in all ten active business-service Deployments.
Wave annotations affect resource metadata, not Pod templates.

The load-generator CronJob remains suspended. Its Application can reconcile
template changes without scheduling test executions.

## Environment boundaries and validation

This policy applies to development. Staging and production policies require
their destination foundations and approval controls before activation.

Local validation rendered all 11 overlays and confirmed that only resource
wave annotations changed in workload manifests. Readiness probes and CronJob
suspension were preserved. Both Application policy changes passed server-side
dry-run validation. Live activation and reconciliation remain to be validated.
