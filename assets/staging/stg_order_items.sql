/* @bruin
name: staging.stg_order_items
type: athena.sql
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
    type: double
    checks:
      - name: not_null
      - name: positive
@bruin */

SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    TRY_CAST(shipping_limit_date AS TIMESTAMP)  AS shipping_limit_date,
    ROUND(TRY_CAST(price AS DOUBLE), 2)          AS price,
    ROUND(TRY_CAST(freight_value AS DOUBLE), 2)  AS freight_value,
    ROUND(TRY_CAST(price AS DOUBLE) + TRY_CAST(freight_value AS DOUBLE), 2) AS total_amount
FROM olist.raw_order_items
WHERE order_id IS NOT NULL
  AND order_id != 'order_id'
