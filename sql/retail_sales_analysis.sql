-- =========================================================
-- Retail Sales Intelligence & Business Analytics
-- Independent analysis based on the project dataset
-- =========================================================

CREATE DATABASE IF NOT EXISTS retail_sales_intelligence;
USE retail_sales_intelligence;

DROP TABLE IF EXISTS superstore;

CREATE TABLE superstore (
    row_id          INT,
    order_id        VARCHAR(30),
    order_date      DATE,
    ship_date       DATE,
    ship_mode       VARCHAR(50),
    customer_id     VARCHAR(30),
    customer_name   VARCHAR(150),
    segment         VARCHAR(50),
    country_region  VARCHAR(100),
    city            VARCHAR(100),
    state_province  VARCHAR(100),
    postal_code     VARCHAR(20),
    region          VARCHAR(50),
    product_id      VARCHAR(30),
    category        VARCHAR(50),
    sub_category    VARCHAR(50),
    product_name    VARCHAR(255),
    sales           DECIMAL(12,2),
    quantity        INT,
    discount        DECIMAL(5,2),
    profit          DECIMAL(12,2)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'data/superstore_clean.csv'
INTO TABLE superstore
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    row_id,
    order_id,
    @order_date,
    @ship_date,
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country_region,
    city,
    state_province,
    postal_code,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    sales,
    quantity,
    discount,
    profit
)
SET
    order_date = STR_TO_DATE(@order_date, '%m/%d/%Y'),
    ship_date  = STR_TO_DATE(@ship_date, '%m/%d/%Y');

-- A. DATA VALIDATION
SELECT COUNT(*) AS transaction_lines,
       COUNT(DISTINCT order_id) AS distinct_orders,
       COUNT(DISTINCT customer_id) AS distinct_customers,
       ROUND(SUM(sales), 2) AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit
FROM superstore;

SELECT
    SUM(CASE WHEN order_id IS NULL OR TRIM(order_id) = '' THEN 1 ELSE 0 END) AS missing_order_ids,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS missing_order_dates,
    SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) AS missing_ship_dates,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS missing_sales,
    SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) AS missing_profit,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS missing_quantity,
    SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS missing_discount
FROM superstore;

SELECT row_id, COUNT(*) AS duplicate_count
FROM superstore
GROUP BY row_id
HAVING COUNT(*) > 1;

SELECT
    MIN(order_date) AS earliest_order_date,
    MAX(order_date) AS latest_order_date,
    SUM(CASE WHEN order_date IS NULL OR order_date < '2023-01-01' OR order_date > '2026-12-31' THEN 1 ELSE 0 END) AS invalid_order_dates,
    SUM(CASE WHEN ship_date IS NULL OR ship_date < order_date THEN 1 ELSE 0 END) AS invalid_ship_dates
FROM superstore;

SELECT
    SUM(CASE WHEN sales < 0 THEN 1 ELSE 0 END) AS negative_sales_rows,
    SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) AS negative_profit_rows,
    SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END) AS zero_or_negative_quantity_rows,
    SUM(CASE WHEN discount < 0 OR discount > 1 THEN 1 ELSE 0 END) AS invalid_discount_rows
FROM superstore;

-- B. CORE KPIS
SELECT
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS profit_margin_pct,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM superstore;

-- C. CATEGORY ANALYSIS
SELECT
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS profit_margin_pct,
    ROUND(SUM(quantity), 0) AS total_quantity
FROM superstore
GROUP BY category
ORDER BY total_sales DESC;

-- D. SUB-CATEGORY ANALYSIS
WITH subcategory AS (
    SELECT
        sub_category,
        SUM(sales) AS sales,
        SUM(profit) AS profit,
        ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS margin_pct
    FROM superstore
    GROUP BY sub_category
)
SELECT *
FROM subcategory
ORDER BY sales DESC;

SELECT *
FROM (
    SELECT
        sub_category,
        SUM(sales) AS sales,
        SUM(profit) AS profit,
        ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS margin_pct,
        RANK() OVER (ORDER BY SUM(profit) ASC) AS lowest_profit_rank
    FROM superstore
    GROUP BY sub_category
) ranked
WHERE lowest_profit_rank <= 10
ORDER BY lowest_profit_rank;

-- E. REGIONAL ANALYSIS
SELECT
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS profit_margin_pct,
    COUNT(DISTINCT order_id) AS total_orders
FROM superstore
GROUP BY region
ORDER BY total_sales DESC;

