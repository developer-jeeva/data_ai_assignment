SELECT
    d.product_id,
    s.selling_price,
    s.tax_exclusive_price,
    s.avg_rating,
    s.review_count,
    s.in_stock,
    s.scraped_at
FROM {{ ref('stg_product_catalog') }} s
JOIN {{ ref('dim_product') }} d
    ON s.sku = d.sku
