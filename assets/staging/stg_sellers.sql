/* @bruin
name: staging.stg_sellers
type: athena.sql
materialization:
  type: table
depends:
  - raw.sellers
columns:
  - name: seller_id
    type: varchar
    checks:
      - name: not_null
      - name: unique
@bruin */

SELECT
    seller_id,
    seller_zip_code_prefix,
    LOWER(TRIM(seller_city))  AS seller_city,
    UPPER(TRIM(seller_state)) AS seller_state
FROM olist.raw_sellers
WHERE seller_id IS NOT NULL
  AND seller_id != 'seller_id'
