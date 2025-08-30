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




