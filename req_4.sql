with cte20 as(
select p.segment,count(distinct fs.product_code)as product_count_2020
from dim_product as p
join fact_sales_monthly as fs
on p.product_code=fs.product_code
where fs.fiscal_year=2020
group by p.segment
),
cte21 as(
select p.segment,count(distinct fs.product_code)as product_count_2021
from dim_product as p
join fact_sales_monthly as fs
on p.product_code=fs.product_code
where fs.fiscal_year=2021
group by p.segment
)
select
cte20.segment,
cte20.product_count_2020,
cte21.product_count_2021,
(cte21.product_count_2021-cte20.product_count_2020)as difference
from cte20
join cte21 
on cte20.segment=cte21.segment
