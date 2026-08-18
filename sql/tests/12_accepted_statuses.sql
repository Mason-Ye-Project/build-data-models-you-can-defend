with issues as (
    select count(*) as issue_count
    from staging.stg_rentals
    where rental_status not in ('reserved', 'checked_out', 'completed', 'cancelled')
)
select
    'rental_status_values_are_governed' as check_name,
    case when issue_count = 0 then 'pass' else 'fail' end as status,
    'unexpected status rows=' || issue_count as detail
from issues;
