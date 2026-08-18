create table analytics.fct_equipment_daily_snapshot as
select
    d.date_key,
    s.snapshot_date,
    b.branch_key,
    e.equipment_key,
    s.available_units,
    s.rented_units,
    s.maintenance_units,
    (s.available_units + s.rented_units + s.maintenance_units)::integer as total_units,
    (s.available_units + s.rented_units)::integer as serviceable_units
from staging.stg_equipment_daily_inventory s
join analytics.dim_date d on s.snapshot_date = d.calendar_date
join analytics.dim_branch b using (branch_id)
join analytics.dim_equipment e using (equipment_id);

create view fct_equipment_daily_snapshot as
select * from analytics.fct_equipment_daily_snapshot;
