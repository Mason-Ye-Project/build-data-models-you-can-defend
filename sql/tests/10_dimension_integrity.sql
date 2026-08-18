with issues as (
    select 'branch' as model_name, count(*) - count(distinct branch_key) as duplicate_count
    from analytics.dim_branch
    union all
    select 'equipment', count(*) - count(distinct equipment_key)
    from analytics.dim_equipment
    union all
    select 'customer', count(*) - count(distinct customer_key)
    from analytics.dim_customer
)
select
    'dimension_surrogate_keys_are_unique' as check_name,
    case when sum(duplicate_count) = 0 then 'pass' else 'fail' end as status,
    'duplicate surrogate keys=' || sum(duplicate_count) as detail
from issues;
