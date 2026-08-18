# Schema-change review: equipment condition

## Proposed change

The operational export adds `condition_code` to equipment records with values `new`, `good`, `fair`, and `retired`. A dashboard owner asks to filter historical utilization by condition.

## Decision

Do not add the current value directly to the existing equipment dimension and imply historical accuracy. Treat condition as time-varying. Before implementation, obtain effective timestamps or a dated condition event source. If only the current value exists, publish it as `current_condition_code`, document that it is not historically accurate, and keep it out of historical metric contracts.

## Invariants

- The transaction fact remains one row per rental line.
- The availability snapshot remains one row per date, branch, and equipment type.
- Existing revenue and utilization baselines must reconcile before and after the schema change.
- No historical row may acquire a condition value that was not knowable at its event or snapshot date.

## Validation packet

1. Re-run every existing SQL check.
2. Add accepted-value and non-overlap checks to the chosen condition-history model.
3. Construct an asset whose condition changes during the fixture period.
4. Prove an as-of lookup returns the earlier condition for earlier snapshots.
5. Compare totals with and without the condition join to detect fan-out.

## Blast radius

Affected: equipment dimension design, snapshot lookup, documentation, model manifest, and any new condition-filtered metric. Not affected unless requirements change: customer history, rental-line grain, fee logic, on-time-return logic.

## Rollback condition

Do not release the historical filter if effective timestamps are missing, intervals overlap, or any pre-existing metric baseline changes without an approved definition change.
