# Project 01 — E-commerce Conversion Funnel Analysis

**Portfolio track:** Product Analytics · Growth Analytics · SQL · Dashboarding  
**Dataset:** Google Analytics 4 sample ecommerce export for the Google Merchandise Store  
**SQL dialect:** GoogleSQL (BigQuery)  
**Dashboard:** Streamlit + Plotly

## Business question

Where do shoppers drop out between viewing a product and completing a purchase, and how does the funnel vary by device and traffic source?

## Dataset

The public dataset is available in BigQuery as:

`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

It covers November 1, 2020 through January 31, 2021. The data is obfuscated and may contain placeholder values or internal inconsistencies. Treat findings as a portfolio exercise, not as current business benchmarks.

Official documentation: https://developers.google.com/analytics/bigquery/web-ecommerce-demo-dataset

## Repository structure

```text
sql/
  01_data_profile.sql
  02_overall_funnel.sql
  03_funnel_by_device.sql
  04_funnel_by_source.sql
  05_daily_trend.sql
dashboard/
  app.py
  overall_funnel.csv   # add after exporting query results
  device_funnel.csv    # add after exporting query results
  source_funnel.csv    # add after exporting query results
  daily_trend.csv      # add after exporting query results
requirements.txt
README.md
```

## Run the SQL

1. Open the BigQuery console and select a Google Cloud project with BigQuery access enabled. The BigQuery Sandbox can be used for basic exploration.
2. Open each `.sql` file and run it against the public dataset.
3. Export each query result as CSV using the expected filename below, and place it in `dashboard/`.

| SQL file | Export filename |
|---|---|
| `02_overall_funnel.sql` | `overall_funnel.csv` |
| `03_funnel_by_device.sql` | `device_funnel.csv` |
| `04_funnel_by_source.sql` | `source_funnel.csv` |
| `05_daily_trend.sql` | `daily_trend.csv` |

For `05_daily_trend.sql`, use the result export as `daily_trend.csv`. For each SQL query, the output column names are designed to match the dashboard.

## Run the interactive dashboard

Python 3.10+ recommended.

```bash
python -m venv .venv
# macOS/Linux
source .venv/bin/activate
# Windows PowerShell: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
streamlit run dashboard/app.py
```

You can also upload the CSV exports from the dashboard sidebar without saving them into the repository.

## Funnel methodology

The included funnel is a **user-level qualifying funnel**: users count at a step only if they also qualify for all previous steps, but events may occur across multiple sessions or in a different order within the reporting window. This is useful for a first pass but is not a strict ordered-session funnel. A next iteration should use `ga_session_id`, timestamps, and explicit event ordering.

## Analysis plan

1. Validate the event coverage and date range.
2. Calculate users at each funnel stage and step-to-step drop-off.
3. Compare funnel progression by device category.
4. Compare funnel volumes by first observed traffic source/medium.
5. Review daily trend spikes and anomalies.
6. Recommend one or two experiments tied to the largest observed drop-off.

## Findings and summary

**Do not write conclusions until the real BigQuery results have been exported and reviewed.** Record the actual numbers, date range, metric definitions, limitations, and actionable recommendation here. Avoid claiming causality from descriptive funnel analysis.

## Suggested future projects

- Project 02: Retention and cohort analysis
- Project 03: A/B test evaluation and experimentation
- Project 04: Customer segmentation and lifetime value
- Project 05: Product feature adoption and activation
