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

