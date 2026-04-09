WITH product_counts AS (
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
CROSS JOIN product_counts c; 