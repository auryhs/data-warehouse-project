/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN 
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY 
		SET @batch_start_time = GETDATE(); 
		PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';
			
		-- Loading silver.customers_raw
		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.customers_raw';
		TRUNCATE TABLE silver.customers_raw;
		PRINT '>> Inserting Data Into: silver.customers_raw';

		INSERT INTO silver.customers_raw(cust_id, full_name, city, gender, registered_date, segment)
		SELECT c.cust_id, c.full_name, c.city, c.gender,
		-- when customer registered date > first order date, then registered date = first order date 
			CASE WHEN DATEDIFF(day, c.registered_date, cust_order.[First Order Date]) < 0 
				THEN cust_order.[First Order Date] 
				ELSE c.registered_date 
				END AS 'registered_date', c.segment
			FROM bronze.customers_raw  AS c
			LEFT JOIN (SELECT cust_id, MIN(order_date) AS 'First Order Date'
			FROM bronze.orders_raw
			GROUP BY cust_id) cust_order ON c.cust_id = cust_order.cust_id;
		SET @end_time=GETDATE()

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.products_raw
		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.products_raw';
		TRUNCATE TABLE silver.products_raw;
		PRINT '>> Inserting Data Into: silver.products_raw';

		INSERT INTO silver.products_raw(prod_id, prod_name, category, unit_price, brand, supplier)
		SELECT prod_id, prod_name, category, unit_price, brand, supplier FROM bronze.products_raw;
		SET @end_time=GETDATE()

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.campaigns_raw
		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.campaigns_raw';
		TRUNCATE TABLE silver.campaigns_raw;
		PRINT '>> Inserting Data Into: silver.campaigns_raw';

		INSERT INTO silver.campaigns_raw(campaign_id, campaign_name, start_date, end_date, channel)
		SELECT campaign_id, campaign_name, start_date, end_date, channel FROM bronze.campaigns_raw;
		SET @end_time=GETDATE()

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.orders_raw
		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.orders_raw';
		TRUNCATE TABLE silver.orders_raw;
		PRINT '>> Inserting Data Into: silver.orders_raw';

		INSERT INTO silver.orders_raw(order_id, cust_id, order_date, payment_type, order_status, campaign_id)
		SELECT o.order_id, cust_id, order_date, payment_type, order_status, 
		-- If an order has a campaign_id but the order_date is outside the campaign period, then set campaign_id to NULL
			CASE WHEN invalid_campaign.[order_id] IS NOT NULL THEN NULL 
			ELSE o.campaign_id 
			END AS campaign_id
		FROM bronze.orders_raw o 
		LEFT JOIN (SELECT o.order_id AS order_id
		FROM bronze.orders_raw o
			LEFT JOIN bronze.campaigns_raw c ON 
			o.campaign_id = c.campaign_id
			WHERE NOT(o.order_date>=c.start_date AND o.order_date<=c.end_date)) invalid_campaign 
			ON o.order_id = invalid_campaign.[order_id];
		SET @end_time=GETDATE()

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.order_items_raw
		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.order_items_raw';
		TRUNCATE TABLE silver.order_items_raw;
		PRINT '>> Inserting Data Into: silver.order_items_raw';

		INSERT INTO silver.order_items_raw( order_id, prod_id, qty, unit_price, discount_pct, subtotal)
		SELECT order_id, prod_id, qty, unit_price, discount_pct, subtotal FROM bronze.order_items_raw;
		SET @end_time=GETDATE()

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.shipping_raw
		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.shipping_raw';
		TRUNCATE TABLE silver.shipping_raw;
		PRINT '>> Inserting Data Into: silver.shipping_raw';

		INSERT INTO silver.shipping_raw( order_id, ship_date, shipping_provider, shipping_fee, shipping_status)
		SELECT s.order_id, 
		-- if ship date < order date, then ship date = order date
			CASE WHEN invalid_date.order_id IS NOT NULL 
			THEN invalid_date.order_date 
			ELSE ship_date END AS ship_date, 
		shipping_provider, shipping_fee, shipping_status
		FROM bronze.shipping_raw s
		LEFT JOIN (
		SELECT s.order_id, o.order_date FROM 
		bronze.shipping_raw s
		LEFT JOIN bronze.orders_raw o ON 
		s.order_id = o.order_id
		WHERE s.ship_date < o.order_date
		) invalid_date ON invalid_date.order_id = s.order_id;
		SET @end_time=GETDATE()

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.reviews_raw
		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.reviews_raw';
		TRUNCATE TABLE silver.reviews_raw;
		PRINT '>> Inserting Data Into: silver.reviews_raw';

		INSERT INTO silver.reviews_raw( review_id, order_id, prod_id, cust_id, rating, review_text, review_date)
		SELECT review_id, r.order_id, prod_id, cust_id, rating, review_text, 
		-- if review date < order date then review date = order date
		CASE WHEN invalid_date.order_id IS NOT NULL THEN order_date 
		ELSE review_date 
		END AS review_date
		FROM bronze.reviews_raw r
		LEFT JOIN (SELECT r.order_id, min_review_date, order_date
		FROM (SELECT order_id, MIN(review_date) AS min_review_date
		FROM bronze.reviews_raw GROUP BY order_id) r
		LEFT JOIN bronze.orders_raw o ON r.order_id = o.order_id
		WHERE min_review_date < order_date
		) invalid_date ON r.order_id = invalid_date.order_id;
		SET @end_time=GETDATE()

		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		SET @batch_end_time = GETDATE()
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END