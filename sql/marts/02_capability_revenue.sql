create table analytics.mart_capability_revenue as
select
    b.capability,
    sum(f.net_revenue * b.allocation_weight)::decimal(12, 2) as allocated_net_revenue
from analytics.fct_rental_line f
join analytics.bridge_equipment_capability b using (equipment_key)
group by b.capability;

create view mart_capability_revenue as
select * from analytics.mart_capability_revenue;
