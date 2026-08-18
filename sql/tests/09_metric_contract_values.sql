select
    'bounded_metric_values' as check_name,
    case
        when net_revenue = 1175.00
         and completed_rentals = 3
         and on_time_rentals = 2
         and abs(on_time_return_rate - 0.666667) < 0.000001
         and abs(utilization_rate - 0.314286) < 0.000001
        then 'pass' else 'fail'
    end as status,
    'revenue=' || net_revenue
      || ', on_time=' || on_time_rentals || '/' || completed_rentals
      || ', utilization=' || round(utilization_rate, 6) as detail
from analytics.mart_metric_summary;
