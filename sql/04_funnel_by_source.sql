-- Funnel by first observed traffic source/medium per user.
-- This is a simplified attribution view; it is not a causal estimate.
WITH events AS (
  SELECT
    user_pseudo_id,
    event_timestamp,
    event_name,
    COALESCE(NULLIF(traffic_source.source, ''), '(not set)') AS source,
    COALESCE(NULLIF(traffic_source.medium, ''), '(not set)') AS medium
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND user_pseudo_id IS NOT NULL
), user_source AS (
  SELECT user_pseudo_id, source, medium
  FROM events
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY user_pseudo_id ORDER BY event_timestamp
  ) = 1
), user_steps AS (
  SELECT
    user_pseudo_id,
    LOGICAL_OR(event_name = 'view_item') AS viewed_product,
    LOGICAL_OR(event_name = 'add_to_cart') AS added_to_cart,
    LOGICAL_OR(event_name = 'begin_checkout') AS began_checkout,
    LOGICAL_OR(event_name = 'purchase') AS purchased
  FROM events GROUP BY user_pseudo_id
), combined AS (
  SELECT s.source, s.medium, u.*
  FROM user_steps u JOIN user_source s USING (user_pseudo_id)
), funnel AS (
  SELECT source, medium, 'Product view' AS funnel_step, 1 AS step_order,
         COUNTIF(viewed_product) AS users FROM combined GROUP BY source, medium
  UNION ALL
  SELECT source, medium, 'Add to cart', 2,
         COUNTIF(viewed_product AND added_to_cart) FROM combined GROUP BY source, medium
  UNION ALL
  SELECT source, medium, 'Begin checkout', 3,
         COUNTIF(viewed_product AND added_to_cart AND began_checkout) FROM combined GROUP BY source, medium
  UNION ALL
  SELECT source, medium, 'Purchase', 4,
         COUNTIF(viewed_product AND added_to_cart AND began_checkout AND purchased) FROM combined GROUP BY source, medium
)
SELECT source, medium, funnel_step, step_order, users
FROM funnel
ORDER BY source, medium, step_order;
