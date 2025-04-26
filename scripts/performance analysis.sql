-- Performance analysis (current - target||average||previous||lowest||highest) etc. 
/* Analyze the yearly performance of products by comparing their sales to both the 
average sales performance of the product and the previous year*/
With yearly_product_sales as (
select 
year(f.order_date) as order_year,
p.product_name, sum(f.sales_amount) as current_sales
from gold.fact_sales as f
left join gold.dim_products as p 
on f.product_key = p.product_key
where f.order_date is not null
group by year(f.order_date),p.product_name
)
select 
order_year, 
product_name,
current_Sales,
avg(current_sales) over (partition by product_name) as AvgSales,
current_sales-avg(current_sales) over (partition by product_name) as diff_avg,
case when current_sales-avg(current_sales) over (partition by product_name) > 0 then 'Above avg'
	when current_sales-avg(current_sales) over (partition by product_name) < 0 then 'Below avg'
	else 'Avg'
	end avg_change,
	-- Year-over-year analysis
	Lag(current_sales) over (partition by product_name order by order_year) as prev_yr,
	current_sales - Lag(current_sales) over (partition by product_name order by order_year) as dif_prev_yr,
	case
	when Lag(current_sales) over (partition by product_name order by order_year) > 0 then 'Increase'
	when Lag(current_sales) over (partition by product_name order by order_year) < 0 then 'decrease'
	else 'No change'
	end py_change
	 from yearly_product_sales
 order by product_name, order_year