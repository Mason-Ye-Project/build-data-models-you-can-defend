select
    'availability_snapshot_grain' as check_name,
    case when count(*) = count(distinct (snapshot_date, branch_key, equipment_key)) then 'pass' else 'fail' end as status,
    'rows=' || count(*) || ', distinct grain=' || count(distinct (snapshot_date, branch_key, equipment_key)) as detail
from analytics.fct_equipment_daily_snapshot;
