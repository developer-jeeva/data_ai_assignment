/* ============================================================
   FILE: 02_load_data.sql
   PURPOSE: Load scraped CSV into raw ingestion table
   ============================================================ */

USE DATABASE INDUSTRIAL_PROCUREMENT_DB;
USE SCHEMA RAW;
USE WAREHOUSE COMPUTE_WH;

---------------------------------------------------------------
-- 4. LOAD DATA INTO RAW TABLE
---------------------------------------------------------------
COPY INTO RAW.PRODUCT_INGESTION
(category, page_url, scraped_at, raw_product_json)
FROM @RAW_STAGE/raw_data.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';
