/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/


IF OBJECT_ID('bronze.customers_raw','U') IS NOT NULL 
	DROP TABLE bronze.customers_raw;
GO
CREATE TABLE bronze.customers_raw(
	cust_id INT, 
	full_name NVARCHAR(50), 
	city NVARCHAR(50), 
	gender NVARCHAR(50), 
	registered_date DATE, 
	segment NVARCHAR(50)
);
--
IF OBJECT_ID('bronze.products_raw','U') IS NOT NULL 
	DROP TABLE bronze.products_raw;
GO
CREATE TABLE bronze.products_raw(
	prod_id INT, 
	prod_name NVARCHAR(50), 
	category NVARCHAR(50), 
	unit_price FLOAT, 
	brand NVARCHAR(50), 
	supplier NVARCHAR(50)
);
-- 
IF OBJECT_ID('bronze.campaigns_raw','U') IS NOT NULL 
	DROP TABLE bronze.campaigns_raw;
GO
CREATE TABLE bronze.campaigns_raw(
	campaign_id  INT, 
	campaign_name NVARCHAR(50), 
	start_date DATE,
	end_date DATE, 
	channel NVARCHAR(50)
);
--
IF OBJECT_ID('bronze.orders_raw','U') IS NOT NULL 
	DROP TABLE bronze.orders_raw;
GO
CREATE TABLE bronze.orders_raw(
	order_id INT, 
	cust_id INT,
	order_date DATE, 
	payment_type NVARCHAR(50), 
	order_status NVARCHAR(50), 
	campaign_id INT
);
--
IF OBJECT_ID('bronze.order_items_raw','U') IS NOT NULL 
	DROP TABLE bronze.order_items_raw;
GO
CREATE TABLE bronze.order_items_raw(
	order_id INT, 
	prod_id INT,
	qty INT, 
	unit_price FLOAT, 
	discount_pct FLOAT, 
	subtotal FLOAT
);
--
IF OBJECT_ID('bronze.shipping_raw','U') IS NOT NULL 
	DROP TABLE bronze.shipping_raw;
GO
CREATE TABLE bronze.shipping_raw(
	order_id INT, 
	ship_date DATE, 
	shipping_provider NVARCHAR(50), 
	shipping_fee FLOAT, 
	shipping_status NVARCHAR(50)
);
--
IF OBJECT_ID('bronze.reviews_raw','U') IS NOT NULL 
	DROP TABLE bronze.reviews_raw;
GO
CREATE TABLE bronze.reviews_raw(
	review_id INT, 
	order_id INT, 
	prod_id INT, 
	cust_id INT, 
	rating INT, 
	review_text NVARCHAR(50), 
	review_date DATE 
);