-- F. SEGMENT ANALYSIS
SELECT
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS profit_margin_pct,
    COUNT(DISTINCT order_id) AS total_orders
FROM superstore
GROUP BY segment
ORDER BY total_sales DESC;

-- G. TIME ANALYSIS
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month_key,
    ROUND(SUM(sales), 2) AS monthly_sales,
    ROUND(SUM(profit), 2) AS monthly_profit
FROM superstore
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month_key;

SELECT
    YEAR(order_date) AS order_year,
    ROUND(SUM(sales), 2) AS yearly_sales,
    ROUND(SUM(profit), 2) AS yearly_profit
FROM superstore
GROUP BY YEAR(order_date)
ORDER BY order_year;

WITH monthly AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month_key,
        ROUND(SUM(sales), 2) AS monthly_sales,
        ROUND(SUM(profit), 2) AS monthly_profit
    FROM superstore
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    month_key,
    monthly_sales,
    LAG(monthly_sales) OVER (ORDER BY month_key) AS previous_month_sales,
    ROUND(((monthly_sales - LAG(monthly_sales) OVER (ORDER BY month_key)) / NULLIF(LAG(monthly_sales) OVER (ORDER BY month_key), 0)) * 100, 2) AS month_over_month_sales_growth_pct
FROM monthly
ORDER BY month_key;

-- H. DISCOUNT ANALYSIS
WITH discount_bands AS (
    SELECT
        CASE
            WHEN discount >= 0.50 THEN '50%+'
            WHEN discount >= 0.30 THEN '30% to 49%'
            WHEN discount >= 0.20 THEN '20% to 29%'
            WHEN discount >= 0.10 THEN '10% to 19%'
            ELSE '0% to 9%'
        END AS discount_band,
        COUNT(*) AS transaction_lines,
        COUNT(DISTINCT order_id) AS orders,
        ROUND(SUM(sales), 2) AS sales,
        ROUND(SUM(profit), 2) AS profit,
        ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS margin_pct
    FROM superstore
    GROUP BY
        CASE
            WHEN discount >= 0.50 THEN '50%+'
            WHEN discount >= 0.30 THEN '30% to 49%'
            WHEN discount >= 0.20 THEN '20% to 29%'
            WHEN discount >= 0.10 THEN '10% to 19%'
            ELSE '0% to 9%'
        END
)
SELECT *
FROM discount_bands
ORDER BY
    CASE discount_band
        WHEN '50%+' THEN 1
        WHEN '30% to 49%' THEN 2
        WHEN '20% to 29%' THEN 3
        WHEN '10% to 19%' THEN 4
        ELSE 5
    END;

SELECT
    COUNT(*) AS transaction_lines,
    COUNT(DISTINCT order_id) AS distinct_orders,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS margin_pct
FROM superstore
WHERE discount >= 0.50;

-- I. PRODUCT ANALYSIS
SELECT
    product_name,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;

SELECT
    product_name,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 10;

SELECT
    product_name,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY total_profit ASC
LIMIT 20;

-- J. CUSTOMER ANALYSIS
SELECT
    customer_id,
    customer_name,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS order_frequency
FROM superstore
GROUP BY customer_id, customer_name
ORDER BY total_sales DESC
LIMIT 20;

SELECT
    customer_id,
    customer_name,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS order_frequency,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS margin_pct
FROM superstore
GROUP BY customer_id, customer_name
ORDER BY total_profit DESC
LIMIT 20;

-- K. ADVANCED SQL
WITH order_totals AS (
    SELECT
        order_id,
        ROUND(SUM(sales), 2) AS order_sales,
        ROUND(SUM(profit), 2) AS order_profit,
        COUNT(*) AS transaction_lines
    FROM superstore
    GROUP BY order_id
)
SELECT
    order_id,
    order_sales,
    order_profit,
    transaction_lines,
    SUM(order_sales) OVER (ORDER BY order_sales DESC) AS running_sales_total,
    RANK() OVER (ORDER BY order_sales DESC) AS sales_rank
FROM order_totals
ORDER BY order_sales DESC
LIMIT 20;

WITH category_rank AS (
    SELECT
        category,
        ROUND(SUM(sales), 2) AS category_sales,
        ROUND(SUM(profit), 2) AS category_profit,
        ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS margin_pct,
        RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank,
        RANK() OVER (ORDER BY SUM(profit) DESC) AS profit_rank
    FROM superstore
    GROUP BY category
)
SELECT * FROM category_rank;
