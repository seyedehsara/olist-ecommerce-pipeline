# 🛒 Olist Brazilian E-Commerce Analytics Pipeline

An end-to-end data engineering pipeline built with **Bruin**, **AWS S3**, **AWS Athena**, and **Looker Studio** to analyze Brazilian e-commerce trends from 2016 to 2018.

---

## 📌 Problem Statement

Brazilian e-commerce has grown rapidly in recent years. This project investigates:

- **How has daily revenue evolved** between 2016 and 2018?
- **Which Brazilian states** generate the most e-commerce revenue?
- **Which product categories** are the top revenue drivers?

By answering these questions, businesses can make informed decisions about regional expansion, marketing spend, and inventory prioritization.

---

## 📦 Dataset

**Source:** [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) on Kaggle

Olist is the largest department store in Brazilian marketplaces. The dataset contains ~100,000 orders placed between 2016 and 2018 across multiple Brazilian marketplaces.

### Tables used:

| File | Description | Rows |
|---|---|---|
| olist_orders_dataset.csv | Core order information and status | ~99K |
| olist_order_items_dataset.csv | Items within each order, price, freight | ~112K |
| olist_order_payments_dataset.csv | Payment method and value per order | ~104K |
| olist_customers_dataset.csv | Customer location and unique ID | ~99K |
| olist_products_dataset.csv | Product category and dimensions | ~33K |
| olist_sellers_dataset.csv | Seller location | ~3K |

---


## 🏗️ Architecture

The pipeline follows a medallion architecture with three layers:

**1. Ingestion**
CSV files are downloaded from Kaggle and uploaded to AWS S3. Athena external tables are created on top of the S3 files — no data is moved or duplicated at this stage.

**2. Staging**
Bruin SQL assets read from the raw Athena tables and apply cleaning transformations: type casting, null handling, text standardization, and data quality checks. Results are materialized as Iceberg tables in Athena.

**3. Mart**
Bruin SQL assets join and aggregate the staging tables into three business-level tables ready for dashboarding: daily revenue, revenue by state, and top product categories.

**4. Dashboard**
Looker Studio connects to the mart tables and presents three interactive charts.

### Data Flow

> Kaggle CSVs → AWS S3 → Athena Raw Tables → Bruin Staging → Bruin Mart → Looker Studio
---

## 🛠️ Technology Stack

