with correct as (
    select sum(net_revenue)::decimal(12, 2) as amount
    from analytics.fct_rental_line
), unsafe_join as (
    select sum(f.net_revenue)::decimal(12, 2) as amount
    from analytics.fct_rental_line f
    join analytics.bridge_equipment_capability b using (equipment_key)
)
select
    'fanout_counterexample_is_visible' as check_name,
    case when u.amount > c.amount then 'pass' else 'fail' end as status,
    'correct=' || c.amount || ', unsafe capability join=' || u.amount as detail
from correct c cross join unsafe_join u;
