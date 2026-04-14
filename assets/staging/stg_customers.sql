/* @bruin
name: staging.stg_customers
type: duckdb.sql
materialization:
  type: table
depends:
  - raw.customers
columns:
  - name: customer_id
    type: varchar
    checks:
      - name: not_null
      - name: unique
  - name: customer_state
    type: varchar
    checks:
      - name: not_null
@bruin */

SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    LOWER(TRIM(customer_city))  AS customer_city,
    UPPER(TRIM(customer_state)) AS customer_state
FROM raw.customers
WHERE customer_id IS NOT NULL
