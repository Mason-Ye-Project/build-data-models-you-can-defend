with expected as (
    select count(*) as eligible_completed_rentals
    from analytics.fct_rental_lifecycle
    where rental_status = 'completed'
      and returned_on_time is not null
), published as (
    select completed_rentals
    from analytics.mart_metric_summary
)
select
    'on_time_denominator_uses_comparable_returns' as check_name,
    case when e.eligible_completed_rentals = p.completed_rentals
         then 'pass' else 'fail' end as status,
    'eligible=' || e.eligible_completed_rentals
      || ', published=' || p.completed_rentals as detail
from expected e cross join published p;
