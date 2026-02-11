/* ============================================================
   DATA ENGINEERING TECHNICAL ASSESSMENT
   FILE: 01_create_tables.sql
   PURPOSE: Create warehouse, database, schemas and tables
   ============================================================ */

---------------------------------------------------------------
-- 1. WAREHOUSE (Compute Layer)
---------------------------------------------------------------
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH
WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE;

USE WAREHOUSE COMPUTE_WH;

---------------------------------------------------------------
-- 2. DATABASE + SCHEMAS
---------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS INDUSTRIAL_PROCUREMENT_DB;
CREATE SCHEMA IF NOT EXISTS INDUSTRIAL_PROCUREMENT_DB.RAW;
CREATE SCHEMA IF NOT EXISTS INDUSTRIAL_PROCUREMENT_DB.ANALYTICS;

USE DATABASE INDUSTRIAL_PROCUREMENT_DB;

---------------------------------------------------------------
-- 3. RAW LAYER (BRONZE) - STORE FULL SCRAPED JSON
---------------------------------------------------------------
USE SCHEMA RAW;

CREATE OR REPLACE TABLE RAW.PRODUCT_INGESTION (

    ingestion_id INTEGER AUTOINCREMENT,
    -- metadata about scrape
    category STRING,
    page_url STRING,
    scraped_at TIMESTAMP,
    -- full raw product payload (semi-structured)
    raw_product_json VARIANT

);

---------------------------------------------------------------
-- 4. ANALYTICS LAYER (SILVER/GOLD STRUCTURE)
---------------------------------------------------------------
-- USE SCHEMA ANALYTICS;

---------------------------------------------------------------
-- DIMENSION TABLE (MASTER PRODUCT ENTITY)
-- One row per product (SKU)
---------------------------------------------------------------
-- CREATE OR REPLACE TABLE ANALYTICS.DIM_PRODUCT (

--     product_id INTEGER AUTOINCREMENT PRIMARY KEY,
--     sku STRING,
--     product_name STRING,
--     brand STRING,
--     category STRING,
--     product_url STRING,
--     country_of_origin STRING,
--     manufacturer STRING,
--     description STRING,
--     selling_unit STRING

-- );

---------------------------------------------------------------
-- FACT TABLE (TIME-BASED OBSERVATIONS)
-- One row per scrape per product
---------------------------------------------------------------
-- CREATE OR REPLACE TABLE ANALYTICS.FCT_PRODUCT_SNAPSHOT (

--     snapshot_id INTEGER AUTOINCREMENT PRIMARY KEY,
--     product_id INTEGER,
--     selling_price NUMBER(10,2),
--     tax_exclusive_price NUMBER(10,2),
--     avg_rating FLOAT,
--     review_count INTEGER,
--     in_stock BOOLEAN,
--     scraped_at TIMESTAMP,
--     source_page_url STRING,
--     FOREIGN KEY (product_id)
--         REFERENCES ANALYTICS.DIM_PRODUCT(product_id)

-- );

---------------------------------------------------------------
-- 5. STAGE FOR FILE LOADING
---------------------------------------------------------------
USE SCHEMA RAW;

CREATE OR REPLACE STAGE PRODUCT_STAGE;

---------------------------------------------------------------
-- 6. FILE FORMAT (CSV)
---------------------------------------------------------------
CREATE OR REPLACE FILE FORMAT CSV_FORMAT
TYPE = CSV
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
SKIP_HEADER = 1
EMPTY_FIELD_AS_NULL = TRUE;
