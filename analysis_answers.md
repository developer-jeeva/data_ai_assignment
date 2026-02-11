
# Part B — BI, Stakeholder Thinking & Automation

  

---

  

## B1) Dashboard Design
### Dashboard Title
**Industrial Procurement Intelligence Dashboard**

  

### Target Stakeholder Persona

**Primary User:** Operations Manager / Procurement Manager in a manufacturing organization.

  

This stakeholder is responsible for:

- Selecting suppliers

- Ensuring uninterrupted production

- Controlling purchasing costs

- Minimizing operational risk

  

The user is not interested in raw datasets or technical metrics. They require quick, reliable purchasing decisions backed by data.

  

Therefore, the dashboard focuses on **decision support**, not data exploration.

  

---

  

### Key Performance Indicators (KPIs)

**Average Product Price**

Provides a baseline understanding of the market price level and helps detect overpriced suppliers.

  

**In-Stock Product Count**

Measures supply availability and procurement risk. A low value indicates potential sourcing issues.

  

**Average Supplier Rating**

Acts as a proxy for product quality and supplier reliability.

  

**Average Lead Time (Days)**

A critical operational KPI. Longer lead times increase the risk of production downtime.

  

**High-Rating Products (> 4 Stars)**

Allows stakeholders to quickly shortlist reliable products.

  

**Affordable Reliable Products**

*(Price < ₹10,000 AND Rating > 4)*

A direct decision KPI identifying best-value procurement options.

  

---

  

### Visualizations

  

**Price Trend Line Chart (Daily)**

Tracks price movement over time and detects supplier pricing changes.

  

**Country vs Average Price (Bar Chart)**

Helps compare sourcing regions and identify cost-efficient countries.

  

**Lead Time Distribution (Histogram)**

Displays delivery risk across available suppliers.

  

**Top Rated Products (Table)**

Provides an immediate purchasing shortlist.

  

**Rating vs Price (Scatter Plot)**

Identifies high-quality products at reasonable cost (value optimization).

  

**Category-wise Product Count (Bar Chart)**

Shows catalog coverage and availability by product category.

  

---

  

### Filters / Slicers

- Product Category
- Country of Origin
- Minimum Rating
- Maximum Price
- Maximum Lead Time

  

These filters allow stakeholders to quickly narrow procurement options based on operational constraints.

  

---

  

### Dashboard Layout Decision

**Single-Page Dashboard**

  

Procurement decisions are operational and time-sensitive. Users typically need a rapid answer ("What should I buy today?") rather than deep analytical navigation. A single page enables quick assessment of availability, cost, and risk.

  

---

  

## B2) Stakeholder Insights: Obvious vs Non-Obvious

  

### 1. Obvious Insights (Direct Stakeholder Questions)

  

**Cheapest Products in Each Category**

Used to reduce purchasing cost and quickly shortlist budget options.

  

**Top Rated Products**

Helps identify reliable and good-quality products to avoid returns and complaints.

  

**Products Currently In Stock**

Directly impacts production continuity. Out-of-stock items may stop factory operations.

  

**Fastest Delivery Products (Lowest Lead Time)**

Important when a replacement part is urgently needed to resume machine operations.

  

**Average Price per Category**

Helps stakeholders understand the normal market price and identify overpriced suppliers.

  

---

  

### 2. Non-Obvious Insights (High-Value Analytical Discoveries)

  

**Price vs Quality Mismatch (Value Identification)**

Some mid-priced products have higher ratings than premium products. This enables procurement to buy best-value items instead of simply choosing the cheapest or most expensive.

  

**Supply Risk Detection (Lead Time + Stock Availability)**

Categories with long delivery times and low stock availability indicate potential supply chain risk, enabling proactive sourcing.

  

**Country Reliability Patterns**

Products from certain countries consistently show faster delivery or better ratings. Procurement teams can prioritize reliable sourcing regions.

  

**Review Confidence Score**

A 5-star product with 1 review is less reliable than a 4.3-star product with 200 reviews. Review count measures confidence in quality.

  

**Category Price Volatility**

Some product categories experience frequent price changes. These items should be bulk-purchased early to avoid future cost increases.

  

---

  

## B3) Data Quality & Reliability Plan

  

### 1. Data Quality Checks

  

#### Mandatory Field Validation

Critical columns must never be empty:

- product_name
- sku
- category
- scraped_at

  

Records missing these fields are rejected.

  

---

  

#### Price Validation

Rules:

-  `selling_price > 0`
-  `selling_price < ₹10,00,000` (sanity threshold)

  

Prevents corrupted or mis-parsed data from entering analytics.

  

---

  

#### Rating Validation

Rule:

-  `0 ≤ rating ≤ 5`

  

Values outside this range indicate scraping or parsing errors.

  

---

  

#### Duplicate Detection

Duplicates identified using SKU or product URL hash.

If the same SKU appears multiple times in the same scrape run:

- Keep the latest record
- Mark older records as superseded

  

---

  

#### Lead Time Validation

Rules:

- Cannot be negative
- Cannot exceed 60 days

  

