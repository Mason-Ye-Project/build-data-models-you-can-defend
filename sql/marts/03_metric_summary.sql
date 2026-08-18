create table analytics.mart_metric_summary as
with revenue as (
    select sum(net_revenue)::decimal(12, 2) as net_revenue
    from analytics.fct_rental_line
), returns as (
    select
        count(*) filter (
            where rental_status = 'completed'
              and returned_on_time is not null
        ) as completed_rentals,
        count(*) filter (
            where rental_status = 'completed'
              and returned_on_time
        ) as on_time_rentals
    from analytics.fct_rental_lifecycle
), utilization as (
    select
        sum(rented_units)::decimal(18, 6)
        / nullif(sum(serviceable_units), 0) as utilization_rate
    from analytics.fct_equipment_daily_snapshot
)
select
    r.net_revenue,
    t.completed_rentals,
    t.on_time_rentals,
    (t.on_time_rentals::decimal(18, 6) / nullif(t.completed_rentals, 0)) as on_time_return_rate,
    u.utilization_rate
from revenue r cross join returns t cross join utilization u;

create view mart_metric_summary as select * from analytics.mart_metric_summary;