| Component | Tool | Purpose |
|---|---|---|
| Pipeline tool | [Bruin](https://getbruin.com) | Orchestration, transformation, quality checks |
| Raw storage | AWS S3 | Store raw CSV files |
| Data warehouse | AWS Athena | Query engine on top of S3 (Iceberg tables) |
| Local development | DuckDB | Fast local iteration before pushing to cloud |
| Dashboard | Looker Studio | Visualization and reporting |
| Version control | GitHub | Code repository |
| CLI | AWS CLI | Infrastructure management |

---

## 🔧 What is Bruin?

[Bruin](https://getbruin.com) is an open-source end-to-end data pipeline tool that replaces the need for separate tools like Airflow (orchestration), dbt (transformation), and Great Expectations (quality checks). Everything lives in one place:

- **Assets** are SQL or Python files with a `@bruin` header defining metadata, dependencies, and quality checks
- **Lineage** is automatically inferred from `depends:` declarations
- **Quality checks** run automatically after each asset executes
- **Environments** allow switching between local DuckDB and cloud Athena with one flag

### Example Bruin asset:

```sql
/* @bruin
name: staging.stg_orders
type: athena.sql
materialization:
  type: table
depends:
  - raw.orders
columns:
  - name: order_id
    type: varchar
    checks:
      - name: not_null
      - name: unique
@bruin */

SELECT
    order_id,
    customer_id,
    order_status,
    TRY_CAST(order_purchase_timestamp AS TIMESTAMP) AS order_purchase_timestamp
FROM olist.raw_orders
WHERE order_id IS NOT NULL
```

---

## 📁 Project Structure

```
olist-ecommerce-pipeline/
├── .bruin.yml              # Environment configs (gitignored)
├── pipeline.yml            # Pipeline definition
├── README.md
├── assets/
│   ├── raw/                # Seed assets (local DuckDB dev)
│   │   ├── raw_orders.asset.yml
│   │   ├── raw_customers.asset.yml
│   │   ├── raw_order_items.asset.yml
│   │   ├── raw_order_payments.asset.yml
│   │   ├── raw_products.asset.yml
│   │   └── raw_sellers.asset.yml
│   ├── staging/            # Cleaning, casting, validation
│   │   ├── stg_orders.sql
│   │   ├── stg_customers.sql
│   │   ├── stg_order_items.sql
│   │   ├── stg_order_payments.sql
│   │   ├── stg_products.sql
│   │   └── stg_sellers.sql
│   └── mart/               # Aggregated business metrics
│       ├── mart_daily_revenue.sql
│       ├── mart_revenue_by_state.sql
│       └── mart_top_product_categories.sql
└── macros/                 # Reusable Jinja SQL macros
```
---

## 📊 Pipeline Layers

### Raw Layer
External Athena tables pointing directly to CSV files stored in S3. No transformation — data is read as-is from:
s3://sara-olist-pipeline/raw/orders/
s3://sara-olist-pipeline/raw/customers/
...

### Staging Layer
SQL assets that clean and standardize the raw data:
- Cast string columns to proper types (`TRY_CAST` for safe casting)
- Standardize text (`LOWER`, `UPPER`, `TRIM`)
- Handle nulls with `COALESCE`
- Filter out header rows and invalid records
- Run quality checks on every column

### Mart Layer
Aggregated tables ready for dashboarding:

| Table | Description |
|---|---|
| `mart.daily_revenue` | Daily order count, total revenue, freight, avg order value |
| `mart.revenue_by_state` | Revenue, orders, and customers grouped by Brazilian state |
| `mart.top_product_categories` | Revenue and order count per product category |

---

## ✅ Data Quality

Bruin runs quality checks automatically after each asset. Checks used in this project:

| Check | Description | Applied to |
|---|---|---|
| `not_null` | Column has no null values | All key columns |
| `unique` | Column has no duplicate values | Primary keys |
| `positive` | All values are > 0 | Revenue, price |
| `non_negative` | All values are >= 0 | Payment value |

Total: **24 quality checks** across 15 assets, all passing.

---

## 📈 Dashboard

🔗 [View the Olist E-Commerce Analytics Dashboard](https://datastudio.google.com/reporting/3871b131-30d1-4015-8d31-d13f5051091a)

![Olist E-Commerce Analytics Dashboard](Screenshot%202026-04-17%20163410.png)

### Charts:

**1. Daily Revenue Trend (2016–2018)**
Shows how revenue grew over time. Key observation: revenue was low in late 2016, grew steadily through 2017, peaked in late 2017/early 2018, with a notable spike likely corresponding to Black Friday promotions.

**2. Revenue by Brazilian State**
São Paulo (SP) dominates with ~40% of total revenue, followed by Rio de Janeiro (RJ) and Minas Gerais (MG). This reflects Brazil's population distribution and economic concentration in the Southeast.

**3. Top Product Categories by Revenue**
Health & beauty products lead revenue, followed by watches/gifts and furniture/décor. This suggests Brazilian consumers prioritize personal care and home goods in online shopping.

---

## 🚀 How to Reproduce

### Prerequisites
- [Bruin CLI](https://getbruin.com/docs/bruin/getting-started/introduction/installation.html) installed
- AWS CLI configured (`aws configure`)
- Python 3.8+ with `pandas` installed
- Git Bash (on Windows)

### Step 1 — Clone the repository
```bash
git clone https://github.com/seyedehsara/olist-ecommerce-pipeline.git
cd olist-ecommerce-pipeline
```

### Step 2 — Download the dataset
Download from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and place all CSV files in the `data/` folder.

### Step 3 — Configure Bruin
Create a `.bruin.yml` file in the project root:

```yaml
default_environment: default

environments:
  default:
    connections:
      duckdb:
        - name: "duckdb-default"
          path: "olist.duckdb"

  production:
    connections:
      athena:
        - name: "athena-default"
          region: "eu-west-1"
          database: "olist"
          access_key_id: "YOUR_AWS_ACCESS_KEY_ID"
          secret_access_key: "YOUR_AWS_SECRET_ACCESS_KEY"
          query_results_path: "s3://YOUR-BUCKET/athena-results/"
```

### Step 4 — Run locally with DuckDB
```bash
bruin run . --workers 1
```

### Step 5 — Set up AWS infrastructure
```bash
# Create S3 bucket
aws s3 mb s3://YOUR-BUCKET --region eu-west-1

# Upload CSV files to S3
aws s3 cp data/ s3://YOUR-BUCKET/raw/ --recursive --region eu-west-1

# Create Athena databases
aws athena start-query-execution \
  --query-string "CREATE DATABASE IF NOT EXISTS olist" \
  --result-configuration "OutputLocation=s3://YOUR-BUCKET/athena-results/" \
  --region eu-west-1

aws athena start-query-execution \
  --query-string "CREATE DATABASE IF NOT EXISTS staging" \
  --result-configuration "OutputLocation=s3://YOUR-BUCKET/athena-results/" \
  --region eu-west-1

aws athena start-query-execution \
  --query-string "CREATE DATABASE IF NOT EXISTS mart" \
  --result-configuration "OutputLocation=s3://YOUR-BUCKET/athena-results/" \
  --region eu-west-1
```

### Step 6 — Run staging and mart on Athena
```bash
for f in assets/staging/*.sql assets/mart/*.sql; do
  bruin run $f --environment production --workers 1 --no-log-file
done
```

---

## 🔑 Key Results

- Processed **~100,000 orders** across 6 tables
- **15 pipeline assets** with **24 quality checks** all passing
- São Paulo accounts for **~40% of total revenue**
- **Health & beauty** is the #1 revenue category
- Revenue grew approximately **3x** between late 2016 and mid-2018

---

## 📝 Notes

- `.bruin.yml` is gitignored — never commit credentials
- Raw Athena tables are external tables pointing to S3 — no data duplication
- Staging and mart tables are materialized as Iceberg tables in Athena
- Local development uses DuckDB for fast iteration without AWS costs

