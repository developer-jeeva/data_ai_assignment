/* ============================================================
   ANALYTICS QUERIES – INDUSTRIAL PROCUREMENT DATASET
   PURPOSE:
   Demonstrate business insights derived from the transformed
   warehouse tables (DIM_PRODUCT & FCT_PRODUCT_SNAPSHOT)

   Each query answers a realistic stakeholder question.
   ============================================================ */


---------------------------------------------------------------
-- 1. TOP 10 PRODUCTS BY CUSTOMER RATING
-- Stakeholder: Procurement Manager
-- Purpose: Identify the most reliable and trusted products.
-- Higher rating and more reviews = higher supplier confidence.
---------------------------------------------------------------
SELECT
    d.product_name,
    d.brand,
    d.category,
    d.country_of_origin,
    d.avg_rating,
    d.review_count,
    f.selling_price
FROM ANALYTICS.FCT_PRODUCT_SNAPSHOT f
JOIN ANALYTICS.DIM_PRODUCT d
    ON f.product_id = d.product_id
WHERE d.avg_rating IS NOT NULL
ORDER BY d.avg_rating DESC, d.review_count DESC
LIMIT 10;


---------------------------------------------------------------
-- 2. DAILY PRICE TREND
-- Stakeholder: Procurement Manager
-- Purpose: Monitor pricing changes over time and detect
-- supplier price increases or market inflation.
---------------------------------------------------------------
SELECT
    DATE(f.scraped_at) AS snapshot_date,
    COUNT(*) AS total_products,
    AVG(f.selling_price) AS avg_price
FROM ANALYTICS.FCT_PRODUCT_SNAPSHOT f
GROUP BY snapshot_date
ORDER BY snapshot_date;


---------------------------------------------------------------
-- 3. PRICE OUTLIER DETECTION (Z-SCORE)
-- Stakeholder: Data / Procurement Analyst
-- Purpose: Detect abnormal pricing which may indicate
-- incorrect listings, supplier error, or premium suppliers.
---------------------------------------------------------------
WITH stats AS (
    SELECT
        AVG(selling_price) AS avg_price,
        STDDEV(selling_price) AS std_price
    FROM ANALYTICS.FCT_PRODUCT_SNAPSHOT
),
scored AS (
    SELECT
        d.product_name,
        f.selling_price,
        (f.selling_price - s.avg_price) / NULLIF(s.std_price,0) AS z_score
    FROM ANALYTICS.FCT_PRODUCT_SNAPSHOT f
    JOIN ANALYTICS.DIM_PRODUCT d
        ON f.product_id = d.product_id
    CROSS JOIN stats s
)
SELECT *
FROM scored
WHERE ABS(z_score) > 2
ORDER BY z_score DESC;


---------------------------------------------------------------
-- 4. GEOGRAPHIC BREAKDOWN (COUNTRY OF ORIGIN)
-- Stakeholder: Supply Chain Manager
-- Purpose: Compare sourcing regions and understand cost and
-- quality differences between supplier countries.
---------------------------------------------------------------
SELECT
    d.country_of_origin,
    COUNT(*) AS product_count,
    AVG(f.selling_price) AS avg_price,
    AVG(d.avg_rating) AS avg_rating
FROM ANALYTICS.FCT_PRODUCT_SNAPSHOT f
JOIN ANALYTICS.DIM_PRODUCT d
    ON f.product_id = d.product_id
GROUP BY d.country_of_origin
ORDER BY product_count DESC;


---------------------------------------------------------------
-- 5. PROCUREMENT SHORTLIST (BUSINESS DECISION QUERY)
-- Stakeholder: Procurement Manager
-- Purpose: Find affordable, available and reliable products
-- to avoid production downtime.
---------------------------------------------------------------
SELECT
    d.product_name,
    d.brand,
    d.category,
    d.country_of_origin,
    d.avg_rating,
    d.review_count,
    d.lead_time,
    f.selling_price
FROM ANALYTICS.FCT_PRODUCT_SNAPSHOT f
JOIN ANALYTICS.DIM_PRODUCT d
    ON f.product_id = d.product_id
WHERE f.in_stock = TRUE
  AND f.selling_price < 10000
  AND COALESCE(d.avg_rating,0) >= 3.5
ORDER BY d.avg_rating DESC, f.selling_price ASC;
