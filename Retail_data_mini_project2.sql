CREATE DATABASE retail_db;
USE retail_db;

-- customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- products table
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    added_on DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Pending',
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- order_items table
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    item_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- payments table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount_paid DECIMAL(10,2) NOT NULL CHECK (amount_paid > 0),
    method VARCHAR(20) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- product_reviews table
CREATE TABLE product_reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    customer_id INT,
    rating INT NOT NULL,
    review_text TEXT,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- inserted datas checking in tables..
SELECT * FROM customers LIMIT 5;
SELECT * FROM order_items LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM payments LIMIT 5;
SELECT * FROM product_reviews LIMIT 5;
SELECT * FROM products LIMIT 5;

-- level 1 :- Basics

-- 1. Retrieve customer names and emails for email marketing?
SELECT  name as customer_names , email from customers;

-- 2. View complete product catalog with all available details?
SELECT * FROM products;

-- 3. List all unique product categories
SELECT DISTINCT category FROM products;

-- 4. Show all products priced above ₹1,000
SELECT product_id, name, price FROM products
WHERE price>1000
ORDER BY price;

-- 5. Display products within a mid-range price bracket (₹2,000 to ₹5,000)
SELECT product_id, name, category, price, stock_quantity FROM products
WHERE price>2000 AND price<5000
ORDER BY price;

-- 6. Fetch data for specific customer IDs (e.g., from loyalty program list)
SELECT customer_id, name, email, phone, created_at FROM customers
WHERE customer_id IN (1, 5, 12, 20);

-- 7. Identify customers whose names start with the letter ‘A’
SELECT customer_id, name, email, phone FROM customers 
WHERE name LIKE 'A%';

-- 8. List electronics products priced under ₹3,000
SELECT product_id, name, category, price, stock_quantity FROM products
WHERE price<3000 AND category = 'Electronics'
ORDER BY price;

-- 9. Display product names and prices in descending order of price
SELECT name as product_name, price FROM products
ORDER BY price DESC;

-- 10. Display product names and prices, sorted by price and then by name
SELECT name, price FROM products
ORDER BY price ASC, name ASC;

-- level 2:- Filtering and Formatting

-- 1. Retrieve orders where customer information is missing (possibly due to data migration or deletion)
SELECT o.order_id, o.customer_id, o.order_date, o.total_amount 
FROM orders o
JOIN customers c 
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 2. Display customer names and emails using column aliases for frontend readability
SELECT  name AS customer_name, email AS email_address
FROM customers;

-- 3. Calculate total value per item ordered by multiplying quantity and item price
SELECT p.name AS 'item name', 
	oi.quantity AS 'quantity ordered',
    oi.item_price AS 'unit price',
    (oi.quantity * oi.item_price) AS 'total value'
FROM order_items oi
JOIN products p 
ON oi.product_id = p.product_id;

-- 4. Combine customer name and phone number in a single column
SELECT CONCAT(name, ': (', phone, ')') AS "Customer Info"
FROM customers;

-- 5. Extract only the date part from order timestamps for date-wise reporting
SELECT DATE(order_date) AS "Order Date"
FROM orders
GROUP BY DATE(order_date)
ORDER BY DATE(order_date);

-- 6. List products that do not have any stock left
SELECT name as product_name, stock_quantity FROM products
WHERE stock_quantity = 0;

-- level 3 :- Aggregation

-- 1. Count the total number of orders placed
SELECT COUNT(*) AS total_order_placed FROM orders
WHERE status != "Cancelled";

-- 2. Calculate the total revenue collected from all orders
SELECT sum(total_amount) AS total_revenue FROM orders
WHERE status != "Cancelled";

-- 3. Calculate the average order value
-- avg_order_value = total revenue collected / number of orders
SELECT AVG(total_amount) AS avg_order_value FROM orders
WHERE status != "Cancelled";

-- 4. Count the number of customers who have placed at least one order
SELECT COUNT(DISTINCT customer_id) AS customers_with_orders
FROM orders
WHERE status != "Cancelled";

-- 5. Find the number of orders placed by each customer
SELECT customer_id, COUNT(order_id) AS total_orders FROM orders
WHERE status != "Cancelled"
GROUP BY customer_id
ORDER BY customer_id;

-- 6. Find total sales amount made by each customer
SELECT c.customer_id, c.name, c.email, SUM(o.total_amount) AS total_sales
FROM customers c
JOIN orders o 
ON c.customer_id = o.customer_id
WHERE o.status != "Cancelled"
GROUP BY c.customer_id, c.name, c.email
ORDER BY total_sales DESC;

-- 7. List the number of products sold per category
SELECT p.category, SUM(oi.quantity) AS total_products_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE status != "Cancelled"
GROUP BY p.category
ORDER BY total_products_sold DESC;

-- 8. Find the average item price per category
SELECT p.category, AVG(oi.item_price) AS avg_price
FROM order_items oi 
JOIN productS p 
ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_price DESC;

