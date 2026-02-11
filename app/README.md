
# 🖥️ Streamlit App Execution

  

This Streamlit application provides a simple user interface for
non-technical stakeholders to query procurement insights without
accessing Snowflake or writing SQL.

  

The app allows procurement or operations teams to filter industrial
products and instantly view recommended purchasing options.

 
    

------------------------------------------------------------------------

  

## 📊 Features

  

The application connects directly to the analytics warehouse and enables filtering using business parameters:

  

**Filters Available**

  

- Category
- Country of Origin
- Maximum Lead Time (days)
- Minimum Rating
- Maximum Price

  

**Output**

  

- Top 20 recommended products
- Sorted by highest rating and lowest price
- Displays reliability and delivery information

  

------------------------------------------------------------------------

  

## ⚙️ Requirements

  

Python 3.10+

  

Install dependencies:

  

``` bash

pip  install  streamlit
pip  install  pandas
pip  install  snowflake-connector-python

```

  

(Or create `requirements.txt` and run:)

  

``` bash
pip  install  -r  requirements.txt
```

  

------------------------------------------------------------------------

  

## 🔐 Snowflake Connection

  

Before running the app, verify the Snowflake credentials :
Locate secrets.toml inside /.streamilt

  

``` python

snowflake.connector.connect(
user = "jeevatj"
password = "veTigJ88s3SP9gY"
account = "rlxazxg-ow84266"
warehouse = "COMPUTE_WH"
database = "INDUSTRIAL_PROCUREMENT_DB"
schema = "ANALYTICS"
role = "ACCOUNTADMIN"
)

```

  

This credentials will help the user to get in touch with the database.
  

------------------------------------------------------------------------

  

## ▶️ Running the Application

  

Navigate to the app folder:

  

``` bash
cd  app
```

  

Run Streamlit:

  

``` bash
streamlit  run  app.py
```

  

The browser will automatically open:

  

http://localhost:8501

  

------------------------------------------------------------------------

  

## 🧠 What the App Does

  

When **Run Query** is clicked:

  

1. Filters are applied
2. SQL query is executed on `FCT_PRODUCT_SNAPSHOT` joined with
`DIM_PRODUCT`
3. Results returned from Snowflake
4. Data displayed as a table
5. Export CSV to download the result

  

The stakeholder receives a ready-to-use procurement shortlist.

  

------------------------------------------------------------------------

  

## 📌 Example Use Case

  

A maintenance engineer needs a replacement tool urgently.

  

They can select:

  

Category: Drilling
Minimum Rating: 4
Max Lead Time: 5 days
Max Price: ₹10,000

  

The app instantly returns the most reliable available products instead
of manually searching supplier websites.

  

------------------------------------------------------------------------

  

## 🛑 Notes

  

- The app requires an active internet connection and Snowflake
warehouse running.

- If no data appears, ensure dbt models have been executed
(`dbt run`).