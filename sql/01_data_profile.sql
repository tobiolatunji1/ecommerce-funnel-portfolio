-- Project 01: E-commerce Conversion Funnel Analysis
-- Source: bigquery-public-data.ga4_obfuscated_sample_ecommerce
-- Dialect: GoogleSQL / BigQuery

-- 1) Basic data profile
SELECT
  COUNT(*) AS total_events,
  COUNT(DISTINCT user_pseudo_id) AS unique_users,
  COUNT(DISTINCT event_date) AS active_days,
  MIN(PARSE_DATE('%Y%m%d', event_date)) AS first_event_date,
  MAX(PARSE_DATE('%Y%m%d', event_date)) AS last_event_date
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131';

-- 2) Event inventory
SELECT event_name, COUNT(*) AS event_count,
       COUNT(DISTINCT user_pseudo_id) AS users
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY event_name
ORDER BY event_count DESC;
