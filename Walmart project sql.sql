Create Database if not exists Project_Sql;

USE  Project_Sql;

CREATE TABLE IF NOT EXISTS sales(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT,
    gross_income DECIMAL(12, 4),
    rating FLOAT
);
-- Data Cleaning--
SELECT * FROM sales;
-- time_of_day
SELECT time,( Case 
                 when time  BETWEEN '00:00:00' AND '12;00:00' THEN "Morning"
                 when time  BETWEEN '12:01:00' AND '16:00:00' THEN "Afternoon"
                 ELSE  "Evening"
                 End
                 ) As time_of_date FROM Sales; 
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

SET SQL_SAFE_UPDATES=0;

UPDATE sales SET time_of_day=(
                         Case 
                 when time  BETWEEN '00:00:00' AND '12:00:00' THEN "Morning"
                 when time  BETWEEN '12:01:00' AND '16:00:00' THEN "Afternoon"
                 ELSE  "Evening"
                 End);
-- ADD day_name column
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales SET day_name=DAYNAME(date);
-- ADD month_name column 
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);
UPDATE sales set month_name = MONTHNAME(date);

SELECT * FROM SALES;
-- How many unique cities does the data have?
SELECT DISTINCT city FROM sales;
-- -- In which city is each branch?
SELECT DISTINCT city, branch  FROM sales;
-- How many unique product lines does the data have?
SELECT DISTINCT product_line from sales;
-- What is the most common payment method?
SELECT  payment, count(payment) from sales group by payment order by count(payment) desc limit 1;
-- What is the most selling product line?
SELECT SUM(quantity) as qty, product_line FROM sales GROUP BY product_line ORDER BY qty DESC;
-- What is the total revenue by month?
SELECT month_name, sum(total) from sales group by month_name;
-- What month had the largest COGS?
select month_name, sum(cogs)  from sales group by month_name order by sum(cogs) desc limit 1;
-- What product line had the largest revenue?
select Product_line, sum(total) from sales group by product_line  order by sum(total) desc limit 1;

-- What is the city with the largest revenue
SELECT city, branch, sum(total) from sales group by city ,branch order by sum(total) desc;
-- What product line had the largest VAT?
SELECT PRODUCT_LINE,avg(tax_pct) FROM SALES group by Product_line ;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT productLine, AVG(total) AS avg_sales
FROM sales
GROUP BY productLine;

-- Add a column indicating whether sales are greater than average
SELECT od.*, 
    CASE 
        WHEN od.total>avg_total Then "good"
        ELSE 'Bad'
    END AS sales_total
FROM sales
JOIN (
    SELECT productLine, AVG(total) as avg_sales
    FROM sales
    GROUP BY productLine
) AS avg_sales_per_line
ON od.productLine = avg_sales_per_line.productLine;

-- Which branch sold more products than average product sold?
select branch,sum(total) from sales group by branch having sum(total) >(select Avg(total) from(select sum(total) from sales group by branch)as avg_per_branch);


-- What is the most common product line by gender
SELECT 
    gender, product_line, COUNT(gender) AS total_cnt
FROM
    sales
GROUP BY gender , product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line
SELECT
	ROUND(AVG(rating), 2) as avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- -- Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;
-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

SELECT
	customer_type,
sum(tax_pct) as total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;

-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;
-- -- How many unique payment methods does the data have?
SELECT
	DISTINCT payment
FROM sales;

-- What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- -- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;

-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	rating 
FROM sales
GROUP BY time_of_day
ORDER BY rating DESC;
-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	(rating) 
FROM sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY rating DESC;
-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;