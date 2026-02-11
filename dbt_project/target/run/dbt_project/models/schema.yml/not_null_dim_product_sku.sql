
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select sku
from INDUSTRIAL_PROCUREMENT_DB.ANALYTICS.dim_product
where sku is null



  
  
      
    ) dbt_internal_test