-- Store Performance
select * from retail_custom rc

--  1. What are the top-performing products by revenue and units sold across all stores?

SELECT 
    "Store", 
    SUM("Price" * "Quantity") AS total_sales
FROM retail_custom rc 
where rc."Store" in ('Store A','Store B', 'Store C', 'Store D')
GROUP BY "Store"
ORDER BY total_sales DESC

-- 2. How do sales trends vary across different time periods (daily, weekly, monthly, seasonal)?

-- Daily
SELECT 
    rc."Store",
    rc."Date",
    SUM(rc."Weekly_Sales") AS total_daily_sales
FROM retail_custom rc
WHERE rc."Store" IN ('Store A','Store B', 'Store C', 'Store D')
GROUP BY rc."Store", rc."Date"
ORDER BY total_daily_sales DESC;

-- Weekly

select "Store", SUM("Weekly_Sales") as Total_Weekly_Sales
from retail_custom rc 
where rc."Store" in ('Store A','Store B', 'Store C', 'Store D')
group by "Store"
order by total_weekly_sales DESC;

-- Monthly Sales Per store
SELECT 
    "Store",
    DATE_TRUNC('month', CAST("Date" AS DATE)) AS Month,
    SUM("Weekly_Sales") AS Monthly_Sales
FROM retail_custom
GROUP BY "Store", DATE_TRUNC('month', CAST("Date" AS DATE))
ORDER BY "Store", Month;

-- OR

SELECT 
    rc."Store",
    TO_CHAR(rc."Date"::date, 'Mon') AS month,
    DATE_PART('year', rc."Date"::date) AS year,
    SUM(rc."Weekly_Sales") AS total_monthly_sales
FROM retail_custom rc
WHERE rc."Store" IN ('Store A','Store B', 'Store C', 'Store D')
GROUP BY rc."Store", year, TO_CHAR(rc."Date"::date, 'Mon'), DATE_PART('month', rc."Date"::date)
ORDER BY year, DATE_PART('month', rc."Date"::date), total_monthly_sales DESC;

-- OR

SELECT 
    rc."Store",
    TO_CHAR(rc."Date"::date, 'Mon YYYY') AS month_year,
    SUM(rc."Weekly_Sales") AS total_monthly_sales
FROM retail_custom rc
WHERE rc."Store" IN ('Store A','Store B', 'Store C', 'Store D')
GROUP BY rc."Store", TO_CHAR(rc."Date"::date, 'Mon YYYY'), DATE_PART('year', rc."Date"::date), DATE_PART('month', rc."Date"::date)
ORDER BY DATE_PART('year', rc."Date"::date), DATE_PART('month', rc."Date"::date), total_monthly_sales DESC;


-- YEARLY SALES BY STORES

SELECT 
    "Store",
    TO_CHAR("Date"::date, 'YYYY') AS Year,
    SUM("Price" * "Quantity") AS Yearly_Sales
FROM retail_custom
WHERE "Store" IN ('Store A','Store B', 'Store C', 'Store D')
GROUP BY "Store", TO_CHAR("Date"::date, 'YYYY'), DATE_PART('year', "Date"::date)
ORDER BY "Store", DATE_PART('year', "Date"::date) DESC;

-- OR
SELECT 
    "Store",
    DATE_TRUNC('year', CAST("Date" AS DATE)) AS Year,
    SUM("Weekly_Sales") AS Yearly_Sales
FROM retail_custom
GROUP BY "Store", DATE_TRUNC('year', CAST("Date" AS DATE))
ORDER BY "Store", Year;

-- OR
SELECT 
    "Store",
    DATE_TRUNC('year', "Date"::date) AS year,
    SUM("Weekly_Sales") AS total_yearly_sales
FROM retail_custom
GROUP BY "Store", DATE_TRUNC('year', "Date"::date)
ORDER BY "Store", year;

-- SEASONAL 

