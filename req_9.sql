# Which channel helped to bring more gross sales in the fiscal year 2021 
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

