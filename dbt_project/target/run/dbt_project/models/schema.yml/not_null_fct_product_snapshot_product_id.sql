
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select product_id
from INDUSTRIAL_PROCUREMENT_DB.ANALYTICS.fct_product_snapshot
where product_id is null



  
  
      
    ) dbt_internal_test