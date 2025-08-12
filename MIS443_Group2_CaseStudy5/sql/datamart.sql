-- Part A: Create new table
CREATE TABLE data_mart.clean_weekly_sales AS
SELECT
-- Convert 'week_date' from 'DD/MM/YY' text to a DATE type, then format it as a
'YYYY/MM/DD' string
TO_CHAR(TO_DATE(week_date, 'DD/MM/YY'), 'YYYY/MM/DD') AS week_date,
-- Extract the week number of the year from the 'week_date'
EXTRACT(WEEK FROM TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
-- Extract the calendar month from the 'week_date'
EXTRACT(MONTH FROM TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
-- Extract the calendar year from the 'week_date'
EXTRACT(YEAR FROM TO_DATE(week_date, 'DD/MM/YY')) AS calendar_year,
-- Include original columns
region,
platform,
-- Clean the segment column by replacing 'null' strings with 'unknown'
CASE
WHEN segment = 'null' THEN 'unknown'
ELSE segment
END AS segment,
-- Add a new 'age_band' column based on the last character of the segment
CASE
WHEN RIGHT(segment, 1) = '1' THEN 'Young Adults'
WHEN RIGHT(segment, 1) = '2' THEN 'Middle Aged'
WHEN RIGHT(segment, 1) IN ('3', '4') THEN 'Retirees'
ELSE 'unknown'
END AS age_band,
-- Add a new 'demographic' column based on the first character of the segment
CASE
WHEN LEFT(segment, 1) = 'C' THEN 'Couples'
WHEN LEFT(segment, 1) = 'F' THEN 'Families'
ELSE 'unknown'
END AS demographic,
customer_type,
transactions,
sales,
-- Generate a new 'avg_transaction' column by dividing sales by transactions and rounding to 2
decimal places
ROUND(sales::NUMERIC / transactions, 2) AS avg_transaction
FROM
data_mart.weekly_sales;
--Part B: Data Exploration
-- Q1: What day of the week is used for each week_date?
SELECT
DISTINCT week_date,
TO_CHAR(week_date, 'Day') AS day_of_week
FROM data_mart.clean_weekly_sales
ORDER BY week_date;
-- Monday is used for the week_date value.
-- Q2: What range of week numbers are missing from the dataset?
SELECT MIN(week_number), MAX(week_number), COUNT(DISTINCT week_number)
FROM data_mart.clean_weekly_sales;
SELECT DISTINCT week_number
FROM data_mart.clean_weekly_sales
ORDER BY week_number;
WITH all_weeks AS (
SELECT generate_series(1, 53) AS week_number
),
existing_weeks AS (
SELECT DISTINCT week_number
FROM data_mart.clean_weekly_sales
)
SELECT aw.week_number
FROM all_weeks aw
LEFT JOIN existing_weeks ew
ON aw.week_number = ew.week_number
WHERE ew.week_number IS NULL
ORDER BY aw.week_number;
--- The dataset is missing a total of 29 week_number records.
--- Q3: How many total transactions were there for each year in the dataset?
SELECT
calendar_year,
SUM(transactions) AS total_transactions
FROM data_mart.clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;
---Q4: What is the total sales for each region for each month?
SELECT
region,
month_number,
SUM(sales) AS total_sales
FROM data_mart.clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;
--- Q5: What is the total count of transactions for each platform?
SELECT platform,
SUM(transactions) AS total_transactions
FROM data_mart.clean_weekly_sales
GROUP BY platform;
--Q6: What is the percentage of sales for Retail vs Shopify for each month?
SELECT
calendar_year,
month_number,
ROUND( SUM(CASE WHEN platform = 'Retail' THEN sales ELSE 0 END) *100.0/
SUM(sales), 2) AS retail_percentage,
ROUND( SUM(CASE WHEN platform = 'Shopify' THEN sales ELSE 0 END) *100.0/
SUM(sales), 2) AS shopify_percentage
FROM data_mart.clean_weekly_sales
GROUP BY calendar_year, month_number
ORDER BY calendar_year, month_number;
--Q7: What is the percentage of sales by demographic for each year in the dataset?
SELECT
calendar_year,
ROUND(SUM(CASE WHEN demographic = 'Couples' THEN sales ELSE 0 END) * 100.0 /
SUM(sales), 2) AS couples_sales_percent,
ROUND(SUM(CASE WHEN demographic = 'Families' THEN sales ELSE 0 END) * 100.0 /
SUM(sales), 2) AS families_sales_percent,
ROUND(SUM(CASE WHEN demographic = 'unknown' THEN sales ELSE 0 END) * 100.0 /
SUM(sales), 2) AS unknown_sales_percent
FROM data_mart.clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;
--Q8: Which age_band and demographic values contribute the most to Retail sales?
SELECT
age_band,
demographic,
SUM(sales) AS total_sales,
ROUND(
(SUM(sales) * 100.0) /
SUM(SUM(sales)) OVER (),
2
) AS percentage_sales
FROM data_mart.clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY total_sales DESC;
- -Part C: Before & After Analysis
- -Q1: What is the total sales for the 4 weeks before and after 2020-06-15?
WITH sales_4wk AS (
SELECT
CASE
WHEN week_date::date < DATE '2020-06-15'
AND week_date::date >= (DATE '2020-06-15' - INTERV AL '4 weeks') THEN 'Before'
WHEN week_date::date >= DATE '2020-06-15'
AND week_date::date < (DATE '2020-06-15' + INTERV AL '4 weeks') THEN 'After'
END AS period,
SUM(sales) AS total_sales
FROM data_mart.clean_weekly_sales
WHERE calendar_year = 2020
AND week_date::date BETWEEN (DATE '2020-06-15' - INTERV AL '4 weeks')
AND (DATE '2020-06-15' + INTERV AL '4 weeks')
GROUP BY period
)
SELECT
MAX(CASE WHEN period = 'Before' THEN total_sales END) AS sales_before,
MAX(CASE WHEN period = 'After' THEN total_sales END) AS sales_after,
(MAX(CASE WHEN period = 'After' THEN total_sales END) -
MAX(CASE WHEN period = 'Before' THEN total_sales END)) AS difference,
ROUND(
((MAX(CASE WHEN period = 'After' THEN total_sales END) -
MAX(CASE WHEN period = 'Before' THEN total_sales END))::numeric /
NULLIF(MAX(CASE WHEN period = 'Before' THEN total_sales END), 0) * 100),
2
) AS pct_change
FROM sales_4wk;
--Q2: What is the growth or reduction rate in actual values and percentage of sales?
WITH sales_12wk AS (
SELECT
CASE
WHEN week_date < DATE '2020-06-15'
AND week_date >= (DATE '2020-06-15' - INTERV AL '12 weeks') THEN 'Before'
WHEN week_date >= DATE '2020-06-15'
AND week_date < (DATE '2020-06-15' + INTERV AL '12 weeks') THEN 'After'
END AS period,
SUM(sales) AS total_sales
FROM data_mart.clean_weekly_sales
WHERE calendar_year = 2020
AND week_date BETWEEN (DATE '2020-06-15' - INTERV AL '12 weeks')
AND (DATE '2020-06-15' + INTERV AL '12 weeks')
GROUP BY period
)
SELECT
MAX(CASE WHEN period = 'Before' THEN total_sales END) AS sales_before,
MAX(CASE WHEN period = 'After' THEN total_sales END) AS sales_after,
(MAX(CASE WHEN period = 'After' THEN total_sales END) -
MAX(CASE WHEN period = 'Before' THEN total_sales END)) AS difference,
ROUND(
((MAX(CASE WHEN period = 'After' THEN total_sales END) -
MAX(CASE WHEN period = 'Before' THEN total_sales END))::numeric /
NULLIF(MAX(CASE WHEN period = 'Before' THEN total_sales END), 0) * 100),
2
) AS pct_change
FROM sales_12wk;
--Q3: What about the entire 12 weeks before and after?
WITH sales_4wk AS (
SELECT
calendar_year,
CASE
WHEN week_date < TO_DATE(calendar_year || '-06-15', 'YYYY-MM-DD')
AND week_date >= (TO_DATE(calendar_year || '-06-15', 'YYYY-MM-DD') -
INTERV AL '4 weeks') THEN 'Before'
WHEN week_date >= TO_DATE(calendar_year || '-06-15', 'YYYY-MM-DD')
AND week_date < (TO_DATE(calendar_year || '-06-15', 'YYYY-MM-DD') + INTERV AL
'4 weeks') THEN 'After'
END AS period,
SUM(sales) AS total_sales
FROM data_mart.clean_weekly_sales
WHERE calendar_year IN (2018, 2019, 2020)
AND week_date BETWEEN (TO_DATE(calendar_year || '-06-15', 'YYYY-MM-DD') -
INTERV AL '4 weeks')
AND (TO_DATE(calendar_year || '-06-15', 'YYYY-MM-DD') + INTERV AL '4
weeks')
GROUP BY calendar_year, period
),
pivoted_4wk AS (
SELECT
calendar_year,
MAX(CASE WHEN period = 'Before' THEN total_sales END) AS sales_before,
MAX(CASE WHEN period = 'After' THEN total_sales END) AS sales_after
FROM sales_4wk
GROUP BY calendar_year
)
SELECT
calendar_year,
sales_before,
sales_after,
(sales_after - sales_before) AS difference,
ROUND(((sales_after - sales_before)::numeric / NULLIF(sales_before, 0) * 100), 2) AS
pct_change
FROM pivoted_4wk
ORDER BY calendar_year;
--Q4: How do the sale metrics for these 2 periods before and after compare with the previous
years in 2018 and 2019?
WITH sales_12wk AS (
SELECT
calendar_year,
CASE
WHEN week_date < TO_DATE(calendar_year || '-06-15', 'YYYY-MM-DD')
AND week_date >= (TO_DATE(calendar_year || '-06-15', 'YYYY-MM-DD') -
INTERV AL '12 weeks') THEN 'Before'
WHEN week_date >= TO_DATE(calendar_year || '-06-15', 'YYYY-MM-DD')
AND week_date < (TO_DATE(calendar_year || '-06-15', 'YYYY-MM-DD') + INTERV AL
'12 weeks') THEN 'After'
END AS period,
SUM(sales) AS total_sales
FROM data_mart.clean_weekly_sales
WHERE calendar_year IN (2018, 2019, 2020)
AND week_date BETWEEN (TO_DATE(calendar_year || '-06-15', 'YYYY-MM-DD') -
INTERV AL '12 weeks')
AND (TO_DATE(calendar_year || '-06-15', 'YYYY-MM-DD') + INTERV AL '12
weeks')
GROUP BY calendar_year, period
),
pivoted_12wk AS (
SELECT
calendar_year,
MAX(CASE WHEN period = 'Before' THEN total_sales END) AS sales_before,
MAX(CASE WHEN period = 'After' THEN total_sales END) AS sales_after
FROM sales_12wk
GROUP BY calendar_year
)
SELECT
calendar_year,
sales_before,
sales_after,
(sales_after - sales_before) AS difference,
ROUND(((sales_after - sales_before)::numeric / NULLIF(sales_before, 0) * 100), 2) AS
pct_change
FROM pivoted_12wk
ORDER BY calendar_year;