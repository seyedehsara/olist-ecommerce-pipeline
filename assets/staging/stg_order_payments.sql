/* @bruin
name: staging.stg_order_payments
type: duckdb.sql
materialization:
  type: table
depends:
  - raw.order_payments
columns:
  - name: order_id
    type: varchar
    checks:
      - name: not_null
  - name: payment_value
    type: float
    checks:
      - name: not_null
      - name: non_negative
@bruin */

SELECT
    order_id,
    payment_sequential,
    LOWER(TRIM(payment_type))       AS payment_type,
    payment_installments,
    ROUND(CAST(payment_value AS DOUBLE), 2) AS payment_value
FROM raw.order_payments
WHERE order_id IS NOT NULL
