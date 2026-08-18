with issues as (
    select count(*) as issue_count
    from analytics.fct_rental_lifecycle
    where (rental_status = 'completed' and actual_return_at is null)
       or (checked_out_at is not null and checked_out_at < reserved_at)
       or (actual_return_at is not null and checked_out_at is null)
       or (actual_return_at is not null and actual_return_at < checked_out_at)
       or (expected_return_at is not null and checked_out_at is not null and expected_return_at < checked_out_at)
)
select
    'lifecycle_milestones_are_consistent' as check_name,
    case when issue_count = 0 then 'pass' else 'fail' end as status,
    'inconsistent lifecycle rows=' || issue_count as detail
from issues;
