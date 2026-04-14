/* @bruin
name: staging.stg_products
type: duckdb.sql
materialization:
  type: table
depends:
  - raw.products
columns:
  - name: product_id
    type: varchar
    checks:
      - name: not_null
      - name: unique
@bruin */

SELECT
    product_id,
    COALESCE(product_category_name, 'unknown') AS product_category_name,
    CAST(product_weight_g AS DOUBLE)           AS product_weight_g,
    CAST(product_length_cm AS DOUBLE)          AS product_length_cm,
    CAST(product_height_cm AS DOUBLE)          AS product_height_cm,
    CAST(product_width_cm AS DOUBLE)           AS product_width_cm
FROM raw.products
WHERE product_id IS NOT NULL
