create table analytics.mart_branch_daily as
select
    f.checkout_date as calendar_date,
    b.branch_key,
    b.branch_name,
    count(*) filter (where f.is_billable) as rental_line_count,
    sum(f.net_revenue)::decimal(12, 2) as net_revenue
from analytics.fct_rental_line f
join analytics.dim_branch b using (branch_key)
where f.checkout_date is not null
group by f.checkout_date, b.branch_key, b.branch_name;

create view mart_branch_daily as select * from analytics.mart_branch_daily;
