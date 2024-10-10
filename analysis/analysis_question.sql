--Question 1. Which cookie generates the highest total sale and highest order?
--Sale
SELECT c.name, SUM(od.total_price) AS total_sale
FROM Order_Details od
LEFT JOIN Cookies c
ON od.cookie_id = c.cookie_id
GROUP BY c.name
ORDER BY total_sale DESC 

--Order
SELECT c.name, SUM(od.quantity) AS highest_order_cookie 
FROM Order_Details od
LEFT JOIN Cookies c
ON od.cookie_id = c.cookie_id
GROUP BY c.name
ORDER BY highest_order_cookie DESC

--Question 2. What is the trend in sales over the last 12 Months
SELECT SUM(od.quantity) AS total_order_for_the_day, o.order_date, SUM(od.total_price) as total_sale
FROM Order_Details od
LEFT JOIN Orders o
ON od.order_id = o.order_id
GROUP BY o.order_date
ORDER BY o.order_date ASC

--Question 3. What percentage of customers are repeat buyers? Formula: No. of Customers Who Purch More Than Once / Total No. Of Customer x 100
--USE CTE and SUBQUERY
--Convert the values to a decimal type to avoid integer division
--You can use the CAST function to convert the integer values to decimals or floats before performing the division, which will allow SQL Server to return a decimal result.
WITH repeat_order AS (
SELECT customer_id, COUNT(*) AS repeat_orders 
FROM Orders
GROUP BY customer_id
HAVING COUNT(*) > 1
)
SELECT 
    COUNT(repeat_orders) AS total_repeat_order, 
    (SELECT COUNT(customer_id) FROM Orders) AS total_orders,
    CAST(COUNT(repeat_orders) AS DECIMAL(10, 2)) / CAST((SELECT COUNT(customer_id) FROM Orders) AS DECIMAL(10, 2)) * 100 AS percent_of_repeat_orders
FROM repeat_order;

--Explanation:
--CAST(COUNT(repeat_orders) AS DECIMAL(10, 2)) converts the count of repeat orders into a decimal value with 2 decimal places.
--CAST((SELECT COUNT(customer_id) FROM Orders) AS DECIMAL(10, 2)) ensures that the total count of orders is also treated as a decimal.

--4. What is the month-over-month sales
SELECT YEAR(o.order_date) AS year_cookies, 
		CASE 
		WHEN MONTH(o.order_date) = 1 THEN 'January'
		WHEN MONTH(o.order_date) = '2' THEN 'February'
		WHEN MONTH(o.order_date) = '3' THEN 'March'
		WHEN MONTH(o.order_date) = '4' THEN 'April'
		WHEN MONTH(o.order_date) = '5' THEN 'May'
		WHEN MONTH(o.order_date) = '6' THEN 'June'
		WHEN MONTH(o.order_date) = '7' THEN 'July'
		WHEN MONTH(o.order_date) = '8' THEN 'August'
		WHEN MONTH(o.order_date) = '9' THEN 'September'
		WHEN MONTH(o.order_date) = '10' THEN 'October'
		WHEN MONTH(o.order_date) = '11' THEN 'November'
		WHEN MONTH(o.order_date) = '12' THEN 'December'
		END AS month_cookies,
		SUM(od.total_price) as total_sale
FROM Order_Details od
LEFT JOIN Orders o
ON od.order_id = o.order_id
GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY year_cookies DESC

--Question 5.1
--Can we forecast which products will perform well in the future based on past performance? 9 months past performance in 2024 based on sales and order
--Order
WITH nine_month_performance AS (
SELECT c.name AS cookies, SUM(od.quantity) AS highest_order_cookie, YEAR(o.order_date) AS year_cookies,
		CASE 
		WHEN MONTH(o.order_date) = '1' THEN 'January'
		WHEN MONTH(o.order_date) = '2' THEN 'February'
		WHEN MONTH(o.order_date) = '3' THEN 'March'
		WHEN MONTH(o.order_date) = '4' THEN 'April'
		WHEN MONTH(o.order_date) = '5' THEN 'May'
		WHEN MONTH(o.order_date) = '6' THEN 'June'
		WHEN MONTH(o.order_date) = '7' THEN 'July'
		WHEN MONTH(o.order_date) = '8' THEN 'August'
		WHEN MONTH(o.order_date) = '9' THEN 'September'
		WHEN MONTH(o.order_date) = '10' THEN 'October'
		WHEN MONTH(o.order_date) = '11' THEN 'November'
		WHEN MONTH(o.order_date) = '12' THEN 'December'
		END AS month_cookies,
		SUM(od.total_price) as total_sale
FROM Order_Details od
LEFT JOIN Cookies c
ON od.cookie_id = c.cookie_id
LEFT JOIN Orders o
ON od.order_id = o.order_id
GROUP BY YEAR(o.order_date), MONTH(o.order_date), c.name
)

