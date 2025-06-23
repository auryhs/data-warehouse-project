/*
performs data quality checks on raw data stored in the Bronze layer before it is cleaned and transformed into the Silver layer. 
The script includes validations such as null checks, duplicates detection, and format consistency to ensure data integrity.
*/

-- ====================================================================
-- Checking 'bronze.customers_raw'
-- ====================================================================
SELECT * FROM bronze.customers_raw;

-- check registered_date > First Order Date
SELECT c.cust_id, c.registered_date, cust_order.[First Order Date],
DATEDIFF(day, c.registered_date, cust_order.[First Order Date]) AS date_diff
FROM bronze.customers_raw  AS c
LEFT JOIN (SELECT cust_id, MIN(order_date) AS 'First Order Date'
FROM bronze.orders_raw
GROUP BY cust_id) cust_order ON c.cust_id = cust_order.cust_id
WHERE DATEDIFF(day, c.registered_date, cust_order.[First Order Date]) <0;

-- check min and max date
SELECT MIN(registered_date) AS min_date, MAX(registered_date) AS max_date
FROM bronze.customers_raw;

-- check if duplicate or NULL
SELECT cust_id, COUNT(*) 
FROM bronze.customers_raw
GROUP BY cust_id
HAVING COUNT(*) > 1 OR cust_id IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT city FROM bronze.customers_raw;
SELECT DISTINCT gender FROM bronze.customers_raw;
SELECT DISTINCT segment FROM bronze.customers_raw;

-- ====================================================================
-- Checking 'bronze.products_raw'
-- ====================================================================
SELECT * FROM bronze.products_raw;

-- check if duplicate or NULL
SELECT prod_id, COUNT(*) 
FROM bronze.products_raw
GROUP BY prod_id
HAVING COUNT(*) > 1 OR prod_id IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT category FROM bronze.products_raw;
SELECT DISTINCT brand FROM bronze.products_raw;
SELECT DISTINCT supplier FROM bronze.products_raw;

-- Check Price Null
SELECT * FROM bronze.products_raw
WHERE unit_price IS NULL;

-- ====================================================================
-- Checking 'bronze.campaigns_raw'
-- ====================================================================
SELECT * FROM bronze.campaigns_raw

-- Data Standardization & Consistency
SELECT DISTINCT channel FROM bronze.campaigns_raw;

-- Check if end date always < start date
SELECT * FROM bronze.campaigns_raw
WHERE end_date < start_date;


-- ====================================================================
-- Checking 'bronze.orders_raw'
-- ====================================================================
SELECT * FROM bronze.orders_raw;

-- check if duplicate or NULL
SELECT order_id, COUNT(*) 
FROM bronze.orders_raw
GROUP BY order_id
HAVING COUNT(*) > 1 OR order_id IS NULL;

-- Check cust_id not in Customers table
SELECT o.cust_id
FROM bronze.orders_raw o 
LEFT JOIN bronze.customers_raw c ON o.cust_id = c.cust_id
WHERE c.cust_id IS NULL;

-- Check campaign_id not in Campaign table
SELECT o.campaign_id
FROM bronze.orders_raw o
LEFT JOIN bronze.campaigns_raw c ON o.campaign_id = c.campaign_id
WHERE o.campaign_id is NOT NULL AND c.campaign_id IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT payment_type FROM bronze.orders_raw;
SELECT DISTINCT order_status FROM bronze.orders_raw;

-- Check order date and campaign periode align
SELECT o.order_id, o.campaign_id, o.order_date, c.start_date, c.end_date
FROM bronze.orders_raw o
LEFT JOIN bronze.campaigns_raw c ON 
o.campaign_id = c.campaign_id
WHERE NOT(o.order_date>=c.start_date AND o.order_date<=c.end_date)

-- ====================================================================
-- Checking 'bronze.order_items_raw'
-- ====================================================================
SELECT * FROM bronze.order_items_raw

