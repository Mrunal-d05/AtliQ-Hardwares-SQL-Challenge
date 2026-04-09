SELECT customer_code,market,customer,region FROM gdb023.dim_customer
where customer="Atliq Exclusive" and region='APAC';WITH ranked_products AS (
  SELECT
    d.division,
    f.product_code,
    d.product AS product_name,         -- Additional field
    SUM(f.sold_quantity) AS total_sold_quantity,
    ROW_NUMBER() OVER (
      PARTITION BY d.division
      ORDER BY SUM(f.sold_quantity) DESC
    ) AS row_num                        -- Using ROW_NUMBER to avoid ties
  FROM dim_product AS d
  JOIN fact_sales_monthly AS f
    ON d.product_code = f.product_code
  WHERE f.fiscal_year = 2021
  GROUP BY d.division, f.product_code, d.product
)
SELECT
  division,
  product_code,
  product_name,                       -- Included in final output
  total_sold_quantity,                -- Included in final output
  row_num AS rank_order               -- Displaying the computed rank
FROM ranked_products
WHERE row_num <= 3
ORDER BY division, rank_order;WITH product_counts AS (
  SELECT
    COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code END) AS unique_products_2020,
    COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN product_code END) AS unique_products_2021
  FROM fact_sales_monthly
  WHERE fiscal_year IN (2020, 2021)
)

SELECT
  p.unique_products_2020,
  p.unique_products_2021,
  CONCAT(
    ROUND(
      (p.unique_products_2021 - p.unique_products_2020) * 100.0
      / NULLIF(p.unique_products_2020, 0),
      2
    ),
    '%'
  ) AS percentage_chg
FROM product_counts AS p
CROSS JOIN product_counts c; SELECT segment,count(distinct product_code)as product_count
FROM dim_product
group by segment
order by product_count desc;with cte20 as(
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
select m.product_code,p.product,m.manufacturing_cost
from fact_manufacturing_cost m
join dim_product p
on p.product_code=m.product_code
where m.manufacturing_cost=
(select max(manufacturing_cost) 
from fact_manufacturing_cost)
union all
select m.product_code,p.product,m.manufacturing_cost
from fact_manufacturing_cost m
join dim_product p
on p.product_code=m.product_code
where m.manufacturing_cost=
(select min(manufacturing_cost) 
from fact_manufacturing_cost)

SELECT pi.customer_code,c.customer,
round(avg(pre_invoice_discount_pct),4)as average_discount_percentage
 FROM fact_pre_invoice_deductions pi
 join dim_customer c
 on pi.customer_code=c.customer_code
 where pi.fiscal_year=2021 and
 c.market='India'and
 pi.pre_invoice_discount_pct IS NOT NULL
 group by pi.customer_code,c.customer
 order by average_discount_percentage desc
 limit 5;SELECT
  MONTHNAME(fs.date) AS Month,
  YEAR(fs.date) AS Year,
  CONCAT(
    ROUND(SUM(fs.sold_quantity * fg.gross_price) / 1000000, 2),
    'm'
  ) AS `Gross sales Amount`
FROM fact_sales_monthly AS fs
JOIN fact_gross_price AS fg
  ON fs.product_code = fg.product_code
JOIN dim_customer AS d
  ON fs.customer_code = d.customer_code
WHERE d.customer = 'Atliq Exclusive'
GROUP BY Month, Year
ORDER BY Year, FIELD(Month,
  'January','February','March','April','May','June',
  'July','August','September','October','November','December');
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
order by total_sold_quantity_in_millions desc;# Which channel helped to bring more gross sales in the fiscal year 2021 
# and the percentage of contribution?  The final output  contains these fields, 
#channel, gross_sales_mln ,percentage 
WITH channel_sales AS (
  SELECT
    c.channel,
    SUM(fs.sold_quantity * gp.gross_price) AS gross_sales
  FROM fact_sales_monthly fs
  JOIN fact_gross_price gp
    ON fs.product_code = gp.product_code
    AND fs.fiscal_year = gp.fiscal_year
  JOIN dim_customer c
    ON fs.customer_code = c.customer_code
  WHERE fs.fiscal_year = 2021
  GROUP BY c.channel
)

SELECT
  channel,
  ROUND(gross_sales / 1000000, 2) AS gross_sales_mln,
  CONCAT(
    ROUND(
      gross_sales * 100.0 / SUM(gross_sales) OVER (), 2
    ),
    '%'
  ) AS percentage_contribution
FROM channel_sales
ORDER BY gross_sales DESC
LIMIT 5;

