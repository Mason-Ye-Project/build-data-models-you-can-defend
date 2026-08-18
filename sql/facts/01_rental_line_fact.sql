create table analytics.fct_rental_line as
with fee_by_line as (
    select rental_line_id, sum(amount)::decimal(12, 2) as fee_amount
    from staging.stg_fee_adjustments
    group by rental_line_id
)
select
    l.rental_line_id,
    l.rental_id,
    b.branch_key,
    c.customer_key,
    e.equipment_key,
    cast(r.checked_out_at as date) as checkout_date,
    r.rental_status,
    l.quantity,
    l.rental_days,
    l.daily_rate,
    (l.quantity * l.rental_days * l.daily_rate)::decimal(12, 2) as base_charge,
    l.discount_amount,
    coalesce(f.fee_amount, 0)::decimal(12, 2) as fee_amount,
    (r.rental_status <> 'cancelled') as is_billable,
    case
        when r.rental_status = 'cancelled' then 0
        else (l.quantity * l.rental_days * l.daily_rate) - l.discount_amount + coalesce(f.fee_amount, 0)
    end::decimal(12, 2) as net_revenue
from staging.stg_rental_lines l
join staging.stg_rentals r using (rental_id)
join analytics.dim_branch b using (branch_id)
left join analytics.dim_customer c
    on r.customer_id = c.customer_id
   and cast(coalesce(r.checked_out_at, r.reserved_at) as date) >= c.effective_from
   and cast(coalesce(r.checked_out_at, r.reserved_at) as date) < coalesce(c.effective_to, date '9999-12-31')
join analytics.dim_equipment e using (equipment_id)
left join fee_by_line f using (rental_line_id)
qualify row_number() over (
    partition by l.rental_line_id
    order by coalesce(c.effective_from, date '1900-01-01') desc
) = 1;

create view fct_rental_line as select * from analytics.fct_rental_line;
