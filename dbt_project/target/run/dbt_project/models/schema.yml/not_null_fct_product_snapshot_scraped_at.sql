
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select scraped_at
from INDUSTRIAL_PROCUREMENT_DB.ANALYTICS.fct_product_snapshot
where scraped_at is null



  
  
      
    ) dbt_internal_test