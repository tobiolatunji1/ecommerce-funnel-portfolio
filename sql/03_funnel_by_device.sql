-- Funnel by device category. Export results as dashboard/device_funnel.csv
WITH user_device_steps AS (
  SELECT
    user_pseudo_id,
    device.category AS device_category,
    LOGICAL_OR(event_name = 'view_item') AS viewed_product,
    LOGICAL_OR(event_name = 'add_to_cart') AS added_to_cart,
    LOGICAL_OR(event_name = 'begin_checkout') AS began_checkout,
    LOGICAL_OR(event_name = 'purchase') AS purchased
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND user_pseudo_id IS NOT NULL
  GROUP BY user_pseudo_id, device_category
), funnel AS (
  SELECT device_category, 'Product view' AS funnel_step, 1 AS step_order,
         COUNTIF(viewed_product) AS users
  FROM user_device_steps GROUP BY device_category
  UNION ALL
  SELECT device_category, 'Add to cart', 2,
         COUNTIF(viewed_product AND added_to_cart)
  FROM user_device_steps GROUP BY device_category
  UNION ALL
  SELECT device_category, 'Begin checkout', 3,
         COUNTIF(viewed_product AND added_to_cart AND began_checkout)
  FROM user_device_steps GROUP BY device_category
  UNION ALL
  SELECT device_category, 'Purchase', 4,
         COUNTIF(viewed_product AND added_to_cart AND began_checkout AND purchased)
  FROM user_device_steps GROUP BY device_category
)
SELECT device_category, funnel_step, step_order, users,
       SAFE_DIVIDE(users, FIRST_VALUE(users) OVER (
         PARTITION BY device_category ORDER BY step_order
         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       )) AS conversion_from_product_view
FROM funnel
ORDER BY device_category, step_order;
