USE online_retail;

--Preview data
SELECT TOP 10 * FROM retail;

--Row count
SELECT COUNT(*) AS total_rows FROM retail; 

--Corrected Data Types (Clean Table)
SELECT
InvoiceNo,
StockCode,
Description,
TRY_CAST(Quantity AS INT) AS Quantity,
TRY_CAST(UnitPrice AS DECIMAL(10,2)) AS UnitPrice,
TRY_CAST(Quantity AS INT) * TRY_CAST(UnitPrice AS DECIMAL(10,2)) AS Revenue,
TRY_CAST(CustomerID AS INT) AS CustomerID,
TRY_CONVERT(DATETIME, InvoiceDate) AS InvoiceDate,
Country
INTO retail_clean 
FROM retail;

--Clean data preview
SELECT COUNT(*) AS total_rows
FROM 
retail_clean;

SELECT TOP 10*
FROM retail_clean;

--Null check
SELECT 
COUNT(*) AS total_rows,
SUM (CASE WHEN Description IS NULL THEN 1 ELSE 0 END) AS null_desription,
SUM (CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS null_customerid,
SUM (CASE WHEN InvoiceDate IS NULL THEN 1 ELSE 0 END) AS null_invoicedate,
SUM (CASE WHEN UnitPrice IS NULL THEN 1 ELSE 0 END) AS null_unitprice,
SUM (CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
SUM (CASE WHEN Country IS NULL THEN 1 ELSE 0 END) AS null_country
FROM retail_clean;

--Blanks Check(None found)
SELECT
SUM (CASE WHEN LTRIM(RTRIM(Description)) = '' THEN 1 ELSE 0 END) AS blank_description,
SUM (CASE WHEN LTRIM(RTRIM(StockCode)) = '' THEN 1 ELSE 0 END) AS blank_stockcode,
SUM (CASE WHEN LTRIM(RTRIM(InvoiceNo)) = '' THEN 1 ELSE 0 END) AS blank_invoiceNO,
SUM (CASE WHEN LTRIM(RTRIM(Country)) = '' THEN 1 ELSE 0 END) AS blank_country
FROM retail_clean

--Null Preview 
SELECT TOP 20 *
FROM retail 
WHERE CustomerID IS NULL
OR LTRIM(RTRIM(CustomerID)) = ''
OR Description IS NULL
OR LTRIM(RTRIM(Description)) = '';

--Duplicate Check(4879 Rows Found)
SELECT *,
COUNT(*) AS duplicate_count
FROM retail_clean
GROUP BY
InvoiceNo,
StockCode,
Description,
Quantity,
InvoiceDate,
UnitPrice,
CustomerID,
Country,
Revenue
HAVING COUNT(*) > 1;

--Duplicate group count
SELECT COUNT(*) AS duplicate_rows
FROM
(
SELECT
InvoiceNo,
StockCode,
Description,
Quantity,
InvoiceDate,
UnitPrice,
CustomerID,
Country,
Revenue,
COUNT(*) AS duplicate_count
FROM retail_clean
GROUP BY
InvoiceNo,
StockCode,
Description,
Quantity,
InvoiceDate,
UnitPrice,
CustomerID,
Country,
Revenue
HAVING COUNT(*) > 1
) AS duplicates;

--Data types check
EXEC sp_help retail_clean;

--Distinct Row Count
SELECT count(*) AS distinct_rows
FROM (SELECT DISTINCT * FROM retail_clean)d;

--New Table (removed duplicates)
SELECT DISTINCT *
INTO retail_clean_df
FROM retail_clean;

SELECT COUNT(*) AS total_rows
FROM retail_clean_df;

--Negative Quantities
SELECT COUNT(*) AS negative_quantity
FROM retail_clean_df
WHERE Quantity < 0;

--Cancelled Invoices
SELECT COUNT(*) AS cancelled_invoices
FROM retail_clean_df
WHERE InvoiceNo LIKE 'C%';

--Negative Quantities (from non cancelled invoices)
SELECT COUNT(*) AS negative_not_cancelled
FROM retail_clean_df
WHERE Quantity < 0
  AND InvoiceNo NOT LIKE 'C%';

  --Negative Quantities (from cancelled invoices)
SELECT COUNT(*) AS negative_and_cancelled
FROM retail_clean_df
WHERE Quantity < 0
  AND InvoiceNo LIKE 'C%';

  --Retail Sales Table
  SELECT *
  INTO retail_sales
  FROM retail_clean_df
  WHERE Quantity > 0
  AND UnitPrice > 0;

  --Sales Data Size
  SELECT COUNT(*) AS total_sales_rows,
  SUM(Revenue) AS total_revenue
  FROM retail_sales;

  --Top Country by Revenue
  SELECT TOP 10
  Country,
  SUM(Revenue) AS total_revenue
  FROM retail_sales 
  Group BY Country
  ORDER BY total_revenue DESC;

  --Top Products by Revenue
  SELECT TOP 10
  Description,
  SUM(Revenue) AS total_revenue
  FROM retail_sales
  GROUP BY Description
  ORDER BY total_revenue DESC;

   --Monthly Sales Trend
SELECT
YEAR(InvoiceDate) AS sales_year,
MONTH(InvoiceDate) AS sales_month,
SUM(Revenue) AS total_revenue
FROM retail_sales
GROUP BY
YEAR(InvoiceDate),
MONTH(InvoiceDate)
ORDER BY
sales_year,
sales_month;

--Top Customers by Revenue
SELECT TOP 10
CustomerID,
SUM(Revenue) AS total_revenue
FROM retail_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_revenue DESC;

--Average Order Value (AOV)
SELECT
      SUM(Revenue) / COUNT(DISTINCT InvoiceNo) AS AOV
FROM retail_sales;

--Monthly Order Volume
SELECT 
     YEAR(InvoiceDate) AS sales_year,
     DATENAME(MONTH,InvoiceDate) AS sales_month,
     COUNT(DISTINCT InvoiceNo) AS total_orders
FROM retail_sales
GROUP BY 
        YEAR(InvoiceDate),
        MONTH(InvoiceDate),
        DATENAME(MONTH, InvoiceDate)
ORDER BY 
       total_orders DESC;

--Top Customers Contribution
WITH CustomerRevenue AS(
     SELECT 
          CustomerID,
          SUM(Revenue) AS total_revenue
FROM retail_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
)
SELECT TOP 10 
     CustomerID,
     total_revenue,
     ROUND(
          total_revenue * 100.0 /
          (SELECT SUM(Revenue) FROM retail_sales),
          2
          )
          AS revenue_percentage
    FROM CustomerRevenue
    ORDER BY total_revenue DESC;       

--Country Perfomance %
SELECT 
     Country,
     SUM(Revenue) AS total_revenue,
     ROUND(
         SUM(Revenue) * 100.0 /
         (SELECT SUM(Revenue) FROM retail_sales),
         2
         ) AS revenue_percentage
     FROM retail_sales
     GROUP BY Country
     ORDER BY total_revenue DESC;
  



  


 