SELECT 
    rc."Store",
    CASE 
        WHEN EXTRACT(MONTH FROM rc."Date"::date) IN (12, 1, 2) THEN 'Winter'
        WHEN EXTRACT(MONTH FROM rc."Date"::date) IN (3, 4, 5) THEN 'Spring'
        WHEN EXTRACT(MONTH FROM rc."Date"::date) IN (6, 7, 8) THEN 'Summer'
        WHEN EXTRACT(MONTH FROM rc."Date"::date) IN (9, 10, 11) THEN 'Fall'
    END AS season,
    EXTRACT(YEAR FROM rc."Date"::date) AS year,
    SUM(rc."Weekly_Sales") AS total_seasonal_sales
FROM retail_custom rc
WHERE rc."Store" IN ('Store A','Store B', 'Store C', 'Store D')
GROUP BY rc."Store", season, year
ORDER BY year, season, total_seasonal_sales DESC;


-- 2. Which store locations generate the highest revenue and profit margins?
SELECT 
    rc."Store",
    SUM(rc."Weekly_Sales") AS total_revenue,
    (SUM(rc."Weekly_Sales") - SUM(rc."Price")) AS total_profit,
    ROUND(
        ((SUM(rc."Weekly_Sales") - SUM(rc."Price"))::numeric 
        / NULLIF(SUM(rc."Weekly_Sales"),0)::numeric) * 100, 2
    ) ::text || '%' AS profit_margin_percent
FROM retail_custom rc
GROUP BY rc."Store"
ORDER BY total_revenue DESC, profit_margin_percent DESC;

-- What is the average transaction value and how has it changed over time by store?
SELECT
    rc."Store",
    TO_CHAR(rc."Date"::date, 'Mon') AS month,
    SUM(rc."Price" * rc."Quantity") AS total_revenue,
    COUNT(*) AS total_transactions,
    ROUND(
        (SUM(rc."Price" * rc."Quantity")::numeric 
        / NULLIF(COUNT(*), 0))::numeric, 
        2
    ) AS avg_transaction_value
FROM retail_custom rc
GROUP BY rc."Store", TO_CHAR(rc."Date"::date, 'Mon'), DATE_PART('month', rc."Date"::date)
ORDER BY rc."Store", month, DATE_PART('month', rc."Date"::date);

-- Store Performance Comparison
-- Which stores are the top performers in terms of total sales and revenue?
-- How do different stores compare in terms of product mix and sales volume?
-- What are the sales patterns and peak hours for each store location?
-- Which stores show the most consistent performance over time?

-- Which stores are the top performers in terms of total sales and revenue?
SELECT "Store", sum("Price" * "Quantity") as Revenue, sum("Weekly_Sales") as Total_Sales
FROM retail_custom rc 
WHERE "Store" IN ('Store A','Store B', 'Store C', 'Store D')
GROUP BY "Store"
ORDER BY Total_Sales DESC;

-- ANS: Store D and Store A are the top performers in terms of total sales and revenue

-- How do different stores compare in terms of category mix and sales volume?
SELECT
    "Store",
    "Category",
    SUM("Quantity") AS total_sales_volume,
    ROUND(SUM("Price" * "Quantity")::numeric, 2) AS total_sales,
    ROUND(
        ((SUM("Quantity") * 100.0) / SUM(SUM("Quantity")) OVER (PARTITION BY "Store"))::numeric,
        2
    ) AS store_sales_volume,
    ROUND(
        ((SUM("Price" * "Quantity") * 100.0) / SUM(SUM("Price" * "Quantity")) OVER (PARTITION BY "Store"))::numeric,
        2
    ) AS store_sales_value
FROM retail_custom
GROUP BY "Store", "Category"
ORDER BY "Store", total_sales DESC;

-- Store A relies heavily on Clothings (26.92% of sales value) with a total sales volume at 415 
-- Store D sells fewer units on Clothings, but its Groceries category contributes 24.07% of its sales value, higher than the other stores.”
-- OR 

