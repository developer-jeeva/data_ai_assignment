
  create or replace   view INDUSTRIAL_PROCUREMENT_DB.ANALYTICS.stg_product_catalog
  
  
  
  
  as (
    WITH base AS (

    SELECT
        ingestion_id,

        raw_product_json:title::string               AS product_name,
        REPLACE(raw_product_json:productBrand::string, 'By ', '') AS brand,
        COALESCE(
            raw_product_json:addToCart:action:params:sku::string,
            raw_product_json:sku::string
        ) AS sku,
        raw_product_json:inStock::boolean            AS in_stock,

        NULLIF(raw_product_json:rating:average::float, 0) AS avg_rating,
        raw_product_json:rating:totalReviews::int AS review_count,

        raw_product_json:pricing:prices[0]:value::number(10,2) AS selling_price,
        raw_product_json:pricing:prices[1]:value::number(10,2) AS tax_exclusive_price,

        scraped_at,
        page_url,
        category,
        COALESCE(
            raw_product_json:skuLeadTime::string,
            raw_product_json:oosAvailable::string
        ) AS lead_time


    FROM INDUSTRIAL_PROCUREMENT_DB.RAW.product_ingestion
    WHERE raw_product_json:addToCart:action:params:sku IS NOT NULL


),

country AS (

    SELECT
        r.ingestion_id,
        nv.value:value::string AS country_of_origin

    FROM INDUSTRIAL_PROCUREMENT_DB.RAW.product_ingestion r,
    LATERAL FLATTEN(input => r.raw_product_json:familyData:nonVariants) nv
    WHERE nv.value:name::string = 'Country of Origin'
)

SELECT
    b.*,
    c.country_of_origin
FROM base b
LEFT JOIN country c
ON b.ingestion_id = c.ingestion_id
  );

