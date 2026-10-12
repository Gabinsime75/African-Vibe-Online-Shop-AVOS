# AVOS Phase 6 — Platform Services Validation

## Status

Platform implementation completed through Step 6.10.
The full Phase 6 validation gate remains partially satisfied.

AVOS platform-services and edge-security were rebuilt from scratch.
Final Terraform plans for both roots returned no changes, exit code 0.

## Implementation and evidence

| Step | Implementation | Validation |
|---|---|---|
| 6.1 | AWS Load Balancer Controller with dedicated EKS Pod Identity | Two ready replicas; controller rollout verified |
| 6.2 | ExternalDNS with scoped Route 53 permissions, annotation selection, TXT ownership, and upsert-only policy | Dry-run and live record synchronization verified; public CNAME resolution verified; test records removed |
| 6.3 | Namespace-scoped External Secrets Operator with dedicated Pod Identity | SecretStore and ExternalSecret ready; Secrets Manager value change synchronized into Kubernetes |
| 6.4 | cert-manager with Route 53 DNS-01 and a Let's Encrypt staging issuer | Certificate issued; manual renewal increased revision and changed certificate serial |
| 6.5 | Istio control plane and Helm-managed ClusterIP ingress gateway | Two ready replicas for each Deployment |
| 6.6 | Standard Gateway API CRDs, Istio Gateway, and test HTTPRoute | Gateway accepted and programmed; test routing returned HTTP 200 |
| 6.7 | Fresh AVOS ALB and IP target group connected through TargetGroupBinding | ALB-to-gateway routing returned HTTP 200; unmatched hostname returned HTTP 404; gateway targets healthy |
| 6.8 | Strict mesh mTLS, gateway HTTP exception, namespace default-deny authorization, and service resilience defaults | Approved identity allowed; unapproved identity denied; plaintext rejected; timeout, bounded retries, endpoint ejection, and recovery tested |
| 6.9 | Controller PDBs, node/zone spread, revision-aware placement, Istio priority, and ESO health probes | Rollouts and rendered settings verified; replicated components observed on separate nodes |
| 6.10 | Ingress ownership and duplicate-controller review | No duplicate ingress controllers or legacy routing objects; binding tracked in Terraform; current gateway targets healthy |

## Ownership

- edge-security Terraform owns the ALB, listener, target group, and edge security-group rules.
- platform-services Terraform owns controller Helm releases, identities, PDBs, and TargetGroupBinding.
- AWS Load Balancer Controller reconciles target registration.
- Istio reconciles Gateway API routing.
- Helm owns the manually deployed Istio gateway Deployment and Service.
- Gateway API and mesh policy manifests are versioned and were applied with kubectl.
- Phase 5 retains ownership of EKS, managed add-ons, Karpenter, and gp3 storage.

## Validation limits and outstanding work

- Eviction and node-disruption tests were skipped at the user's request.
- Node and zone spread use ScheduleAnyway; separation is preferred, not guaranteed.
- ExternalDNS and the ESO certificate controller remain single replicas.
- Gateway API ExternalDNS sources have not yet been enabled.
- Certificate validation used Let's Encrypt staging and manual renewal; public production issuance and scheduled renewal were not tested.
- Retry validation used a test-scoped EnvoyFilter; production application routes still require explicit retry and timeout decisions.
- Standard Gateway API CRDs and their safe-upgrade admission policy were retained.
- No application HTTPRoutes were listed during the final ownership check.
- The full Route 53 → CloudFront/WAF → ALB → Istio → Frontend path remains unvalidated.
- The current ALB listener is HTTP with access restricted to configured validation CIDRs.

## Final drift evidence

- platform-services: no changes, detailed exit code 0.
- edge-security: no changes, detailed exit code 0.
- Both current Istio gateway Pod IPs were healthy ALB targets.
