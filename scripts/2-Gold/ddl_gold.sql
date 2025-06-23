/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each DIM view selects and formats cleaned data, 
	while the FACT view combines and transforms data from multiple sources.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
	cust_id AS customer_id,
	full_name, 
	city,
	gender, 
	segment, 
	registered_date
FROM silver.customers_raw;
GO

-- =============================================================================
-- Create Dimension: gold.products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
	prod_id AS product_id,
	prod_name  AS product_name, 
	category,
	brand,
	supplier,
	unit_price
FROM silver.products_raw;
GO

-- =============================================================================
-- Create Dimension: gold.campaigns
-- =============================================================================
IF OBJECT_ID('gold.dim_campaigns', 'V') IS NOT NULL
    DROP VIEW gold.dim_campaigns;
GO

CREATE VIEW gold.dim_campaigns AS
SELECT 
	campaign_id, 
	campaign_name,
	channel,
	start_date,
	end_date
FROM silver.campaigns_raw;
GO

-- =============================================================================
-- Create Dimension: gold.shipping
-- =============================================================================
IF OBJECT_ID('gold.dim_shipping', 'V') IS NOT NULL
    DROP VIEW gold.dim_shipping;
GO

CREATE VIEW gold.dim_shipping AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY ship_date) AS shipping_key, 
	order_id, 
	ship_date AS shipping_date, 
	shipping_provider,
	shipping_fee,
	shipping_status
FROM silver.shipping_raw;
GO

-- =============================================================================
-- Create Dimension: gold.reviews
-- =============================================================================
IF OBJECT_ID('gold.dim_reviews', 'V') IS NOT NULL
    DROP VIEW gold.dim_reviews;
GO

CREATE VIEW gold.dim_reviews AS
SELECT 
	review_id, 
	order_id, 
	prod_id AS product_id, 
	cust_id AS customer_id, 
	rating,
	review_text, 
	review_date
FROM silver.reviews_raw;
GO

-- =============================================================================
-- Create Fact Table: gold.sales_order_items
-- =============================================================================
IF OBJECT_ID('gold.fact_sales_order_items', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales_order_items;
GO

CREATE VIEW gold.fact_sales_order_items AS
SELECT 
	-- ?? Order Info
	oi.order_id,
	o.order_date,
	o.payment_type,
	o.order_status,

	-- ??? Product Info
	p.product_id,
	p.product_name,
	p.category,
	p.brand,
	p.supplier,

	-- ?? Order Item & Pricing Info
	oi.qty AS quantity,
	oi.unit_price,
	oi.discount_pct AS discount_percentage,
	oi.subtotal,
	ROUND(s.shipping_fee / COUNT(prod_id) OVER (PARTITION BY oi.order_id), 2) AS shipping_fee,
	oi.subtotal + ROUND(s.shipping_fee / COUNT(prod_id) OVER (PARTITION BY oi.order_id), 2) AS subtotal_with_shipping,
	
	-- ?? Shipping Info
	s.shipping_date,
	s.shipping_provider,
	s.shipping_status,

	-- ?? Campaign Info
	cp.campaign_name,
	cp.channel,

	-- ? Review Info
	r.review_date,
	r.rating,
	r.review_text,

	-- ?? Customer Info
	c.customer_id,
	c.city,
	c.gender,
	c.segment
FROM silver.order_items_raw oi
LEFT JOIN silver.orders_raw o ON 
oi.order_id = o.order_id
LEFT JOIN gold.dim_products p ON p.product_id = oi.prod_id
LEFT JOIN gold.dim_shipping s ON o.order_id = s.order_id
LEFT JOIN gold.dim_campaigns cp ON o.campaign_id = cp.campaign_id 
LEFT JOIN gold.dim_customers c ON c.customer_id = o.cust_id
LEFT JOIN gold.dim_reviews r  ON r.order_id = oi.order_id 
 AND r.product_id = oi.prod_id
;
GO

