DROP DATABASE IF EXISTS WalmartSales;
CREATE DATABASE WalmartSales;
USE WalmartSales;

CREATE TABLE IF NOT EXISTS sales
(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6, 4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_pct FLOAT(11, 9) NOT NULL,
    gross_income DECIMAL(12, 4) NOT NULL,
    rating FLOAT(2, 1) NOT NULL
);

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------- Feature Engineering ------------------------------------------------------------------------

-- time_of_day

SELECT 
	time,
    (CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
		ELSE "Evening"
	END
);
 
-- day_name

SELECT
	date,
    DAYNAME(date) AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

-- month-name

SELECT 
	date,
    MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);

UPDATE sales
SET month_name = MONTHNAME(date);
-- ----------------------------------------------------------------------------------------------------------------------------------------------------


-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------- Generic -----------------------------------------------------------------------------------

-- How many unique cities does the data have?
SELECT 
	DISTINCT city
FROM sales;

-- in which city does the branch?
SELECT 
	DISTINCT branch
FROM sales;

SELECT
	DISTINCT city,
    branch
FROM sales;

SELECT *
FROM sales;
-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------- Product ----------------------------------------------------------------------------------

-- 1.How many unique Product lines doest the data have?
SELECT 
	COUNT(DISTINCT product_line)
FROM sales;

-- 2.Whats is the most common payment method?
SELECT
	payment_method,
	COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- 3.Whats is the most selling product line?
SELECT
	product_line,
    COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

-- 4.What is the total revenue by month?
SELECT 
	month_name AS Month,
    SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- 5.What month had the largest COGS?
SELECT
	month_name AS month,
    SUM(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;

-- 6.What product line had the largest revenue?
SELECT 
	product_line,
    SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- 7.What is the city with the largest revenue?
SELECT 
	branch,
    city,
    SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch
ORDER BY total_revenue DESC;

-- 8.What product line had the largest VAT?
SELECT 
	product_line,
    AVG(VAT) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- 9.Fetch each product line and add a column to those product line showing "Good", "Bad".Good if its greater than average sales
SELECT 
	ROUND(AVG(total), 2) 
FROM sales;

SELECT
	product_line,
    ROUND(AVG(total), 2) AS avg_sales,
    (CASE
		WHEN AVG(total) > (SELECT AVG(total) FROM sales) THEN "Good"
        ELSE "Bad"
    END) AS Evaluation
FROM sales
GROUP BY product_line;

-- 10. Which branch sold more products than average product sold
SELECT 
	branch,
    SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- 11.What is the most common product line by gender?
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM SALES
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- 12.What is the average rating of each product line?
SELECT
	ROUND(AVG(rating), 2) AS avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------- Sales -----------------------------------------------------------------------------------


-- 1.Number of sales made in each time of the day per weekday?
SELECT 
	time_of_day,
    COUNT(*) AS total_sales
FROM sales
WHERE day_name ="Monday"
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- 2.Which of the customer types brings the most revenue?
SELECT 
	customer_type,
    SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- 3.Which city has the largest tax percent/VAT (Value Added Tax)?
SELECT
	city,
    AVG(VAT) as VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- 4.Which customer type pays the most in VAT?
SELECT 
	customer_type,
    AVG(VAT) AS VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------- Customer -----------------------------------------------------------------------------------

-- 1. How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;

-- 2.How many unique payment methods does the data have?
SELECT
	DISTINCT payment_method
FROM sales;

-- 3.What is the most common customer type?
SELECT 
	customer_type,
    COUNT(customer_type) AS total_cst
FROM sales
GROUP BY customer_type
ORDER BY total_cst DESC;

-- 4.Which customer type buys the most?
SELECT 
	customer_type,
    COUNT(*) AS total_cst
FROM sales
GROUP BY customer_type
ORDER BY total_cst DESC;

-- 5. What is the gender of most of the customer?
SELECT
	gender,
    COUNT(gender) AS gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- 6.What is the gender distribution of each branch?
SELECT
	branch,
    gender,
    COUNT(gender) AS gender_cnt
FROM sales
GROUP BY branch,gender
ORDER BY branch;

-- 7.Which time of the day do customers give most ratings?
SELECT 
	time_of_day,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- 8.Which time of the day do customers give most ratings per branch?
SELECT
	branch,
	time_of_day,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY branch,time_of_day
ORDER BY branch;

-- 9.Which day of the week has the best avg ratings?
SELECT 
	day_name,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- 10.Which day of the week has the best average ratings per branch?
SELECT
	day_name,
    AVG(rating) AS avg_rating
FROM sales
WHERE branch = "B"
GROUP BY day_name
ORDER BY avg_rating DESC;
    