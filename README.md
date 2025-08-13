# CaseStudy5 – Data Mart

## 1. Project Objective
This project analyzes **Data Mart** weekly sales data to:
- Clean and transform raw sales data into a structured, analyzable format.
- Explore customer behavior over time, by region, platform, and demographic.
- Assess the before-and-after impact of the **sustainable packaging policy** implemented on **2020-06-15**.
- Provide actionable insights and recommendations for Data Mart’s management.

## 2. Dataset Overview
**Original Columns:**
- `week_date` – start of the week (always Monday)
- `region` – geographic area (e.g., Asia, Europe)
- `platform` – sales channel (Retail, Shopify)
- `segment` – customer segmentation code (e.g., C1, F3)
- `customer_type` – type of customer (New, Existing)
- `sales` – total weekly sales revenue
- `transactions` – total transactions in the week

**Derived Columns:**
- `week_number` – ISO week number (1–53)
- `month_number` – calendar month (1–12)
- `calendar_year` – extracted year (2018–2020)
- `age_band` – customer age group (e.g., Young Adults, Retirees) derived from `segment`
- `demographic` – customer type (e.g., Couples, Families) derived from `segment`
- `avg_transaction` – sales / transactions, rounded to 2 decimals

## 3. Data Cleansing Steps
1. **Convert `week_date` to Date format** (`YYYY/MM/DD`).
2. **Create temporal variables**: `week_number`, `month_number`, `calendar_year`.
3. **Classify customer data**:
   - `age_band` from last character of `segment`
   - `demographic` from first character of `segment`
4. **Handle NULL values**: Replace `'null'` or missing values with `'unknown'`.
5. **Calculate `avg_transaction`** = `sales / transactions`.

## 4. Data Exploration – Key Insights
- All `week_date` values are Mondays → consistent weekly reporting.
- **Missing weeks**: 29 week numbers absent in dataset, may affect seasonality/trend analysis.
- **Transaction growth**: Steady increase from 2018 to 2020 (~8.5% growth).
- **Regional trends**:
  - Oceania leads in sales most months.
  - Peak sales in April, drop in September across regions.
- **Platform mix**:
  - Retail dominates (~95% transactions, ~97% sales).
  - Shopify share slowly rising, especially post-June 2020.
- **Demographics**:
  - Couples share rose from 26.38% (2018) to 28.72% (2020).
  - Families stable (~32%), Unknown segment shrinking.
- **Retail contributors**:
  - Retirees, Middle Aged Families, and Couples drive most sales.
  - Unknown segment still ~40% of Retail sales.

## 5. Before & After Analysis – Sustainable Packaging Impact
- **4 weeks before/after 2020-06-15**: Sales dropped 1.15% in 2020, versus increases in 2018/2019.
- **12 weeks before/after 2020-06-15**: Sales dropped 2.14% in 2020, versus stable/increasing trends in 2018/2019.
- Negative short- and medium-term impact in 2020, diverging from historical trends.

## 6. Recommendations
1. **Target high-value segments** – Retirees, Middle Aged Families.
2. **Improve data collection** to reduce "Unknown" customer segment.
3. **Expand Shopify presence** to diversify sales channels.
4. **Communicate operational changes** effectively to minimize sales disruption.


## 7. How to Run (PostgreSQL)
1. Create database:  
   ```sql
   CREATE DATABASE mis443_datamart;
   ```
2. Import raw dataset into `data_mart.weekly_sales` table.
3. Run scripts in `sql/datamart.sql`.
4. Review output and match with insights in final report.


## 8. License
For educational use in MIS 443, Eastern International University.
