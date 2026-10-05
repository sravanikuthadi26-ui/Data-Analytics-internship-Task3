-- TASK 3: SQL FOR DATA ANALYSIS
-- Dataset: Supermart Grocery Sales - Retail Analytics Dataset
-- Database: SQLite-compatible
-- Note: Import the Excel dataset into a table named supermart_sales before running.
-- The city_info table can be created from distinct City, State, Region values.

-- 1. SELECT, WHERE, ORDER BY
SELECT "Order ID", "Customer Name", Category, City, Sales, Profit
FROM supermart_sales
WHERE Sales > 2000
ORDER BY Sales DESC
LIMIT 10;

-- 2. GROUP BY and aggregate functions
SELECT Category,
       COUNT(*) AS Orders,
       ROUND(SUM(Sales), 2) AS Total_Sales,
       ROUND(AVG(Sales), 2) AS Average_Sales,
       ROUND(SUM(Profit), 2) AS Total_Profit
FROM supermart_sales
GROUP BY Category
ORDER BY Total_Sales DESC;

-- 3. INNER JOIN
-- Create a location table from the same dataset if needed:
-- CREATE TABLE city_info AS
-- SELECT DISTINCT City, State, Region FROM supermart_sales;
SELECT s."Order ID", s."Customer Name", s.City, c.State, c.Region, s.Sales, s.Profit
FROM supermart_sales AS s
INNER JOIN city_info AS c
    ON s.City = c.City
ORDER BY s.Sales DESC
LIMIT 10;

-- 4. LEFT JOIN
SELECT c.City, c.State, c.Region,
       COUNT(s."Order ID") AS Orders,
       ROUND(COALESCE(SUM(s.Sales), 0), 2) AS Total_Sales
FROM city_info AS c
LEFT JOIN supermart_sales AS s
    ON c.City = s.City
GROUP BY c.City, c.State, c.Region
ORDER BY Total_Sales DESC
LIMIT 10;

-- 5. RIGHT JOIN
-- SQLite does not support RIGHT JOIN directly.
-- Equivalent result can be produced by reversing the tables and using LEFT JOIN:
SELECT s."Order ID", s."Customer Name", c.City, c.State, c.Region, s.Sales
FROM city_info AS c
LEFT JOIN supermart_sales AS s
    ON c.City = s.City
ORDER BY s.Sales DESC
LIMIT 10;
-- In MySQL/PostgreSQL, the direct form is:
-- SELECT s."Order ID", s."Customer Name", c.City, c.State, c.Region, s.Sales
-- FROM supermart_sales AS s
-- RIGHT JOIN city_info AS c ON s.City = c.City;

-- 6. Subquery: orders above average sales
SELECT "Order ID", "Customer Name", Category, Sales, Profit
FROM supermart_sales
WHERE Sales > (SELECT AVG(Sales) FROM supermart_sales)
ORDER BY Sales DESC
LIMIT 10;

-- 7. Average revenue per user/customer
SELECT "Customer Name",
       COUNT(*) AS Orders,
       ROUND(SUM(Sales), 2) AS Revenue,
       ROUND(AVG(Sales), 2) AS Avg_Revenue_Per_Order
FROM supermart_sales
GROUP BY "Customer Name"
ORDER BY Revenue DESC
LIMIT 10;

-- 8. Handle NULL values
SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS Null_Sales,
    SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS Null_Profit,
    SUM(CASE WHEN "Customer Name" IS NULL THEN 1 ELSE 0 END) AS Null_Customer
FROM supermart_sales;

-- 9. Create a view for analysis
CREATE VIEW IF NOT EXISTS category_performance AS
SELECT Category,
       COUNT(*) AS Orders,
       ROUND(SUM(Sales), 2) AS Total_Sales,
       ROUND(SUM(Profit), 2) AS Total_Profit,
       ROUND(AVG(Discount), 4) AS Avg_Discount
FROM supermart_sales
GROUP BY Category;

SELECT *
FROM category_performance
ORDER BY Total_Profit DESC;

-- 10. Index for query optimization
CREATE INDEX IF NOT EXISTS idx_supermart_category
ON supermart_sales(Category);

CREATE INDEX IF NOT EXISTS idx_supermart_order_date
ON supermart_sales("Order Date");

-- Verify indexes
PRAGMA index_list('supermart_sales');
