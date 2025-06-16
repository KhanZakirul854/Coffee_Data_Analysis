-- Monday Coffe Data Analysis

SELECT * FROM city;
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;

-- Reports & Data Analysis
-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?
SELECT 
	city_name, 
	ROUND((population*0.25)/1000000,2) AS consumers_in_mils, 
	city_rank
FROM city
ORDER BY population DESC;



-- -- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
SELECT *,
	EXTRACT(YEAR FROM sale_date) AS year,
	EXTRACT(quarter FROM sale_date) AS qtr	
FROM sales
WHERE EXTRACT(quarter FROM sale_date) = 4
AND 
EXTRACT(YEAR FROM sale_date) = 2023;

-- Total Revenue
SELECT SUM(total) FROM sales
WHERE EXTRACT(quarter FROM sale_date) = 4
AND 
EXTRACT(YEAR FROM sale_date) = 2023;

-- If in case we want to find out each city and their revenue
SELECT
	ci.city_name,
	SUM(s.total) as total_revenue
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
WHERE EXTRACT(quarter FROM s.sale_date) = 4
AND 
EXTRACT(YEAR FROM s.sale_date) = 2023
GROUP BY 1
ORDER BY 2 DESC; 


-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?

SELECT 
	p.product_name,
	COUNT(s.sale_id) as total_orders
FROM products as p
LEFT JOIN
sales as s
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_orders DESC;


-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?

-- city and total sale
-- no customer in each these city
SELECT
	ci.city_name,
	SUM(s.total) as total_revenue,
	COUNT(DISTINCT s.customer_id) as total_customers,
	ROUND(SUM(s.total)::numeric/COUNT(DISTINCT s.customer_id),2)::numeric as avg_sale_pr_customer
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY ci.city_name
ORDER BY avg_sale_pr_customer DESC; 


-- Q.5
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- City Population and Coffee Consumers (25%)
-- return city_name, total current customers, estimated coffee consumers

WITH city_table as
(SELECT
	city_name,
	ROUND((population * .25)/1000000,2) as coffee_consumers
FROM city
),
customer_table AS
(SELECT 
	ci.city_name,
	COUNT(DISTINCT c.customer_id) as unique_customers
FROM sales as s
JOIN customers as c
ON c.customer_id = s.customer_id
JOIN city as ci
ON c.city_id = ci.city_id
GROUP BY ci.city_name
 )
SELECT
	customer_table.city_name,
	city_table.coffee_consumers AS coffee_consumer_in_million,
	customer_table.unique_customers
FROM city_table
JOIN
customer_table 
ON city_table.city_name = customer_table.city_name


-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
SELECT *
FROM -- table name
(
SELECT 
	ci.city_name,
	p.product_name,
	COUNT(s.sale_id) as total_orders,
	DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) as rank
FROM sales as s
JOIN products as p
ON s.product_id = p.product_id
JOIN customers as c
ON c.customer_id = s.customer_id
JOIN city as ci
ON c.city_id = ci.city_id
GROUP BY ci.city_name, p.product_name
--ORDER BY ci.city_name, total_orders DESC;
	) as t1
WHERE rank <= 3;


-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?
SELECT * FROM products

SELECT 
	ci.city_name,
	COUNT(DISTINCT c.customer_id) as unique_customers
FROM city as ci
LEFT JOIN 
customers as c
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
JOIN products as p
ON p.product_id = s.product_id
WHERE 
	s.product_id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
GROUP BY ci.city_name

-- -- Q.8
-- Find each city and their average sale per customer and avg rent per customer
-- Average Sale vs Rent

WITH city_table 
AS
(SELECT
	ci.city_name,
	COUNT(DISTINCT s.customer_id) as total_customers,
	ROUND(SUM(s.total)::numeric/COUNT(DISTINCT s.customer_id),2)::numeric as avg_sale_pr_customer
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY ci.city_name
ORDER BY avg_sale_pr_customer DESC
 ),
-- each city and total rent/total customers
city_rent AS
(SELECT city_name, estimated_rent
FROM city)
SELECT 
	cr.city_name,
	cr.estimated_rent,
	ct.total_customers,
	ct.avg_sale_pr_customer,
	ROUND(cr.estimated_rent::numeric/ct.total_customers::numeric,2) as avg_rent_per_customer
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY avg_rent_per_customer DESC;
-- DO order by again to check highest average sale per customer



-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city
WITH
monthly_sales
AS
(SELECT 
	ci.city_name,
	EXTRACT(MONTH FROM sale_date) as month,
	EXTRACT(YEAR FROM sale_date) as year,
	SUM(s.total) as total_sale
FROM sales as s
JOIN customers as c
ON c.customer_id = s.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY 1,2,3
ORDER BY 1,3,2
),
growth_ratio
AS
(
SELECT
	city_name,
	month,
	year,
	total_sale as cur_month_sale,
	LAG(total_sale,1) OVER(PARTITION BY city_name ORDER BY year, month) as last_month_sale
FROM monthly_sales
	)
SELECT
	city_name,
	month,
	year,
	cur_month_sale,
	last_month_sale,
	ROUND((cur_month_sale - last_month_sale)::numeric/last_month_sale::numeric * 100, 2) as growth_ratio
FROM growth_ratio
WHERE growth_ratio IS NOT NULL


-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

WITH city_table 
AS
(SELECT
	ci.city_name,
	COUNT(DISTINCT s.customer_id) as total_customers,
	ROUND(SUM(s.total)::numeric/COUNT(DISTINCT s.customer_id),2)::numeric as avg_sale_pr_customer,
 	SUM(s.total) AS total_revenue
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY ci.city_name
ORDER BY avg_sale_pr_customer DESC
 ),
-- each city and total rent/total customers
city_rent AS
(SELECT city_name, estimated_rent, ROUND((population*0.25)/1000000,2) as estimated_coffee_consumer_in_mils
FROM city)
SELECT 
	cr.city_name,
	ct.total_revenue,
	cr.estimated_rent as total_rent,
	ct.total_customers,
	estimated_coffee_consumer_in_mils,
	ct.avg_sale_pr_customer,
	ROUND(cr.estimated_rent::numeric/ct.total_customers::numeric,2) as avg_rent_per_customer
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY total_revenue DESC;

SELECT 
/*
-- Recommendation
City 1 : Pune
1. Avg Rent per customer is less 
2. Highest total revenue 
3. Avg sale per customer is also high

City 2 : Delhi
1. Highest estimated coffee consumer which is 7.75M
2. Highest totoal customer which is 68
3. Avg rent per customer 330 which is still under 500

City 3 : Jaipur
1. Highest number of customer - 69
2. Avg rent per customer is less (156)
3. Avg sale per customer is good (11.6k)

*/





