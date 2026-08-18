create schema staging;
create schema analytics;

create table staging.stg_branches as
select
    branch_id::varchar as branch_id,
    branch_name::varchar as branch_name,
    region::varchar as region
from read_csv('{{RAW_DIR}}/branches.csv', header = true, all_varchar = true);

create table staging.stg_customers as
select
    customer_id::varchar as customer_id,
    customer_name::varchar as customer_name,
    customer_segment::varchar as customer_segment
from read_csv('{{RAW_DIR}}/customers.csv', header = true, all_varchar = true);

create table staging.stg_customer_segment_history as
select
    customer_id::varchar as customer_id,
    customer_name::varchar as customer_name,
    customer_segment::varchar as customer_segment,
    effective_from::date as effective_from,
    try_cast(effective_to as date) as effective_to
from read_csv('{{RAW_DIR}}/customer_segment_history.csv', header = true, all_varchar = true);

create table staging.stg_equipment as
select
    equipment_id::varchar as equipment_id,
    equipment_name::varchar as equipment_name,
    equipment_category::varchar as equipment_category
from read_csv('{{RAW_DIR}}/equipment.csv', header = true, all_varchar = true);

create table staging.stg_equipment_capabilities as
select equipment_id::varchar as equipment_id, capability::varchar as capability
from read_csv('{{RAW_DIR}}/equipment_capabilities.csv', header = true, all_varchar = true);

create table staging.stg_rentals as
select
    rental_id::varchar as rental_id,
    customer_id::varchar as customer_id,
    branch_id::varchar as branch_id,
    reserved_at::timestamp as reserved_at,
    try_cast(checked_out_at as timestamp) as checked_out_at,
    try_cast(expected_return_at as timestamp) as expected_return_at,
    try_cast(actual_return_at as timestamp) as actual_return_at,
    lower(status)::varchar as rental_status
from read_csv('{{RAW_DIR}}/rentals.csv', header = true, all_varchar = true);

create table staging.stg_rental_lines as
select
    rental_line_id::varchar as rental_line_id,
    rental_id::varchar as rental_id,
    equipment_id::varchar as equipment_id,
    quantity::integer as quantity,
    rental_days::integer as rental_days,
    daily_rate::decimal(12, 2) as daily_rate,
    discount_amount::decimal(12, 2) as discount_amount
from read_csv('{{RAW_DIR}}/rental_lines.csv', header = true, all_varchar = true);

create table staging.stg_fee_adjustments as
select
    adjustment_id::varchar as adjustment_id,
    rental_line_id::varchar as rental_line_id,
    lower(fee_type)::varchar as fee_type,
    amount::decimal(12, 2) as amount
from read_csv('{{RAW_DIR}}/fee_adjustments.csv', header = true, all_varchar = true);

create table staging.stg_equipment_daily_inventory as
select
    snapshot_date::date as snapshot_date,
    branch_id::varchar as branch_id,
    equipment_id::varchar as equipment_id,
    available_units::integer as available_units,
    rented_units::integer as rented_units,
    maintenance_units::integer as maintenance_units
from read_csv('{{RAW_DIR}}/equipment_daily_inventory.csv', header = true, all_varchar = true);

create view stg_rentals as select * from staging.stg_rentals;
create view stg_rental_lines as select * from staging.stg_rental_lines;
