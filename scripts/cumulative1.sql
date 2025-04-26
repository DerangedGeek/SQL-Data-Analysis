-- Calculate the total sales per month
--Calculate the running total over time (cumulative sales)
select 
order_date,
total_sales,
-- window function
sum(total_sales) over (partition by order_date order by order_date) as running_total_sales,
avg(avg_price) over (partition by order_date order by order_date) as moving_avg_price
from(
select 
datetrunc(month, order_date) as order_date, 
sum(sales_amount) total_sales,
avg(price) as avg_price
from gold.fact_sales
where order_date is not null 
group by datetrunc(month, order_date)
)t