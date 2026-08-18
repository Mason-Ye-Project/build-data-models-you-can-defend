create table analytics.dim_branch as
select
    row_number() over (order by branch_id)::integer as branch_key,
    branch_id,
    branch_name,
    region
from staging.stg_branches;

create table analytics.dim_customer as
select
    0::integer as customer_key,
    '__UNKNOWN__'::varchar as customer_id,
    'Unknown customer'::varchar as customer_name,
    'Unknown'::varchar as customer_segment,
    date '1900-01-01' as effective_from,
    null::date as effective_to,
    true as is_current
union all
select
    row_number() over (order by customer_id, effective_from)::integer as customer_key,
    customer_id,
    customer_name,
    customer_segment,
    effective_from,
    effective_to,
    effective_to is null as is_current
from staging.stg_customer_segment_history;

create table analytics.dim_equipment as
select
    row_number() over (order by equipment_id)::integer as equipment_key,
    equipment_id,
    equipment_name,
    equipment_category
from staging.stg_equipment;

create table analytics.bridge_equipment_capability as
with capabilities as (
    select
        equipment_id,
        capability,
        count(*) over (partition by equipment_id) as capability_count
    from staging.stg_equipment_capabilities
)
select
    e.equipment_key,
    c.capability,
    (1.0 / c.capability_count)::decimal(12, 6) as allocation_weight
from capabilities c
join analytics.dim_equipment e using (equipment_id);

create table analytics.dim_date as
select
    cast(strftime(calendar_date, '%Y%m%d') as integer) as date_key,
    calendar_date,
    year(calendar_date)::integer as calendar_year,
    month(calendar_date)::integer as calendar_month,
    day(calendar_date)::integer as day_of_month,
    dayname(calendar_date) as day_name
from range(date '2026-06-01', date '2026-06-09', interval 1 day) d(calendar_date);

create view dim_branch as select * from analytics.dim_branch;
create view dim_customer as select * from analytics.dim_customer;
create view dim_equipment as select * from analytics.dim_equipment;
create view dim_date as select * from analytics.dim_date;
