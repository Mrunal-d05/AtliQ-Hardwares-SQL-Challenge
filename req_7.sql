SELECT
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
