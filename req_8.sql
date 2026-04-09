with sales_with_quarters AS(
SELECT sold_quantity,date,
CASE
WHEN MONTH(date) in (9,10,11) THEN 'Q1'
WHEN MONTH(date) in (12,1,2) THEN 'Q2'
WHEN MONTH(date) in (3,4,5) THEN 'Q3'
ELSE 'Q4'
END AS fiscal_quarter
FROM fact_sales_monthly
where YEAR(date)=2020
)
select fiscal_quarter,
round(sum(sold_quantity/1000000),2)as total_sold_quantity_in_millions
from sales_with_quarters
group by fiscal_quarter
order by total_sold_quantity_in_millions desc;