SELECT cookies, SUM(highest_order_cookie) AS total_order
FROM nine_month_performance
WHERE month_cookies IN ('January','February','March','April','May','June','July','August','September') AND year_cookies = 2024
GROUP BY cookies
ORDER BY total_order DESC;

--Sale
WITH nine_month_performance AS (
SELECT c.name AS cookies, SUM(od.quantity) AS highest_order_cookie, YEAR(o.order_date) AS year_cookies,
		CASE 
		WHEN MONTH(o.order_date) = '1' THEN 'January'
		WHEN MONTH(o.order_date) = '2' THEN 'February'
		WHEN MONTH(o.order_date) = '3' THEN 'March'
		WHEN MONTH(o.order_date) = '4' THEN 'April'
		WHEN MONTH(o.order_date) = '5' THEN 'May'
		WHEN MONTH(o.order_date) = '6' THEN 'June'
		WHEN MONTH(o.order_date) = '7' THEN 'July'
		WHEN MONTH(o.order_date) = '8' THEN 'August'
		WHEN MONTH(o.order_date) = '9' THEN 'September'
		WHEN MONTH(o.order_date) = '10' THEN 'October'
		WHEN MONTH(o.order_date) = '11' THEN 'November'
		WHEN MONTH(o.order_date) = '12' THEN 'December'
		END AS month_cookies,
		SUM(od.total_price) as total_sale
FROM Order_Details od
LEFT JOIN Cookies c
ON od.cookie_id = c.cookie_id
LEFT JOIN Orders o
ON od.order_id = o.order_id
GROUP BY YEAR(o.order_date), MONTH(o.order_date), c.name
)
SELECT cookies, SUM(total_sale) AS total_sale
FROM nine_month_performance
WHERE month_cookies IN ('January','February','March','April','May','June','July','August','September') AND year_cookies = 2024
GROUP BY cookies
ORDER BY total_sale DESC;

--Question 5.2
--USE CTE and SUBQUERY
--Using the moving average method for a 4-quarter. Estimated sale in Oct, Nov, Dec
--What are the expected sales for the next quarter based on historical trends?
WITH sale_per_month AS (
SELECT YEAR(o.order_date) AS year_cookies, 
		CASE 
		WHEN MONTH(o.order_date) = '1' THEN 'January'
		WHEN MONTH(o.order_date) = '2' THEN 'February'
		WHEN MONTH(o.order_date) = '3' THEN 'March'
		WHEN MONTH(o.order_date) = '4' THEN 'April'
		WHEN MONTH(o.order_date) = '5' THEN 'May'
		WHEN MONTH(o.order_date) = '6' THEN 'June'
		WHEN MONTH(o.order_date) = '7' THEN 'July'
		WHEN MONTH(o.order_date) = '8' THEN 'August'
		WHEN MONTH(o.order_date) = '9' THEN 'September'
		WHEN MONTH(o.order_date) = '10' THEN 'October'
		WHEN MONTH(o.order_date) = '11' THEN 'November'
		WHEN MONTH(o.order_date) = '12' THEN 'December'
		END AS month_cookies,
		SUM(od.total_price) as total_sale
FROM Order_Details od
LEFT JOIN Orders o
ON od.order_id = o.order_id
GROUP BY YEAR(o.order_date), MONTH(o.order_date)

)
SELECT SUM(total_sale) AS first_qtr_sale,
			(SELECT SUM(total_sale)
			FROM sale_per_month
			WHERE month_cookies IN ('April','May','June') AND year_cookies = 2024) AS second_qtr_sale,
			(SELECT SUM(total_sale)
			FROM sale_per_month
			WHERE month_cookies IN ('July','August','September') AND year_cookies = 2024) AS third_qtr_sale,
			(SELECT ROUND(SUM(total_price)/ 3, 2)
			FROM Order_Details od
			LEFT JOIN Orders o
			ON od.order_id = o.order_id
			WHERE YEAR(o.order_date) = '2024') AS avg_fourth_qtr_sale
FROM sale_per_month
WHERE month_cookies IN ('January','February','March') AND year_cookies = 2024
