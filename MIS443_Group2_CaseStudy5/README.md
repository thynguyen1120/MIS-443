# MIS443_Group2_CaseStudy5 – Data Mart

## 1. Project Objective
Analyze **Data Mart** weekly sales data using SQL to:
- Clean and transform raw sales data.
- Explore patterns across time, region, platform, and customer demographics.
- Evaluate the before/after impact of sustainable packaging (baseline: 2020-06-15).
- Deliver actionable business insights for Data Mart management.

## 2. Dataset Overview
**Original Columns:**
- `week_date` – start of the week (Monday)
- `region` – geographic area
- `platform` – sales channel (Retail, Shopify)
- `segment` – customer segmentation code
- `customer_type` – new or existing
- `sales` – total weekly sales
- `transactions` – weekly transaction count

**Derived Columns:**
- `week_number`, `month_number`, `calendar_year`
- `age_band`, `demographic`
- `avg_transaction`

## 3. Repository Structure
```
MIS443_GroupX_CaseStudy5/
│
├── sql/
│   ├── datamart_cleaning_and_analysis.sql  # All SQL code for cleaning + analysis
│
├── report/
│   ├── MIS443_Final_Report.pdf              # Project final report
│
├── images/                                  # Charts or figures (optional)
│
└── README.md
```

## 4. How to Run (PostgreSQL)
1. Create the database in PostgreSQL:  
   ```sql
   CREATE DATABASE mis443_datamart;
   ```
2. Import your raw data into the `data_mart.weekly_sales` table.
3. Run the cleaning & transformation script in `sql/datamart_cleaning_and_analysis.sql`.
4. Execute each analysis query to reproduce report results.

## 5. Deliverables
- **SQL scripts** for data cleaning, transformation, and analysis.
- **Final report** with insights and visualizations.
- **Presentation slides** (if applicable).

## 6. Team Members
- Member 1 – ID
- Member 2 – ID
- Member 3 – ID (optional)

## 7. License
Educational use for MIS 443.
