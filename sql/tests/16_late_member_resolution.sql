with candidate_customer_dimension as (
    select customer_key, customer_id, effective_from, effective_to
    from analytics.dim_customer
    union all
    select
        99 as customer_key,
        'C999' as customer_id,
        date '2026-06-01' as effective_from,
        null::date as effective_to
), resolution as (
    select
        r.rental_id,
        coalesce(c.customer_key, 0) as customer_key
    from staging.stg_rentals r
    left join candidate_customer_dimension c
      on r.customer_id = c.customer_id
     and cast(coalesce(r.checked_out_at, r.reserved_at) as date) >= c.effective_from
     and cast(coalesce(r.checked_out_at, r.reserved_at) as date)
           < coalesce(c.effective_to, date '9999-12-31')
    where r.rental_id = 'R1005'
)
select
    'late_customer_can_resolve_without_changing_grain' as check_name,
    case when count(*) = 1 and min(customer_key) = 99 then 'pass' else 'fail' end as status,
    'candidate rows=' || count(*) || ', resolved key=' || min(customer_key) as detail
from resolution;
