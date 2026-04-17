/* @bruin
name: staging.stg_products
type: athena.sql
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
    COALESCE(product_category_name, 'unknown')   AS product_category_name,
    TRY_CAST(product_weight_g AS DOUBLE)          AS product_weight_g,
    TRY_CAST(product_length_cm AS DOUBLE)         AS product_length_cm,
    TRY_CAST(product_height_cm AS DOUBLE)         AS product_height_cm,
    TRY_CAST(product_width_cm AS DOUBLE)          AS product_width_cm
FROM olist.raw_products
WHERE product_id IS NOT NULL
  AND product_id != 'product_id'
