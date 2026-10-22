-- Daily funnel-related event trends. Export as dashboard/daily_trend.csv
SELECT
  PARSE_DATE('%Y%m%d', event_date) AS event_day,
  COUNTIF(event_name = 'view_item') AS product_view_events,
  COUNTIF(event_name = 'add_to_cart') AS add_to_cart_events,
  COUNTIF(event_name = 'begin_checkout') AS checkout_events,
  COUNTIF(event_name = 'purchase') AS purchase_events,
  COUNT(DISTINCT IF(event_name = 'view_item', user_pseudo_id, NULL)) AS product_view_users,
  COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) AS purchaser_users
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY event_day
ORDER BY event_day;
