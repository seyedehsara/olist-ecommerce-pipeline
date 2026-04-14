/* @bruin
name: mart.top_product_categories
type: duckdb.sql
materialization:
  type: table
depends:
  - staging.stg_order_items
  - staging.stg_products
  - staging.stg_orders
columns:
  - name: product_category_name
    type: varchar
    checks:
      - name: not_null
  - name: total_revenue
    type: float
    checks:
      - name: not_null
@bruin */

SELECT
    p.product_category_name,
    COUNT(DISTINCT i.order_id)   AS total_orders,
    COUNT(DISTINCT i.product_id) AS total_products,
    ROUND(SUM(i.price), 2)       AS total_revenue,
    ROUND(AVG(i.price), 2)       AS avg_price
FROM staging.stg_order_items i
JOIN staging.stg_products p ON i.product_id = p.product_id
JOIN staging.stg_orders o ON i.order_id = o.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY 1
ORDER BY total_revenue DESC
