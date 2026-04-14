/* @bruin
name: staging.stg_order_items
type: duckdb.sql
materialization:
  type: table
depends:
  - raw.order_items
columns:
  - name: order_id
    type: varchar
    checks:
      - name: not_null
  - name: price
    type: float
    checks:
      - name: not_null
      - name: positive
@bruin */

SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_date,
    ROUND(CAST(price AS DOUBLE), 2)          AS price,
    ROUND(CAST(freight_value AS DOUBLE), 2)  AS freight_value,
    ROUND(CAST(price AS DOUBLE) + CAST(freight_value AS DOUBLE), 2) AS total_amount
FROM raw.order_items
WHERE order_id IS NOT NULL
