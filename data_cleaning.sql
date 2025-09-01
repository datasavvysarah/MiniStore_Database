select * from retail_custom rc

Select "Date","Price","Quantity","Product", "Customer_Age", "Payment_Method", "Weekly_Sales" from retail_custom rc
where rc."Price" is null;

--- Changing Null Values
select * from retail_custom rc 

update retail_custom rc 
set "Payment_Method" = 'Not Specified'
where "Payment_Method" is null;

select * from retail_custom rc 
where rc."Payment_Method" = 'Cash';

SELECT COUNT(*) 
FROM retail_custom rc 
WHERE rc."Payment_Method"  = '';

-- Converting empty strings '' to nullif values temporarily and permanently
-- Temporary Values

SELECT COALESCE(NULLIF("Payment_Method", ''), 'Not Specified') AS fixed_value
FROM retail_custom rc;

--- Checking for updated Values
select * from retail_custom rc 

-- Permanently
update retail_custom rc 
set "Payment_Method" = 'Not Specified'
where "Payment_Method" = '';

--- Checking for updated Values
select * from retail_custom rc 

--- Fill in the missing Values in Price using the Avg_price function
--update retail_custom rc 
--set  "Price" = '0'
--where rc."Price"  is null;

SELECT rc."Product", AVG("Price") AS avg_price
FROM retail_custom rc 
WHERE "Price" IS NOT NULL
GROUP by rc."Product";

-- For Changing NULL VALUES Retail Avg_Price

UPDATE retail_custom rc
SET "Price" = a.avg_price
FROM (
    SELECT "Product", AVG("Price") AS avg_price
    FROM retail_custom
    WHERE "Price" IS NOT NULL
    GROUP BY "Product"
) a
WHERE rc."Product" = a."Product"
  AND rc."Price" IS NULL;

-- For Changing NULL VALUES USING Retail Avg_Quantity  

UPDATE retail_custom rc
SET "Quantity" = a.avg_qty
FROM (
    SELECT "Product", AVG("Quantity")::INT AS avg_qty
    FROM retail_custom
    WHERE "Quantity" IS NOT NULL
    GROUP BY "Product"
) a
WHERE rc."Product" = a."Product"
  AND rc."Quantity" IS NULL;

select * from retail_custom rc 

-- For Changing NULL VALUES USING -1 in Customer_Age Column

UPDATE retail_custom rc
SET "Customer_Age" = -1
WHERE "Customer_Age" IS NULL;


UPDATE retail_custom rc
SET "Customer_Gender" = 'Unspecified'
WHERE "Customer_Gender" = '';

select * from retail_custom rc 


-- Finding Duplicates Values

SELECT "Date","Store","Product","Category","Price","Quantity", "Payment_Method","City","Customer_Age","Customer_Gender","Weekly_Sales","Holiday_Flag", COUNT(*) 
FROM retail_custom rc 
GROUP BY "Date","Store","Product","Category","Price","Quantity", "Payment_Method","City","Customer_Age","Customer_Gender","Weekly_Sales","Holiday_Flag"
HAVING COUNT(*) > 1;

SELECT *
FROM retail_custom
WHERE ("Date","Store","Product","Category","Price","Quantity", "Payment_Method","City","Customer_Age","Customer_Gender","Weekly_Sales","Holiday_Flag") IN (
    SELECT "Date","Store","Product","Category","Price","Quantity", "Payment_Method","City","Customer_Age","Customer_Gender","Weekly_Sales","Holiday_Flag"
    FROM retail_custom
    GROUP BY "Date","Store","Product","Category","Price","Quantity", "Payment_Method","City","Customer_Age","Customer_Gender","Weekly_Sales","Holiday_Flag"
    HAVING COUNT(*) > 1
);

SELECT *
FROM retail_custom
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM retail_custom
    GROUP BY "Date","Store","Product","Category","Price","Quantity",
             "Payment_Method","City","Customer_Age","Customer_Gender",
             "Weekly_Sales","Holiday_Flag"
);

DELETE FROM retail_custom
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM retail_custom
    GROUP BY "Date","Store","Product","Category","Price","Quantity",
             "Payment_Method","City","Customer_Age","Customer_Gender",
             "Weekly_Sales","Holiday_Flag"
);

--- Total Rows
SELECT COUNT(*) AS total_rows
FROM retail_custom;

select * from retail_custom rc 

--- 								OR
-- Removing Duplicates and placing it on a new table

CREATE TABLE retail_custom_unique AS
SELECT "Date", "Product", "Quantity", "Payment_Method", "Weekly_Sales"
FROM (
    SELECT "Date", "Product", "Quantity", "Payment_Method","Weekly_Sales",
           ROW_NUMBER() OVER (
               PARTITION BY "Date", "Product", "Quantity", "Payment_Method", "Weekly_Sales",
               ORDER BY "Date"
           ) AS rn
    FROM retail_custom
) sub
WHERE rn = 1;

select * from retail_custom rc