SELECT
    COALESCE("Store", 'All Stores') AS store,
    "Category",
    SUM("Quantity") AS total_sales_volume,
    ROUND(SUM("Price" * "Quantity")::numeric, 2) AS total_sales,
    ROUND(
        ((SUM("Quantity") * 100.0) / SUM(SUM("Quantity")) OVER (PARTITION BY "Store"))::numeric,
        2
    ) AS pct_of_store_sales_volume,
    ROUND(
        ((SUM("Price" * "Quantity") * 100.0) / SUM(SUM("Price" * "Quantity")) OVER (PARTITION BY "Store"))::numeric,
        2
    ) AS pct_of_store_sales_value
FROM retail_custom
GROUP BY GROUPING SETS (
    ("Store", "Category"),  -- breakdown by store + category
    ("Category")            -- grand totals across all stores
)
ORDER BY store, total_sales DESC;


-- Due to the fact that there is no time stamps on this data we are focused on the days
-- What are the sales patterns and peak days for each store location?
WITH sales_by_day AS (
    SELECT 
        "City",
        TO_CHAR("Date"::DATE, 'Day') AS day_name,
        COUNT(*) AS sales_volume,
        SUM("Weekly_Sales") AS total_sales
    FROM retail_custom rc
    GROUP BY "City", TO_CHAR("Date"::DATE, 'Day')
)
SELECT *
FROM (
    SELECT 
        "City",
        day_name,
        sales_volume,
        total_sales,
        RANK() OVER (PARTITION BY "City" ORDER BY sales_volume DESC) AS sales_rank
    FROM sales_by_day
) ranked
WHERE sales_rank = 1
order by total_sales DESC;

-- OR
SELECT 
    "City",
    EXTRACT(DOW FROM "Date"::DATE) AS day_of_week, -- 0=Sunday, 1=Monday...
    COUNT(*) AS sales_volume,
    SUM("Weekly_Sales") AS total_sales
FROM retail_custom rc
GROUP BY "City", EXTRACT(DOW FROM "Date"::DATE)
ORDER BY "City", day_of_week;


-- Which stores show the most consistent performance over time?

WITH monthly_sales AS (
    SELECT 
        "Store",
        DATE_TRUNC('month', TO_DATE("Date", 'YYYY-MM-DD')) AS month_start,
        SUM("Weekly_Sales") AS total_sales
    FROM retail_custom
    GROUP BY "Store", DATE_TRUNC('month', TO_DATE("Date", 'YYYY-MM-DD'))
),
consistency AS (
    SELECT 
        "Store",
        AVG(total_sales) AS avg_sales,
        STDDEV(total_sales) AS sales_volatility,
        (STDDEV(total_sales) / NULLIF(AVG(total_sales), 0)) * 100 AS coeff_variation
    FROM monthly_sales
    GROUP BY "Store"
)
SELECT 
    "Store",
    avg_sales,
    sales_volatility,
    TO_CHAR(ROUND(coeff_variation::numeric, 2), 'FM999990.00') || '%' AS coeff_variation_pct
FROM consistency
ORDER BY coeff_variation ASC;  -- lower % = more consistent

-- OR WITH Rank Function
-- Which stores show the most consistent performance over time?
WITH monthly_sales AS (
    SELECT 
        "Store",
        DATE_TRUNC('month', TO_DATE("Date", 'YYYY-MM-DD')) AS month_start,
        SUM("Weekly_Sales") AS total_sales
    FROM retail_custom
    GROUP BY "Store", DATE_TRUNC('month', TO_DATE("Date", 'YYYY-MM-DD'))
),
consistency AS (
    SELECT 
        "Store",
        AVG(total_sales) AS avg_sales,
        STDDEV(total_sales) AS sales_volatility,
        (STDDEV(total_sales) / NULLIF(AVG(total_sales), 0)) * 100 AS coeff_variation
    FROM monthly_sales
    GROUP BY "Store"
)
SELECT 
    "Store",
    avg_sales,
    sales_volatility,
    ROUND(coeff_variation::numeric, 2)::text || '%' AS coeff_variation_pct,
    RANK() OVER (ORDER BY coeff_variation ASC) AS consistency_rank
FROM consistency
ORDER BY coeff_variation ASC
LIMIT 5;   -- Top 5 most consistent



