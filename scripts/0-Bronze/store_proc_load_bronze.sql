/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN 
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY 
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '================================================';

		-- customers_raw
		SET @start_time = GETDATE()
		TRUNCATE TABLE bronze.customers_raw;
		PRINT '>> Inserting Data Into: bronze.customers_raw';
		BULK INSERT bronze.customers_raw
		FROM '<<insert path to customers_raw files>>'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		-- products_raw
		SET @start_time = GETDATE()
		TRUNCATE TABLE bronze.products_raw;
		PRINT '>> Inserting Data Into: bronze.products_raw';
		BULK INSERT bronze.products_raw
		FROM '<<insert path to products_raw files>>'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		-- campaigns_raw
		SET @start_time = GETDATE()
		TRUNCATE TABLE bronze.campaigns_raw;
		PRINT '>> Inserting Data Into: bronze.campaigns_raw';
		BULK INSERT bronze.campaigns_raw
		FROM '<<insert path to campaigns_raw files>>'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		-- orders_raw
		SET @start_time = GETDATE()
		TRUNCATE TABLE bronze.orders_raw;
		PRINT '>> Inserting Data Into: bronze.orders_raw';
		BULK INSERT bronze.orders_raw
		FROM '<<insert path to orders_raw files>>'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		-- order_items_raw
		SET @start_time = GETDATE()
		TRUNCATE TABLE bronze.order_items_raw;
		PRINT '>> Inserting Data Into: bronze.order_items_raw';
		BULK INSERT bronze.order_items_raw
		FROM '<<insert path to order_items_raw files>>'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		-- shipping_raw
		SET @start_time = GETDATE()
		TRUNCATE TABLE bronze.shipping_raw;
		PRINT '>> Inserting Data Into: bronze.shipping_raw';
		BULK INSERT bronze.shipping_raw
		FROM '<<insert path to shipping_raw files>>'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		-- reviews_raw
		SET @start_time = GETDATE()
		TRUNCATE TABLE bronze.reviews_raw;
		PRINT '>> Inserting Data Into: bronze.reviews_raw';
		BULK INSERT bronze.reviews_raw
		FROM '<<insert path to reviews_raw files>>'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @batch_end_time = GETDATE() 
		PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed';
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