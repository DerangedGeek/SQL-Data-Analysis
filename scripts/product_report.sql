create view gold.report_products as
with base_query as (
select
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost,
f.quantity
from gold.fact_sales as f
 left join gold.dim_products as p
 on f.product_key = p.product_key
 where f.order_date is not null -- this is to ensure only valid dates are carried out
 )
,
product_aggregation as (
--Summarize the key metrics of the product level
 select 
 product_key, product_name, category, subcategory, cost,
  max(order_date) as last_order_date,
 datediff(month, min(order_date), max(order_date)) as lifespan, 
 sum(quantity) as total_quantity,
 sum(sales_amount) as total_sales,
 count(distinct order_number) as total_orders,
 count(distinct customer_key) as total_customers,
 round(AVG(cast(sales_amount as float)/nullif(quantity, 0)),2) as avg_selling_price
from base_query
group by product_key, product_name, category, subcategory,cost
)
Select
-- Find the KPIs and other useful data
product_key,
product_name,
category,
subcategory,
cost,
last_order_date,
datediff(month,last_order_date, getdate()) as recency_in_months,
lifespan,
total_quantity,
total_sales,
case 
	when total_sales > 50000 then 'High-Performer'
	when total_sales >= 10000 then 'Mid-Range'
	else 'Low-Performance'
	end product_segment,
total_orders,
total_customers,
avg_selling_price,
-- average order revenue (AOR)
case 
	when total_orders = 0 then 0
	else total_sales/total_orders
	end avg_order_rev,
--case for average monthly revenue
case
	when lifespan = 0 then 0
	else total_sales/lifespan
	end avg_month_rev
from product_aggregation