Unexpected formats indicate parsing or layout issues.

  

---

  

### 2) Detecting Website Layout Changes

  

Web scraping pipelines often fail when site structure changes.

  

Monitoring mechanisms:

-  **Null Spike Detection** — sudden increase in null price/rating/name
-  **Schema Validation** — missing JSON fields in raw payload
-  **Automated Alerting** — email/Slack notifications on failure

  

---

  

### 3) Historical Data Versioning

  

Approach:

- Raw ingestion table remains immutable
- Use `scraped_at` timestamp as snapshot versio
- Insert new records instead of updating

  

Enables:

- Price tracking
- Supplier performance analysis
- Auditability

  

---

  

### 4) Handling Duplicates

  

Duplicates occur when:

- Same product appears in multiple categories
- Multiple daily scrapes

  

Solution:

- Create surrogate key: `MD5(sku)`
- One unique record in `dim_product`
- Daily observations in `fct_product_snapshot`

  

---

  

## B4) LLM Integration Use Cases

  

### Use Case 1 — Supplier Risk Explanation Assistant

  

**Objective:**

Help procurement teams quickly understand whether a supplier is risky without analyzing multiple metrics manually.

  

**Example Prompt**

“Is this supplier safe to buy from for an urgent requirement?”

  

**Data Retrieved**

- Rating
- Review count
- Lead time
- Stock availability
- Country of origin
- Historical price stability

  

**LLM Output**

- Reliability level (Low / Medium / High)
- Delivery risk assessment
- Quality confidence
- Recommended action (Buy / Consider Alternative / Avoid)

  

**Risks**

- Hallucinated conclusions
- Overconfidence

  

**Mitigation**

- Provide structured DB context only
- Show metrics alongside explanation
- Cache repeated analyses

  

---

  

### Use Case 2 — Purchase Recommendation Generator

  

**Objective:**

Recommend the most suitable product based on operational constraints.

  

**Example Prompt**

“I need a reliable drilling machine under ₹8,000 that can be delivered within 5 days.”

  

**Data Retrieved**

- Category
- Price
- Lead time
- Rating
- Review count

  

**LLM Output**

- 2–3 recommended products
- Reasoning
- Trade-offs
- Alternative options

  

**Risks**

- Bias due to incomplete data
- Constraint misinterpretation

  

**Mitigation**

- Hard filter before LLM call
- Validate output against database

  

**Business Value**

The system moves from reporting:

> “Here is the data.”

  

to decision assistance:

> “Here is what you should do and why.”

  

---

  

## B5) n8n Workflow Automation Design

  

### Automation Goal

Automatically monitor the industrial product market and alert stakeholders about purchase opportunities or operational risks.

  

Runs weekly and converts analytics into operational decisions.

  

---

  

### Trigger

**Scheduled — Every Monday at 8:00 AM**

  

Rationale: Procurement planning typically occurs at the beginning of the work week.

  

---

  

### Workflow Steps

  

**1. Extract**

Query Snowflake: `FCT_PRODUCT_SNAPSHOT JOIN DIM_PRODUCT`

  

Retrieve:

- Availability
- Price
- Rating
- Lead time
- Category

  

**2. Transform**

- Opportunity: rating ≥ 4.2, below category average, lead time ≤ 5 days, in stock
- Risk: lead time increased, out of stock, price ↑ > 15%

  

**3. Classification**

- Purchase Opportunity
- Supply Risk
- Price Alert

  

**4. Output**

Generate report:

- Recommended products
- Risky categories
- Supplier alerts

  

**5. Delivery**

- Email (Procurement Team)
- Slack / Microsoft Teams

  

---

  

### Alert Logic

Triggered when:

- High-rated product becomes cheaper
- Frequently used item becomes unavailable
- Lead time increases significantly
- Price changes beyond threshold

  

---

  

### Failure Handling

- Retry after 10 minutes (3 attempts)
- Notify developers with logs
- Preserve last successful dataset

  

**False Positive Prevention**

- Condition persists for 2 runs
- Ignore <5% price changes
- Ignore <3 review products

  

**Most Important Event:**

Stock availability change for frequently purchased products (prevents production downtime).

  

---

  

## B6) Client Memo

  

A procurement intelligence solution has been implemented to automatically collect and analyze industrial supplier product data. The system gathers public supplier listings, structures them in a centralized database, and generates operational insights related to pricing, availability, delivery time, and product reliability.

  

The solution replaces manual website comparison and spreadsheet tracking with a continuously updated decision-support dataset. Procurement teams can quickly identify reliable products, monitor market pricing, and detect supply risks without manual research.

  

**Primary Business Value**

- Operational continuity
- Cost control
- Early detection of shortages and price spikes
- Consistent supplier selection

  

### Technology Stack

- Python web scraping (Requests, BeautifulSoup)
- Snowflake cloud data warehouse
- dbt transformation & modeling
- SQL analytics
- Streamlit decision interface

  

### Recommended Next Step

Integrate internal purchase and maintenance records to predict spare-part demand and enable proactive procurement instead of reactive purchasing.