-- 9. Show number of orders placed per day
SELECT DATE(order_date) AS order_day, COUNT(order_id) AS total_orders
FROM orders
WHERE status != "Cancelled"
GROUP BY DATE(order_date)
ORDER BY order_day;

-- 10. List total payments received per payment method
SELECT p.method, SUM(p.amount_paid) AS total_received
FROM payments p
JOIN orders o ON p.order_id = o.order_id
WHERE o.status != 'Cancelled'
GROUP BY p.method
ORDER BY total_received DESC;

-- level 4:- multi table queries(JOINS)

-- 1. Retrieve order details along with the customer name (INNER JOIN)
SELECT o.order_id, o.order_date, o.status, o.total_amount, c.name AS customer_name
FROM orders o 
INNER JOIN customers c 
ON o.customer_id = c.customer_id
ORDER BY o.order_date;

-- 2. Get list of products that have been sold (INNER JOIN with order_items)
SELECT DISTINCT p.product_id, p.name AS product_name, p.category
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.status !="Cancelled"
ORDER BY p.name;

-- 3. List all orders with their payment method (INNER JOIN)
SELECT o.order_id, o.order_date, o.status, o.total_amount,
p.method, p.amount_paid 
FROM orders o 
JOIN payments p
ON o.order_id = p.order_id
WHERE o.status != "Cancelled"
ORDER BY o.order_date;

-- 4. Get list of customers and their orders (LEFT JOIN)
SELECT c.customer_id, c.name AS customer_name, o.order_id, o.order_date
FROM customers c 
LEFT JOIN orders o 
ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

-- 5. List all products along with order item quantity (LEFT JOIN)
SELECT p.product_id, p.name AS product_name, oi.quantity
FROM products p 
JOIN order_items oi 
ON p.product_id = oi.product_id
ORDER BY p.product_id;

-- 6. List all payments including those with no matching orders (RIGHT JOIN)
SELECT p.payment_id, p.payment_date, p.amount_paid, o.order_id, o.customer_id
FROM orders o
RIGHT JOIN payments p
ON o.order_id = p.order_id
ORDER BY p.payment_id;

-- 7. Combine data from three tables: customer, order, and payment
SELECT c.customer_id, c.name, o.order_id, o.order_date, p.payment_id, p.payment_date, p.amount_paid
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
LEFT JOIN payments p
ON o.order_id = p.order_id
ORDER BY c.customer_id, o.order_id;

-- Level 5.:- Subqueries(inner queries)

-- 1. List all products priced above the average product price
SELECT product_id, name AS product_name, price FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

--  2. Find customers who have placed at least one order
SELECT c.customer_id, c.name AS customer_name FROM customers c 
WHERE EXISTS(
SELECT * FROM orders o 
WHERE o.customer_id = c.customer_id
)
ORDER BY c.customer_id;

-- 3. Show orders whose total amount is above the average for that customer
SELECT o.order_id, o.customer_id, o.total_amount, o.order_date FROM orders o 
WHERE o.total_amount > (
SELECT AVG(o2.total_amount)
FROM orders o2
WHERE o2.customer_id = o.customer_id)
ORDER BY o.customer_id, o.total_amount DESC;

-- 4. Display customers who haven’t placed any orders
SELECT c.customer_id, c.name AS customer_name FROM customers c 
WHERE NOT EXISTS (
	SELECT * FROM orders o 
    WHERE o.customer_id = c.customer_id
)
ORDER BY c.customer_id;

-- 5. Show products that were never ordered
SELECT p.product_id, p.name AS product_name, p.price FROM products p 
WHERE NOT EXISTS(
	SELECT * FROM order_items oi 
    WHERE oi.product_id = p.product_id
)
ORDER BY p.product_id;

-- 6. Show highest value order per customer
SELECT o.order_id, o.customer_id, o.total_amount, o.order_date FROM orders o 
WHERE o.total_amount = (
	SELECT MAX(o2.total_amount)
    FROM orders o2 
     WHERE o2.customer_id = o.customer_id
)
ORDER BY o.customer_id;

-- 7. Highest Order Per Customer (Including Names)
SELECT c.customer_id, c.name AS customer_name, o.order_id, o.total_amount, o.order_date
FROM customers c 
JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.total_amount = (
	SELECT MAX(o2.total_amount)
    FROM orders o2
    WHERE o2.customer_id = c.customer_id
)
ORDER BY c.customer_id;

-- level 6:- Set Operations

-- 1. List all customers who have either placed an order or written a product review
SELECT DISTINCT c.customer_id, c.name AS customer_name FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id

UNION

SELECT DISTINCT c.customer_id, c.name AS customer_name FROM customers c 
JOIN product_reviews r ON c.customer_id = r.customer_id

ORDER BY customer_id;

-- 2. List all customers who have placed an order as well as reviewed a product [intersect not supported]
SELECT c.customer_id, c.name AS customer_name FROM customers c 
JOIN(
	SELECT DISTINCT customer_id FROM orders
) o ON c.customer_id = o.customer_id
JOIN (
	SELECT DISTINCT customer_id FROM product_reviews
) r ON c.customer_id = r.customer_id
ORDER BY c.customer_id;