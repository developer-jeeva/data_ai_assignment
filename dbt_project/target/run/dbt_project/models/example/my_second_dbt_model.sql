
  create or replace   view INDUSTRIAL_PROCUREMENT_DB.ANALYTICS.my_second_dbt_model
  
  
  
  
  as (
    -- Use the `ref` function to select from other models

select *
from INDUSTRIAL_PROCUREMENT_DB.ANALYTICS.my_first_dbt_model
where id = 1
  );