-- Check data consistency Subtotal = Price * Quantity * (1-dicount percentage)
SELECT unit_price * qty * (1-discount_pct) AS subtotal_check, subtotal,
subtotal - (unit_price * qty * (1-discount_pct)) AS diff
FROM bronze.order_items_raw
WHERE subtotal - (unit_price * qty * (1-discount_pct)) > 1;

-- Check order_id not in Orders table 
SELECT oi.order_id
FROM bronze.order_items_raw oi 
LEFT JOIN bronze.orders_raw o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Check prod_id not in Products table 
SELECT oi.prod_id
FROM bronze.order_items_raw oi 
LEFT JOIN bronze.products_raw p ON oi.prod_id = p.prod_id
WHERE p.prod_id IS NULL;

-- Check data consistency between unit_price in Products & unit_ptice in OrderItems
SELECT * , p.unit_price
FROM bronze.order_items_raw oi
LEFT JOIN bronze.products_raw p 
ON oi.prod_id = p.prod_id 
WHERE oi.unit_price != p.unit_price 

-- See if discounts can exist without being tied to a campaign
SELECT oi.*, o.campaign_id  FROM bronze.order_items_raw oi 
LEFT JOIN (SELECT o.order_id, cust_id, order_date, payment_type, order_status, 
		CASE WHEN invalid_campaign.[order_id] IS NOT NULL THEN NULL ELSE o.campaign_id END AS campaign_id
		FROM bronze.orders_raw o 
		LEFT JOIN (SELECT o.order_id AS order_id
		FROM bronze.orders_raw o
		LEFT JOIN bronze.campaigns_raw c ON 
		o.campaign_id = c.campaign_id
		WHERE NOT(o.order_date>=c.start_date AND o.order_date<=c.end_date)) invalid_campaign 
		ON o.order_id = invalid_campaign.[order_id]) o ON oi.order_id = o.order_id

-- ====================================================================
-- Checking 'bronze.shipping_raw'
-- ====================================================================
SELECT * FROM bronze.shipping_raw

-- Data Standardization & Consistency
SELECT DISTINCT shipping_provider FROM bronze.shipping_raw;
SELECT DISTINCT shipping_status FROM bronze.shipping_raw;

-- Check Invalid Date, Ship_date must > order date 
SELECT s.*, o.order_date FROM 
bronze.shipping_raw s
LEFT JOIN bronze.orders_raw o ON 
s.order_id = o.order_id
WHERE s.ship_date < o.order_date;

-- Check order_id not in Order table
SELECT s.*, o.order_date FROM 
bronze.shipping_raw s
LEFT JOIN bronze.orders_raw o ON 
s.order_id = o.order_id
WHERE o.order_id IS NULL

-- ====================================================================
-- Checking 'bronze.reviews_raw'
-- ====================================================================
SELECT * FROM bronze.reviews_raw
ORDER BY 2 ASC;

-- Check duplicate for one trx (order_id & product_id)
SELECT order_id, prod_id, COUNT(review_id)
FROM bronze.reviews_raw
GROUP BY order_id,prod_id
ORDER BY 2 DESC;

-- Check id not in parent table 
SELECT r.* 
FROM bronze.reviews_raw r
LEFT JOIN bronze.orders_raw o ON r.order_id = o.order_id
WHERE o.order_id IS NULL; 

SELECT r.* 
FROM bronze.reviews_raw r
LEFT JOIN bronze.products_raw p ON r.prod_id = p.prod_id
WHERE p.prod_id IS NULL; 

SELECT r.* 
FROM bronze.reviews_raw r
LEFT JOIN bronze.customers_raw c ON r.cust_id = c.cust_id
WHERE c.cust_id IS NULL; 

-- Data Standardization & Consistency
SELECT DISTINCT  rating FROM bronze.reviews_raw;
SELECT DISTINCT  review_text FROM bronze.reviews_raw;

-- Check Invalid Date, review date must > order date
SELECT r.order_id, min_review_date, order_date
FROM (SELECT order_id, MIN(review_date) AS min_review_date
FROM bronze.reviews_raw GROUP BY order_id) r
LEFT JOIN bronze.orders_raw o ON r.order_id = o.order_id
WHERE min_review_date < order_date
