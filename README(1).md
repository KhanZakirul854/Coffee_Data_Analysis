
# Coffee Data Analysis Project

## Project Overview
The **Monday Coffee Data Analysis** project aims to analyze sales data from Monday Coffee, a company that has been selling its products online since January 2023. The primary goal of this project is to determine the market potential and recommend the top three cities in India for opening new coffee shop locations based on consumer demand, sales performance, and other business metrics.

---

## Objectives
1. **Estimate Coffee Consumers**: Calculate the number of people in each city who are likely to consume coffee, assuming that 25% of the population consumes coffee.
2. **Revenue Analysis**: Determine the total revenue generated from coffee sales across all cities in the last quarter of 2023.
3. **Sales Count**: Find out how many units of each coffee product have been sold.
4. **City-based Sales Performance**: Calculate the average sales amount per customer for each city.
5. **Customer Segmentation**: Identify the number of unique customers in each city who have purchased coffee products.
6. **Market Potential**: Identify the top 3 cities based on the highest sales, including city name, total sales, total rent, total customers, and estimated coffee consumers.

---

## Key Questions Analyzed
1. **Coffee Consumers Count**: 
   - How many people in each city are estimated to consume coffee, given that 25% of the population does?
2. **Total Revenue from Coffee Sales**: 
   - What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
3. **Sales Count for Each Product**: 
   - How many units of each coffee product have been sold?
4. **Average Sales per City**: 
   - What is the average sales amount per customer in each city?
5. **City Population and Coffee Consumers**: 
   - Provide a list of cities along with their populations and estimated coffee consumers.
6. **Top Selling Products by City**: 
   - What are the top 3 selling products in each city based on sales volume?
7. **Customer Segmentation by City**: 
   - How many unique customers are there in each city who have purchased coffee products?
8. **Average Sale vs Rent**: 
   - Find each city and their average sale per customer and average rent per customer.
9. **Monthly Sales Growth**: 
   - Calculate the percentage growth (or decline) in sales over different time periods (monthly).
10. **Market Potential Analysis**: 
   - Identify the top 3 cities based on the highest sales and provide insights including city name, total sale, total rent, total customers, and estimated coffee consumers.

---

## Project Structure

### Schemas and Tables
The database consists of four main tables:

1. **`city`**: Contains information about cities, including their population, estimated rent, and city rank.
2. **`customers`**: Contains customer details and their associated city.
3. **`products`**: Contains information about coffee products, including product name and price.
4. **`sales`**: Contains sales transactions, linking customers and products.

The SQL schema setup creates the necessary tables and foreign key constraints to ensure data integrity across the tables.

```sql
CREATE TABLE city
(
	city_id INT PRIMARY KEY,
	city_name VARCHAR(15),
	population BIGINT,
	estimated_rent FLOAT,
	city_rank INT
);

CREATE TABLE customers
(
	customer_id INT PRIMARY KEY,
	customer_name VARCHAR(25),
	city_id INT,
	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);

CREATE TABLE products
(
	product_id INT PRIMARY KEY,
	product_name VARCHAR(35),
	Price float
);

CREATE TABLE sales
(
	sale_id INT PRIMARY KEY,
	sale_date DATE,
	product_id INT,
	customer_id INT,
	total FLOAT,
	rating INT,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

### Reports & Data Analysis Queries
A series of SQL queries were developed to answer the business questions mentioned above. Here are the key queries for analysis:

1. **Coffee Consumers Count**:
   ```sql
   SELECT 
       city_name, 
       ROUND((population * 0.25) / 1000000, 2) AS consumers_in_mils, 
       city_rank
   FROM city
   ORDER BY population DESC;
   ```

2. **Total Revenue from Coffee Sales**:
   ```sql
   SELECT SUM(total) FROM sales
   WHERE EXTRACT(quarter FROM sale_date) = 4
   AND EXTRACT(YEAR FROM sale_date) = 2023;
   ```

3. **Sales Count for Each Product**:
   ```sql
   SELECT 
       p.product_name,
       COUNT(s.sale_id) AS total_orders
   FROM products AS p
   LEFT JOIN sales AS s
       ON s.product_id = p.product_id
   GROUP BY p.product_name
   ORDER BY total_orders DESC;
   ```

4. **Average Sales Amount per City**:
   ```sql
   SELECT 
       ci.city_name,
       SUM(s.total) AS total_revenue,
       COUNT(DISTINCT s.customer_id) AS total_customers,
       ROUND(SUM(s.total)::numeric / COUNT(DISTINCT s.customer_id), 2)::numeric AS avg_sale_pr_customer
   FROM sales AS s
   JOIN customers AS c ON s.customer_id = c.customer_id
   JOIN city AS ci ON ci.city_id = c.city_id
   GROUP BY ci.city_name
   ORDER BY avg_sale_pr_customer DESC;
   ```

5. **Top Selling Products by City**:
   ```sql
   SELECT *
   FROM
   (
   SELECT 
       ci.city_name,
       p.product_name,
       COUNT(s.sale_id) AS total_orders,
       DENSE_RANK() OVER (PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) AS rank
   FROM sales AS s
   JOIN products AS p ON s.product_id = p.product_id
   JOIN customers AS c ON c.customer_id = s.customer_id
   JOIN city AS ci ON c.city_id = ci.city_id
   GROUP BY ci.city_name, p.product_name
   ) AS t1
   WHERE rank <= 3;
   ```

6. **Average Sale vs Rent**:
   ```sql
   WITH city_table AS (
       SELECT
           ci.city_name,
           COUNT(DISTINCT s.customer_id) AS total_customers,
           ROUND(SUM(s.total)::numeric / COUNT(DISTINCT s.customer_id), 2)::numeric AS avg_sale_pr_customer
   FROM sales AS s
   JOIN customers AS c ON s.customer_id = c.customer_id
   JOIN city AS ci ON ci.city_id = c.city_id
   GROUP BY ci.city_name
   ),
   city_rent AS (
       SELECT city_name, estimated_rent
       FROM city
   )
   SELECT 
       cr.city_name,
       cr.estimated_rent,
       ct.total_customers,
       ct.avg_sale_pr_customer,
       ROUND(cr.estimated_rent::numeric / ct.total_customers::numeric, 2) AS avg_rent_per_customer
   FROM city_rent AS cr
   JOIN city_table AS ct ON cr.city_name = ct.city_name
   ORDER BY avg_rent_per_customer DESC;
   ```

---

### **Findings and Recommendations**

After analyzing the data, we recommend the following cities for new store openings based on their sales performance, consumer potential, and financial viability:

1. **City 1: Pune**  
   - Low average rent per customer.
   - Highest total revenue.
   - High average sales per customer.

2. **City 2: Delhi**  
   - Highest estimated coffee consumers (7.7 million).
   - Largest customer base (68 customers).
   - Rent per customer is still under 500.

3. **City 3: Jaipur**  
   - Highest number of customers (69).
   - Low rent per customer (156).
   - Good average sales per customer (11.6k).

---

### **Zakirul Khan**

This project showcases SQL analysis skills applied to the coffee market. Feedback and collaboration are welcome!

---
