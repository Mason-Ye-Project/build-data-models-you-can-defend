with ordered as (
    select
        customer_id,
        effective_from,
        effective_to,
        lead(effective_from) over (partition by customer_id order by effective_from) as next_from
    from analytics.dim_customer
    where customer_key <> 0
), overlap as (
    select count(*) as issue_count
    from ordered
    where effective_to is null and next_from is not null
       or effective_to > next_from
)
select
    'customer_history_has_no_overlap' as check_name,
    case when issue_count = 0 then 'pass' else 'fail' end as status,
    'overlapping intervals=' || issue_count as detail
from overlap;
