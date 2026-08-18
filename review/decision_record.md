# Decision record: Copperline analytical model

## Context

Copperline needs rental revenue, equipment utilization, on-time returns, branch comparison, customer-segment history, and capability reporting from operational exports with different grains.

## Decision

Use three facts: rental-line transaction, equipment daily periodic snapshot, and rental lifecycle accumulating snapshot. Share branch, equipment, date, and effective-dated customer dimensions where their meanings are compatible. Use a weighted equipment-capability bridge only for allocated capability reporting.

## Evidence

- Transaction fact reconciles to $1,175.00.
- Unsafe capability join returns $2,250.00.
- `R1001` resolves to Commercial at checkout.
- `R1005` uses unknown customer key 0 and can resolve to one late version.
- On-time return result is 2 of 3 completed rentals.
- Utilization is 0.314286 from summed components.

## Consequences

Consumers must not join raw facts directly. The model contains more than one published relation and requires documented clocks. In return, each row has defensible meaning, metrics reconcile, and cloud implementations can change physical design without changing business invariants.

## Not decided

Production ingestion, event-time timezone authority, incremental SCD mechanics, cloud platform selection, scale optimization, accounting recognition, and access-control design.
