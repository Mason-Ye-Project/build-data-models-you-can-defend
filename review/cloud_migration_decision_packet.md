# Cloud migration decision packet: Copperline to Snowflake

Evidence label: illustrative transfer based on first-party documentation; no Snowflake account was used.

## Team scenario

Copperline expects daily batch loads, 50 million rental lines, five years of daily inventory snapshots, twenty BI users, and a small engineering team already operating Snowflake standard tables. The scenario is synthetic and exists only to force a bounded choice.

## Preserved invariants

- Three facts retain their declared grains.
- Type 2 customer intervals remain half-open and non-overlapping.
- Unknown and late-member behavior remains visible.
- Net revenue, allocation, utilization, and on-time components retain their contracts.
- The local fixture values remain acceptance baselines for translated SQL.

## Platform deltas

- Replace DuckDB CSV reads with governed landing/staging ingestion.
- Use Snowflake date, timestamp, decimal, and boolean syntax deliberately.
- Treat standard-table primary, foreign, and unique constraints as metadata; retain executable tests.
- Rely on micro-partition pruning before adding clustering keys; collect query-profile evidence.
- Separate transformation and BI compute where workload isolation justifies it.
- Implement incremental history and lifecycle updates with idempotent, audited logic.

## Validation sequence

1. Load the unchanged synthetic fixture into a development schema.
2. Compare source and staging row sets.
3. Run all seventeen logical checks in translated form.
4. Confirm fixed results: $1,175.00; 2 of 3; 0.314286; unsafe fan-out $2,250.00.
5. Compare column types, null behavior, date boundaries, and decimal results.
6. Run production-scale performance tests separately from correctness tests.

## Rollback conditions

Stop migration if translated SQL changes any grain, relationship coverage, interval match, or fixture baseline without an approved contract change. Remove optional physical optimizations if they add operational risk without measured benefit. Preserve the previous serving models until consumers validate the new release.

## Unresolved decisions

Authoritative timestamp timezone, production data volumes, retention, access control, privacy classification, workload concurrency, target SLAs, cost envelope, and whether dbt will orchestrate the transformations.
