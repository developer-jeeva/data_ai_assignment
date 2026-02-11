{{ config(materialized='view') }}

WITH deduplicated AS (

    SELECT
        sku,

        ANY_VALUE(product_name) AS product_name,
        ANY_VALUE(brand) AS brand,
        ANY_VALUE(category) AS category,
        ANY_VALUE(page_url) AS product_url,

        -- Country cleaning
        COALESCE(ANY_VALUE(country_of_origin), 'Not Applicable') AS country_of_origin,

        -- Lead time text
        ANY_VALUE(lead_time) AS raw_lead_time,

        -- Rating cleaning
        COALESCE(ANY_VALUE(avg_rating), 0) AS avg_rating,
        COALESCE(ANY_VALUE(review_count), 0) AS review_count

    FROM {{ ref('stg_product_catalog') }}
    WHERE sku IS NOT NULL
    GROUP BY sku
),

leadtime_cleaned AS (

    SELECT
        sku,
        product_name,
        brand,
        category,
        product_url,
        country_of_origin,
        avg_rating,
        review_count,

        ---------------------------------------------------
        -- Convert lead time text → numeric days
        ---------------------------------------------------
        CASE
            -- "Ships within 24 hrs"
            WHEN raw_lead_time ILIKE '%hrs%' THEN
                CEIL(TRY_TO_NUMBER(REGEXP_SUBSTR(raw_lead_time, '\\d+')) / 24)

            -- "Ships within 2 days"
            WHEN raw_lead_time ILIKE '%days%' THEN
                TRY_TO_NUMBER(REGEXP_SUBSTR(raw_lead_time, '\\d+'))

            -- Unknown lead time
            ELSE NULL
        END AS lead_time_days

    FROM deduplicated
)

SELECT
    MD5(sku) AS product_id,
    sku,
    product_name,
    brand,
    category,
    product_url,
    country_of_origin,
    lead_time_days,
    avg_rating,
    review_count
FROM leadtime_cleaned
