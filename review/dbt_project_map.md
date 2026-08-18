# Illustrative dbt project map

Evidence label: illustrative transfer; not executed as a dbt project.

```text
models/
  staging/copperline/
    _sources.yml
    _staging.yml
    stg_copperline__branches.sql
    stg_copperline__customer_segment_history.sql
    stg_copperline__equipment.sql
    stg_copperline__equipment_capabilities.sql
    stg_copperline__rentals.sql
    stg_copperline__rental_lines.sql
    stg_copperline__fee_adjustments.sql
    stg_copperline__equipment_daily_inventory.sql
  intermediate/
    int_fees__grouped_to_rental_line.sql
    int_customers__versioned.sql
  marts/core/
    _core.yml
    dim_branch.sql
    dim_customer.sql
    dim_date.sql
    dim_equipment.sql
    bridge_equipment_capability.sql
    fct_rental_line.sql
    fct_equipment_daily_snapshot.sql
    fct_rental_lifecycle.sql
  marts/operations/
    _operations.yml
    mart_branch_daily.sql
    mart_capability_revenue.sql
    mart_metric_summary.sql
tests/
  assert_net_revenue_reconciles.sql
  assert_customer_history_does_not_overlap.sql
  assert_capability_allocation_reconciles.sql
  assert_lifecycle_milestones_are_consistent.sql
```

## Mapping rule

Staging models remain source-oriented. Intermediate models name reusable transformations whose output grain is explicit. Facts and dimensions live in governed marts. Generic tests cover not-null, uniqueness, relationships, and accepted values; singular SQL tests preserve reconciliation and counterexamples. Model contracts may enforce published columns and types, but business grain and metric meaning remain documented decisions.
