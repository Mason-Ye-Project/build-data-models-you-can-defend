select
    'rental_lifecycle_grain' as check_name,
    case when count(*) = count(distinct rental_id) then 'pass' else 'fail' end as status,
    'rows=' || count(*) || ', distinct rentals=' || count(distinct rental_id) as detail
from analytics.fct_rental_lifecycle;
