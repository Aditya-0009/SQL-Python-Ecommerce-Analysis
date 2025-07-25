USE ecommerce;
SELECT * FROM customers;

SELECT customer_city AS cc FROM customers GROUP BY customer_city;

SELECT COUNT(order_id) FROM orders WHERE YEAR(order_purchase_timestamp) = 2017;


SELECT p.product_category,ROUND(SUM(payments.payment_value),2) AS total_sales
FROM order_items AS o
JOIN products AS p
ON o.product_id = p.product_id
JOIN payments
ON payments.order_id = o.order_id
GROUP BY p.product_category
ORDER BY total_sales DESC;




SELECT customer_state, COUNT(customer_id) FROM customers
GROUP BY customer_state;




SELECT MONTHNAME(order_purchase_timestamp) AS Order_Month,
COUNT(order_id) FROM orders
WHERE YEAR(order_purchase_timestamp) = 2018
GROUP BY Order_Month , MONTH(order_purchase_timestamp)
ORDER BY MONTH(order_purchase_timestamp);



-- average number of products per order , group by city

WITH count_per_order AS (
SELECT o.order_id,o.customer_id,COUNT(oi.product_id) as oc
FROM orders AS o
JOIN order_items as oi
ON o.order_id = oi.order_id
GROUP BY o.order_id,o.customer_id
)
SELECT c.customer_city,AVG(count_per_order.oc) as Average_Orders
FROM customers c
JOIN count_per_order
ON c.customer_id = count_per_order.customer_id
GROUP BY c.customer_city
ORDER BY Average_Orders DESC;







WITH revenue_by_category AS (
SELECT coalesce(p.product_category,'Uncategorised') AS Product_Category,
ROUND(SUM(oi.price+oi.freight_value),2) AS revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY coalesce(p.product_category,'Uncategorised')
)
SELECT revenue_by_category.Product_Category AS Prod_Category,
ROUND((revenue_by_category.revenue / total.total_revenue)*100,2) 
AS Percentage_Of_TotalRevenue_Per_Category
FROM revenue_by_category,
(SELECT SUM(revenue) AS total_revenue FROM revenue_by_category) AS total
ORDER BY Percentage_Of_TotalRevenue_Per_Category DESC;






SELECT p.product_category,COUNT(oi.product_id) AS Product_Order_Count,
ROUND(AVG(oi.price),2) as Average_Product_Price
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_category
ORDER BY Product_Order_Count DESC;



SELECT *, DENSE_RANK() OVER( ORDER BY total_sales DESC) AS ranking
FROM
(SELECT oi.seller_id, SUM(p.payment_value) as total_sales
FROM order_items oi
JOIN payments p
ON oi.order_id = p.order_id
GROUP BY oi.seller_id) AS b;
