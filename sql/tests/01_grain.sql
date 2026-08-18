select
    'rental_line_grain' as check_name,
    case when count(*) = count(distinct rental_line_id) then 'pass' else 'fail' end as status,
    'fact rows=' || count(*) || ', distinct rental lines=' || count(distinct rental_line_id) as detail
from analytics.fct_rental_line;
