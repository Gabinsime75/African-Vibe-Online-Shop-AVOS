# AVOS gRPC Request Policy

## Scope and status

This policy defines deadlines, cancellation, retry eligibility, and
idempotency for every declared business RPC.
Deadline values are initial engineering limits, not measured SLOs.

This document defines required behavior; it does not establish that every
service currently enforces it. Implementation gaps are recorded below.

## RPC matrix

Deadlines are total logical-call budgets, including any retry and backoff.
R means eligible for one explicitly configured retry under the rules below.
N means no application, client-policy, or mesh retry after dispatch.

| RPC | Budget | Retry | Idempotency and side effects |
|---|---|---|---|
| hipstershop.CartService/AddItem | 3 s | N | Quantity increment; duplicate calls add twice |
| hipstershop.CartService/GetCart | 3 s | R | Read-only; returned state may change |
| hipstershop.CartService/EmptyCart | 3 s | N | Repetition can erase concurrent additions |
| hipstershop.RecommendationService/ListRecommendations | 4 s | R | Read-only; results may vary |
| hipstershop.ProductCatalogService/ListProducts | 3 s | R | Read-only |
| hipstershop.ProductCatalogService/GetProduct | 3 s | R | Read-only |
| hipstershop.ProductCatalogService/SearchProducts | 3 s | R | Read-only |
| hipstershop.ShippingService/GetQuote | 3 s | R | Quote only; no shipment creation |
| hipstershop.ShippingService/ShipOrder | 3 s | N | Creates shipment/tracking identity |
| hipstershop.CurrencyService/GetSupportedCurrencies | 3 s | R | Read-only |
| hipstershop.CurrencyService/Convert | 3 s | R | Calculation; no financial transfer |
| hipstershop.PaymentService/Charge | 3 s | N | Creates a simulated transaction |
| hipstershop.EmailService/SendOrderConfirmation | 3 s | N | May duplicate a delivered message |
| hipstershop.CheckoutService/PlaceOrder | 20 s | N | Orchestrates multiple side effects |
| hipstershop.AdService/GetAds | 100 ms | N | Optional read; latency budget takes priority |
| avos.shoppingassistant.v1.ShoppingAssistantService/GetRecommendations | 30 s | N | Read-only business state, but billable model execution |

The two CartService schema projections share the same RPC policy.
Health Check and Watch lifecycle behavior is addressed separately in 9.3.

## Deadline and cancellation rules

- Every outbound call must have an explicit deadline.
- Use the earlier of the configured call limit and the remaining parent budget.
- Do not start a call after its parent expires or is cancelled.
- Reserve time for local processing and returning the response.
- Propagate the incoming context or cancellation token to downstream work.
- Stop queued and cooperative work promptly after cancellation.
- Cancellation stops waiting or requests cancellation; it does not roll back
  an already completed Redis write, payment, shipment, or message delivery.
- A timeout after mutation dispatch represents an uncertain outcome.
  Do not interpret it as proof that the operation did not execute.

Checkout retains a 20-second overall limit and 3-second child-call limits.
The parent budget is shared across cart retrieval, pricing, payment,
shipping, and best-effort post-order work; it is not reset per dependency.

Recommendation catalog calls must fit inside the incoming deadline,
with a maximum of 3 seconds and time reserved for response processing.

Assistant model and search calls must share the 30-second parent budget.
SDK connection/read timeouts and internal retries are not an overall deadline.

## Retry rules

Retry eligibility is not evidence that retries are currently enabled.
Do not add blanket retries.

For R operations, explicitly enabled retries must satisfy all of these:

- At most two attempts total, including the original request.
- Retry only UNAVAILABLE, while the parent remains active.
- Use randomized backoff, initially 50 to 100 milliseconds.
- Fit both attempts and backoff inside the original logical-call deadline.
- Use one retry layer; do not multiply application, gRPC, SDK, and mesh retries.
- Do not retry CANCELLED, DEADLINE_EXCEEDED, validation, authentication,
  permission, or application-precondition failures.
- Disable hedging.

For N operations, do not configure automatic replay after dispatch.
Transport-level transparent retries proven not to have reached application
logic are distinct from application retries.

Payment, shipment, and checkout retries require durable idempotency before
they can be reconsidered. That includes a caller-supplied key, request-payload
validation, atomic deduplication, stored outcomes, and concurrent-request tests.
A generated transaction ID alone is not an idempotency mechanism.

## Verified behavior and implementation gaps

Source review against merge e794581 established:

- Checkout applies a 20-second overall deadline and 3-second child limits.
- Checkout documents no automatic payment or shipment retry.
- Cart handlers propagate cancellation into store operations.
- Redis WaitAsync cancellation does not prove server-side mutation cancellation.
- Frontend ads use 100 milliseconds; assistant calls use 30 seconds.
- Other inspected frontend wrappers forward context without explicit call caps.
- Recommendation catalog calls use a configured timeout, but the inspected
  implementation does not explicitly cap it to the remaining parent budget.
- Assistant SDK timeouts and retries require alignment with its parent budget.
- End-to-end cancellation and mesh retry behavior remain to be validated.

These gaps must be tracked in subsequent application implementation and
failure testing. Defining this policy does not close the Phase 9 runtime gate.

## Validation requirements

- Every declared business RPC appears in the matrix.
- Short parent deadlines take precedence over larger configured limits.
- Cancellation prevents new downstream dispatch and stops cooperative work.
- Eligible retries remain bounded and do not stack across layers.
- Mutating requests are not automatically replayed after uncertain outcomes.
- Delayed dependencies produce bounded failures without duplicate side effects.
- Tests use controlled fakes; do not induce real charges or customer emails.

## References

- [gRPC deadlines](https://grpc.io/docs/guides/deadlines/)
- [gRPC cancellation](https://grpc.io/docs/guides/cancellation/)
- [gRPC retries](https://grpc.io/docs/guides/retry/)
- [Contract conventions](../../protos/README.md)
