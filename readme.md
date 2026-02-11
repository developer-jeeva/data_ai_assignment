
  

# 🏭 Industrial Procurement Data Pipeline

  

  

An end-to-end **mini data engineering pipeline** that collects industrial product data from public procurement listings, stores it in a cloud warehouse, transforms it into an analytics model, and enables decision support through analytics.

  

  

This project demonstrates:

  

  

* Web Scraping

* Cloud Data Warehousing (Snowflake)

* Data Modeling (dbt)

* Analytical SQL

* Business Intelligence

* Data Quality Testing

  

  

---

  

  

## 📌 Project Overview

  

  

The pipeline automatically collects product data from an industrial procurement website, loads it into a cloud warehouse, models it into an analytics-ready star schema, and enables business analysis.

  

---

  

  

## 📂 Data Source

  

  

Public procurement product listings were scraped from:

  

  

**Website**

  

https://www.industrybuying.com/

  

  

**Category Used**

  

```

Power Tools → drills, saws, cutters, accessories

```

  

  

---

  

  

## 📊 Data Collected

  

  

The scraper extracts the following attributes:

  

  

* product_name
* brand
* SKU
* category
* price
* rating
* review_count
* stock_availability
* lead_time
* country_of_origin
* source_url
* scrape_timestamp
* full_raw_json_payload

  

  

The raw dataset is saved as:

  

  

```

  

raw_data.csv

  

```

  

  

---

  

  

## 🕷️ How to Run the Scraper

  

  

### Step 1 — Create Python Environment

  

  

```bash

conda  create  -n  data_ai_assessment  python=3.10
conda  activate  data_ai_assessment

```

  

  

### Step 2 — Install Dependencies

  

  

Navigate to the scraper directory:

  

  

```bash

cd  scraper

pip  install  -r  requirements.txt

```

  

  

### Step 3 — Run Scraper

  

  

```bash

python  scraper.py

```

  

  

After execution:

  

  

```

..output/raw_data.csv

```

  

  

will be generated in the project root directory.

  

  

---

  

  

## ☁️ Snowflake Setup (Database + Tables)

  

  

Use below credentials to login snowflake:

url: [Snowflake Host URL](https://rlxazxg-ow84266.snowflakecomputing.com/)

      user: dbtuser
      password: dataAItest2026#

  

Open **Snowflake Worksheets** and run:

  

  

```

/sql/01_create_tables.sql

```

  

  

This script will:

  

  

* Create warehouse

* Create database

* Create RAW schema (ingestion layer)

* Create ANALYTICS schema (modeled layer)

* Create raw ingestion table

* Create analytics tables

  

  

---

  

  

## 📥 Load Data into Snowflake

  

  

### Step 1 — Upload CSV to Snowflake Stage

  

  

In Snowflake UI:

  

  

```

Data → Databases → INDUSTRIAL_PROCUREMENT_DB → RAW → PRODUCT_INGESTION → Load Data

```

  

  

Upload:

  

  

```

raw_data.csv

```

  

  

Snowflake automatically places the file into an internal stage.

  

  

---

  

  

### Step 2 — Load into Table

  

  

Run:

  

  

```

/sql/02_load_data.sql

```

  

  

This uses the Snowflake `COPY INTO` command to load the CSV into the raw ingestion table.

  

  

After this step:

  

  

```

RAW.PRODUCT_INGESTION

```

  

  

contains the scraped dataset.

  

  

---

  

  

## 🔧 Running dbt Transformations

  

  

### Step 1 — Install dbt Snowflake Adapter

  

  

```bash

pip  install  dbt-snowflake

```

  

  

---

  

  

### Step 2 — Configure Connection

  

  

Create the file:

  

  

```

C:\Users\<username>\.dbt\profiles.yml

```

  

  

Add your Snowflake credentials:

  

  

```yaml
dbt_project:
target: dev
outputs:
dev:
type: snowflake
account: rlxazxg-ow84266
user: dbtuser
password: dataAItest2026#
role: ACCOUNTADMIN
warehouse: COMPUTE_WH
database: INDUSTRIAL_PROCUREMENT_DB
schema: ANALYTICS
threads: 1
client_session_keep_alive: False

```

  

  

---

  

  

### Step 3 — Test Connection

  

  

```bash

cd  dbt_project

dbt  debug

```

  

  

Expected output:

  

  

```

All checks passed!

```

  

  

---

  

  

### Step 4 — Run Models

  

  

```bash

dbt  run

```

  

  

This creates:

  

  

* staging model

  

* dimension table

  

* fact table

  

  

---

  

  

### Step 5 — Run Tests

  

  

```bash

dbt  test

```

  

  

This validates:

  

  

* uniqueness

* not-null constraints

* fact-dimension relationships

  

  

---

  

  

## 🏗️ Final Data Model

  

  

The warehouse follows a **modern analytics architecture**:

  

  

### Bronze Layer (Raw)

  

```

RAW.PRODUCT_INGESTION

```

  

  

### Silver Layer (Staging)

  

```

stg_product_catalog

```

  

  

### Gold Layer (Analytics — Star Schema)

  

```

DIM_PRODUCT

FCT_PRODUCT_SNAPSHOT

```

  

  

---

  

## 🚀 How the Pipeline Works

  

  

1. Scraper extracts procurement listings

2. Data stored as CSV

3. CSV loaded into Snowflake RAW layer

4. dbt transforms data into staging

5. dbt builds analytics star schema

6. Analytics queries enable procurement insights

  

  

---

  

## 👨‍💻 Author

  

  

**Jeevanandam T**

Data Engineering Enthusiast