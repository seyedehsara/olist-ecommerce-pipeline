/* @bruin
name: mart.daily_revenue
type: duckdb.sql
materialization:
  type: table
depends:
  - staging.stg_orders
  - staging.stg_order_items
columns:
  - name: order_date
    type: date
    checks:
      - name: not_null
  - name: total_revenue
    type: float
    checks:
      - name: not_null
      - name: positive
@bruin */

SELECT
    CAST(o.order_purchase_timestamp AS DATE) AS order_date,
    COUNT(DISTINCT o.order_id)               AS total_orders,
    ROUND(SUM(i.price), 2)                   AS total_revenue,
    ROUND(SUM(i.freight_value), 2)           AS total_freight,
    ROUND(AVG(i.price), 2)                   AS avg_order_value
FROM staging.stg_orders o
JOIN staging.stg_order_items i ON o.order_id = i.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY 1
ORDER BY 1
