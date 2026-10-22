-- Overall user funnel. A user qualifies for a step if they triggered that event
-- at any point in the selected date range; this is a user-level funnel, not a
-- strict same-session / ordered-path funnel.
WITH user_steps AS (
  SELECT
    user_pseudo_id,
    LOGICAL_OR(event_name = 'view_item') AS viewed_product,
    LOGICAL_OR(event_name = 'add_to_cart') AS added_to_cart,
    LOGICAL_OR(event_name = 'begin_checkout') AS began_checkout,
    LOGICAL_OR(event_name = 'purchase') AS purchased
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND user_pseudo_id IS NOT NULL
  GROUP BY user_pseudo_id
)
SELECT 'Product view' AS funnel_step, 1 AS step_order,
       COUNTIF(viewed_product) AS users
FROM user_steps
UNION ALL
SELECT 'Add to cart', 2, COUNTIF(viewed_product AND added_to_cart)
FROM user_steps
UNION ALL
SELECT 'Begin checkout', 3,
       COUNTIF(viewed_product AND added_to_cart AND began_checkout)
FROM user_steps
UNION ALL
SELECT 'Purchase', 4,
       COUNTIF(viewed_product AND added_to_cart AND began_checkout AND purchased)
FROM user_steps
ORDER BY step_order;
