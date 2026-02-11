
    
    

select
    ingestion_id as unique_field,
    count(*) as n_records

from INDUSTRIAL_PROCUREMENT_DB.ANALYTICS.stg_product_catalog
where ingestion_id is not null
group by ingestion_id
having count(*) > 1


