select
    'unresolved_lifecycle_customer_uses_unknown_member' as check_name,
    case when customer_key = 0 then 'pass' else 'fail' end as status,
    'R1005 customer_key=' || customer_key as detail
from analytics.fct_rental_lifecycle
where rental_id = 'R1005';
