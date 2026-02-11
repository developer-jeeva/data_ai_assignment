
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select sku
from INDUSTRIAL_PROCUREMENT_DB.ANALYTICS.stg_product_catalog
where sku is null



  
  
      
    ) dbt_internal_test