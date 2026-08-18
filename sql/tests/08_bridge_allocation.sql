with weights as (
    select equipment_key, sum(allocation_weight) as total_weight
    from analytics.bridge_equipment_capability
    group by equipment_key
), allocation_total as (
    select sum(allocated_net_revenue) as amount
    from analytics.mart_capability_revenue
), fact_total as (
    select sum(net_revenue) as amount
    from analytics.fct_rental_line
)
select
    'bridge_allocation_preserves_revenue' as check_name,
    case
        when (select count(*) from weights where abs(total_weight - 1) > 0.000001) = 0
         and abs(a.amount - f.amount) < 0.01 then 'pass'
        else 'fail'
    end as status,
    'allocated=' || a.amount || ', fact=' || f.amount as detail
from allocation_total a cross join fact_total f;
