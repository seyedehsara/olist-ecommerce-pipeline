/* @bruin
name: staging.stg_order_payments
type: athena.sql
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
    type: double
    checks:
      - name: not_null
      - name: non_negative
@bruin */

SELECT
    order_id,
    payment_sequential,
    LOWER(TRIM(payment_type))                    AS payment_type,
    TRY_CAST(payment_installments AS INTEGER)    AS payment_installments,
    ROUND(TRY_CAST(payment_value AS DOUBLE), 2)  AS payment_value
FROM olist.raw_order_payments
WHERE order_id IS NOT NULL
  AND order_id != 'order_id'
