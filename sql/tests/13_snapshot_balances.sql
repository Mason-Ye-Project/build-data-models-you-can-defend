with issues as (
    select count(*) as issue_count
    from analytics.fct_equipment_daily_snapshot
    where available_units < 0
       or rented_units < 0
       or maintenance_units < 0
       or serviceable_units <> available_units + rented_units
       or total_units <> available_units + rented_units + maintenance_units
)
select
    'snapshot_balances_are_valid' as check_name,
    case when issue_count = 0 then 'pass' else 'fail' end as status,
    'invalid snapshot rows=' || issue_count as detail
from issues;
