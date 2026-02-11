import streamlit as st
import pandas as pd
import snowflake.connector

# ------------------------------------------------
# Page configuration
# ------------------------------------------------
st.set_page_config(
    page_title="Industrial Procurement Assistant",
    page_icon="🏭",
    layout="wide"
)

# ------------------------------------------------
# Snowflake Connection (using secrets)
# ------------------------------------------------
@st.cache_resource
def get_connection():
    conn = snowflake.connector.connect(**st.secrets["snowflake"])
    return conn


def run_query(query, params=None):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(query, params)
    df = pd.DataFrame(cur.fetchall(), columns=[col[0] for col in cur.description])
    return df


# ------------------------------------------------
# Title
# ------------------------------------------------
st.title("🏭 Industrial Procurement Assistant")

st.markdown("""
This tool helps identify **reliable, affordable, and fast-delivery industrial products**  from industrybuying.com.
""")

# ------------------------------------------------
# Load filter values
# ------------------------------------------------
categories = run_query("""
SELECT DISTINCT category
FROM DIM_PRODUCT
ORDER BY category
""")['CATEGORY'].dropna().tolist()

countries = run_query("""
SELECT DISTINCT country_of_origin
FROM DIM_PRODUCT
ORDER BY country_of_origin
""")['COUNTRY_OF_ORIGIN'].dropna().tolist()


# ====================================================
# SIDEBAR FILTERS
# ====================================================
st.sidebar.header("🔎 Product Filters")

category = st.sidebar.selectbox("Category", ["All"] + categories)
country = st.sidebar.selectbox("Country of Origin", ["All"] + countries)

st.sidebar.markdown("### Delivery & Quality")

max_lead_days = st.sidebar.slider("Maximum Lead Time (days)", 0, 15, 7)
min_rating = st.sidebar.slider("Minimum Rating", 0.0, 5.0, 3.5, 0.1)

st.sidebar.markdown("### Budget")

max_price = st.sidebar.slider("Maximum Price (INR)", 0, 100000, 10000)

run_button = st.sidebar.button("🚀 Run Query")


# ====================================================
# QUERY EXECUTION
# ====================================================
if run_button:

    filters = []
    params = {}

    # Base condition
    filters.append("f.in_stock = TRUE")
    filters.append("d.lead_time_days <= %(lead_days)s")
    filters.append("d.avg_rating >= %(rating)s")
    filters.append("f.selling_price <= %(price)s")

    params["lead_days"] = max_lead_days
    params["rating"] = min_rating
    params["price"] = max_price

    if category != "All":
        filters.append("d.category = %(category)s")
        params["category"] = category

    if country != "All":
        filters.append("d.country_of_origin = %(country)s")
        params["country"] = country

    where_clause = " AND ".join(filters)

    query = f"""
    SELECT
        d.product_name,
        d.brand,
        d.category,
        d.country_of_origin,
        d.avg_rating,
        d.review_count,
        d.lead_time_days,
        f.selling_price
    FROM FCT_PRODUCT_SNAPSHOT f
    JOIN DIM_PRODUCT d
        ON f.product_id = d.product_id
    WHERE {where_clause}
    ORDER BY d.avg_rating DESC, f.selling_price ASC
    LIMIT 20
    """

    with st.spinner("Fetching recommended products..."):
        df = run_query(query, params)

    # ------------------------------------------------
    # Display results
    # ------------------------------------------------
    st.subheader("📊 Recommended Products")

    if df.empty:
        st.warning("No products match your filters.")
    else:
        # Download option
        csv = df.to_csv(index=False).encode("utf-8")
        st.download_button(
            "Export CSV",
            csv,
            "recommended_products.csv",
            "text/csv"
        )
        st.dataframe(df, use_container_width=True)



else:
    st.info("Use the filters in the sidebar and click 'Run Query'.")
