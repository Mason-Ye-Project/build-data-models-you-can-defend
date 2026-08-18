with source_truth as (
    select
        sum(
            case when r.rental_status = 'cancelled' then 0
            else l.quantity * l.rental_days * l.daily_rate - l.discount_amount + coalesce(f.fee_amount, 0)
            end
        )::decimal(12, 2) as amount
    from staging.stg_rental_lines l
    join staging.stg_rentals r using (rental_id)
    left join (
        select rental_line_id, sum(amount) as fee_amount
        from staging.stg_fee_adjustments
        group by rental_line_id
    ) f using (rental_line_id)
), model_truth as (
    select sum(net_revenue)::decimal(12, 2) as amount
    from analytics.fct_rental_line
)
select
    'net_revenue_reconciliation' as check_name,
    case when s.amount = m.amount then 'pass' else 'fail' end as status,
    'source=' || s.amount || ', model=' || m.amount as detail
from source_truth s cross join model_truth m;
