
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select ingestion_id
from INDUSTRIAL_PROCUREMENT_DB.ANALYTICS.stg_product_catalog
where ingestion_id is null



  
  
      
    ) dbt_internal_test