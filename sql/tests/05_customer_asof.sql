select
    'r1001_uses_historical_customer_segment' as check_name,
    case when min(c.customer_segment) = 'Commercial' and max(c.customer_segment) = 'Commercial'
         then 'pass' else 'fail' end as status,
    'segment=' || coalesce(min(c.customer_segment), 'missing') as detail
from analytics.fct_rental_line f
join analytics.dim_customer c using (customer_key)
where f.rental_id = 'R1001';
