/* @bruin
name: mart.revenue_by_state
type: athena.sql
materialization:
  type: table
depends:
  - staging.stg_orders
  - staging.stg_order_items
  - staging.stg_customers
columns:
  - name: customer_state
    type: varchar
    checks:
      - name: not_null
  - name: total_revenue
    type: double
    checks:
      - name: not_null
@bruin */

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id)    AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    ROUND(SUM(i.price), 2)        AS total_revenue,
    ROUND(AVG(i.price), 2)        AS avg_order_value
FROM staging.stg_orders o
JOIN staging.stg_customers c ON o.customer_id = c.customer_id
JOIN staging.stg_order_items i ON o.order_id = i.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY 1
ORDER BY total_revenue DESC
