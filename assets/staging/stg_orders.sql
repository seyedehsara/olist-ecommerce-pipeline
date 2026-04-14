/* @bruin
name: staging.stg_orders
type: duckdb.sql
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
  - name: customer_id
    type: varchar
    checks:
      - name: not_null
  - name: order_status
    type: varchar
    checks:
      - name: not_null
@bruin */

SELECT
    order_id,
    customer_id,
    order_status,
    CAST(order_purchase_timestamp AS TIMESTAMP)    AS order_purchase_timestamp,
    CAST(order_approved_at AS TIMESTAMP)           AS order_approved_at,
    CAST(order_delivered_carrier_date AS TIMESTAMP) AS order_delivered_carrier_date,
    CAST(order_delivered_customer_date AS TIMESTAMP) AS order_delivered_customer_date,
    CAST(order_estimated_delivery_date AS TIMESTAMP) AS order_estimated_delivery_date
FROM raw.orders
WHERE order_id IS NOT NULL
