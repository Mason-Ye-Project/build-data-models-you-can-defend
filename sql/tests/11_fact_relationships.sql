with issues as (
    select count(*) as issue_count
    from analytics.fct_rental_line f
    left join analytics.dim_branch b using (branch_key)
    left join analytics.dim_customer c using (customer_key)
    left join analytics.dim_equipment e using (equipment_key)
    where b.branch_key is null or c.customer_key is null or e.equipment_key is null
)
select
    'rental_line_dimension_relationships' as check_name,
    case when issue_count = 0 then 'pass' else 'fail' end as status,
    'orphaned fact rows=' || issue_count as detail
from issues;
