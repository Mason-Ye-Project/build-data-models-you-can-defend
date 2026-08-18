create table analytics.fct_rental_lifecycle as
select
    r.rental_id,
    b.branch_key,
    coalesce(c.customer_key, 0) as customer_key,
    r.rental_status,
    r.reserved_at,
    r.checked_out_at,
    r.expected_return_at,
    r.actual_return_at,
    case when r.checked_out_at is not null
        then date_diff('hour', r.reserved_at, r.checked_out_at)
    end::integer as hours_to_checkout,
    case when r.actual_return_at is not null
        then date_diff('hour', r.checked_out_at, r.actual_return_at)
    end::integer as rental_hours,
    case when r.actual_return_at is not null and r.expected_return_at is not null
        then r.actual_return_at <= r.expected_return_at
    end as returned_on_time
from staging.stg_rentals r
join analytics.dim_branch b using (branch_id)
left join analytics.dim_customer c
    on r.customer_id = c.customer_id
   and cast(coalesce(r.checked_out_at, r.reserved_at) as date) >= c.effective_from
   and cast(coalesce(r.checked_out_at, r.reserved_at) as date) < coalesce(c.effective_to, date '9999-12-31')
qualify row_number() over (
    partition by r.rental_id
    order by coalesce(c.effective_from, date '1900-01-01') desc
) = 1;

create view fct_rental_lifecycle as
select * from analytics.fct_rental_lifecycle;
