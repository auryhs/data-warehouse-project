/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'silver' Tables
===============================================================================
*/

IF OBJECT_ID('silver.customers_raw','U') IS NOT NULL 
	DROP TABLE silver.customers_raw;
GO
CREATE TABLE silver.customers_raw(
	cust_id INT, 
	full_name NVARCHAR(50), 
	city NVARCHAR(50), 
	gender NVARCHAR(50), 
	registered_date DATE, 
	segment NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
--
IF OBJECT_ID('silver.products_raw','U') IS NOT NULL 
	DROP TABLE silver.products_raw;
GO
CREATE TABLE silver.products_raw(
	prod_id INT, 
	prod_name NVARCHAR(50), 
	category NVARCHAR(50), 
	unit_price FLOAT, 
	brand NVARCHAR(50), 
	supplier NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
-- 
IF OBJECT_ID('silver.campaigns_raw','U') IS NOT NULL 
	DROP TABLE silver.campaigns_raw;
GO
CREATE TABLE silver.campaigns_raw(
	campaign_id  INT, 
	campaign_name NVARCHAR(50), 
	start_date DATE,
	end_date DATE, 
	channel NVARCHAR(50), 
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
--
IF OBJECT_ID('silver.orders_raw','U') IS NOT NULL 
	DROP TABLE silver.orders_raw;
GO
CREATE TABLE silver.orders_raw(
	order_id INT, 
	cust_id INT,
	order_date DATE, 
	payment_type NVARCHAR(50), 
	order_status NVARCHAR(50), 
	campaign_id INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
--
IF OBJECT_ID('silver.order_items_raw','U') IS NOT NULL 
	DROP TABLE silver.order_items_raw;
GO
CREATE TABLE silver.order_items_raw(
	order_id INT, 
	prod_id INT,
	qty INT, 
	unit_price FLOAT, 
	discount_pct FLOAT, 
	subtotal FLOAT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
--
IF OBJECT_ID('silver.shipping_raw','U') IS NOT NULL 
	DROP TABLE silver.shipping_raw;
GO
CREATE TABLE silver.shipping_raw(
	order_id INT, 
	ship_date DATE, 
	shipping_provider NVARCHAR(50), 
	shipping_fee FLOAT, 
	shipping_status NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
--
IF OBJECT_ID('silver.reviews_raw','U') IS NOT NULL 
	DROP TABLE silver.reviews_raw;
GO
CREATE TABLE silver.reviews_raw(
	review_id INT, 
	order_id INT, 
	prod_id INT, 
	cust_id INT, 
	rating INT, 
	review_text NVARCHAR(50), 
	review_date DATE ,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);




