
  create or replace   view INDUSTRIAL_PROCUREMENT_DB.ANALYTICS.fct_product_snapshot
  
  
  
  
  as (
    SELECT
    d.product_id,
    s.selling_price,
    s.tax_exclusive_price,
    s.avg_rating,
    s.review_count,
    s.in_stock,
    s.scraped_at
FROM INDUSTRIAL_PROCUREMENT_DB.ANALYTICS.stg_product_catalog s
JOIN INDUSTRIAL_PROCUREMENT_DB.ANALYTICS.dim_product d
    ON s.sku = d.sku
  );

