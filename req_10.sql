WITH ranked_products AS (
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
ORDER BY division, rank_order;