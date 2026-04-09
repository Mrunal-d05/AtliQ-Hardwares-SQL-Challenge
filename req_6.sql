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
 limit 5;