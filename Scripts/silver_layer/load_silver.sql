/*
============================================
Load Script: Silver tables
============================================
Script purpose:
  This script has stored procedure that 
  performs ETL (extract, transform & load)
  to populate the silver layer tables.
Action performed:
  This truncates table 
  Then load them with cleaned, transformed
  data.
*/


CALL silver_layer_full_load(); 

DELIMITER $$

CREATE PROCEDURE silver_layer_full_load()
BEGIN

	-- Transforming & then inserting clean data into (s_crm_cust_info) Silver Layer 
	SELECT 'Truncating table: s_crm_cust_info';
	TRUNCATE TABLE s_crm_cust_info;
	SELECT '>> Inserting data into: s_crm_cust_info';
	INSERT INTO s_crm_cust_info
	(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
	)
	SELECT 
		cst_id, 
		cst_key,
		TRIM(cst_firstname) AS cst_firstname, -- Removed unwanted spaces
		TRIM(cst_lastname) AS cst_lastname,   -- Removed unwanted spaces
	CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'  -- Normalized marital status into a more readable format
		 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married' -- Normalized marital status into a more readable format
		 ELSE 'N/A'
	END cst_marital_status,
	CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' -- Normalized gender status into a more readable format
		 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'   -- Normalized gender status into a more readable format
		 ELSE 'N/A'
	END cst_gndr,
		cst_create_date
	FROM
		(SELECT 
		*,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date) as flag_test
		FROM b_crm_cust_info) as f
		WHERE flag_test = 1; -- Select the most recent records
	-- SELECT * FROM s_crm_cust_info;

	SELECT 'Completed ';

	-- ================================================================================

	-- Transforming & then inserting clean data into (s_crm_prd_info) Silver Layer

	-- ================================================================================

	SELECT 'Truncating table: s_crm_prd_info';
	TRUNCATE TABLE s_crm_prd_info;
	SELECT '>> Inserting data into: s_crm_prd_info';
	INSERT INTO s_crm_prd_info
	(
		prd_id, 
		cat_id, 
		prd_key, 
		prd_nm, 
		prd_cost, 
		prd_line, 
		prd_start_dt, 
		prd_end_dt
	)
	SELECT 
		prd_id,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extracting Category id
		SUBSTRING(prd_key, 7, LENGTH(prd_key)) as prd_key, 	   -- Extracting Product id
		prd_nm,
		prd_cost,
		CASE TRIM(UPPER(prd_line)) 
			 WHEN 'R' THEN 'Road'
			 WHEN 'S' THEN 'Other Sales'
			 WHEN 'M' THEN 'Mountain'
			 WHEN 'T' THEN 'Touring'
			 ELSE 'N/A'
		END AS prd_line, -- Map product line codes to descriptive values
		prd_start_dt,
		DATE_SUB(
		LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), INTERVAL 1 DAY)
		AS prd_end_dt -- Calculate end date as 1 daye before the next start date
	FROM b_crm_prd_info;

	-- SELECT * FROM s_crm_prd_info;

	SELECT 'Completed ';

	-- ================================================================================

	-- Transforming & then inserting clean data into (s_crm_sales_detils) Silver Layer

	-- ================================================================================
	SELECT 'Truncating table: s_crm_sales_detils';
	TRUNCATE TABLE s_crm_sales_details;
	SELECT '>> Inserting data into: s_crm_sales_detils';
	INSERT INTO s_crm_sales_details 
	(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)
	SELECT 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,

	CASE WHEN sls_order_dt < 0 OR LENGTH(sls_order_dt) != 8 THEN NULL 
		 ELSE CAST(sls_order_dt AS DATE)	
	END sls_order_dt,

	CASE WHEN sls_ship_dt < 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL 
		 ELSE CAST(sls_ship_dt AS DATE)
	END sls_ship_dt,

	CASE WHEN sls_due_dt < 0 OR LENGTH(sls_due_dt) != 8 THEN NULL 
		 ELSE CAST(sls_due_dt AS DATE)
	END sls_due_dt,

	CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
		 THEN ABS(sls_price) * sls_quantity -- Dealt with invalid prices
		 ELSE sls_sales
	END sls_sales, 

		sls_quantity,

	CASE WHEN sls_price IS NULL OR sls_price <=0
		 THEN sls_sales * sls_quantity
		 ELSE sls_price
	END sls_price
	FROM b_crm_sales_details;

	-- SELECT * FROM s_crm_sales_details;

	SELECT 'Completed ';

	-- ================================================================================

	-- Transforming & then inserting clean data into (s_erp_cust_az12) Silver Layer

	-- ================================================================================
	SELECT 'Truncating table: s_erp_cust_az12';
	TRUNCATE TABLE s_erp_cust_az12;
	SELECT '>> Inserting data into: s_erp_cust_az12';
	INSERT INTO s_erp_cust_az12
	(
	cid, 
	bdate,
	gen
	)
	SELECT

	CASE 
		 WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
		 ELSE cid
	END cid,

	CASE 
		 WHEN CAST(bdate AS DATE) > NOW() THEN NULL -- Dealt with invalid dates
		 ELSE bdate
	END bdate,
	CASE 
		WHEN UPPER(TRIM(gen)) LIKE 'M%' OR UPPER(TRIM(gen)) LIKE 'MALE%' THEN 'Male' -- More readable form
		WHEN UPPER(TRIM(gen)) LIKE 'F%' OR UPPER(TRIM(gen)) LIKE 'FEMALE%' THEN 'Female' -- Removed unwanted spaces
		ELSE 'N/A'
	END AS gen
	FROM b_erp_cust_az12;

	-- SELECT * FROM s_erp_cust_az12;

	SELECT 'Completed ';
	-- ================================================================================

	-- Transforming & then inserting clean data into (s_erp_loc_a101) Silver Layer

	-- ================================================================================
	SELECT 'Truncating table: s_erp_loc_a101';
	TRUNCATE TABLE s_erp_loc_a101;
	SELECT '>> Inserting data into: s_erp_loc_a101';
	INSERT INTO s_erp_loc_a101
	(
	cid,
	cntry
	)
	SELECT 
	REPLACE (cid, '-', '') AS cid,
	CASE 
		WHEN UPPER(TRIM(cntry)) LIKE 'DE%' THEN 'Germany'
		WHEN UPPER(TRIM(cntry)) LIKE 'US%' OR UPPER(TRIM(cntry)) LIKE 'USA%' THEN 'United States'
		WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
		ELSE SUBSTRING_INDEX(TRIM(cntry), CHAR(13), 1) -- Remove everything after carriage return
	END AS cntry
	FROM b_erp_loc_a101;

	-- SELECT * FROM s_erp_loc_a101;

	SELECT 'Completed ';

	-- ================================================================================

	-- Transforming & then inserting clean data into (s_erp_px_cat_g1v2) Silver Layer

	-- ================================================================================
	SELECT 'Truncating table: s_erp_px_cat_g1v2';
	TRUNCATE TABLE s_erp_px_cat_g1v2;
	SELECT '>> Inserting data into: s_erp_px_cat_g1v2';
	INSERT INTO s_erp_px_cat_g1v2
	(
	id,
	cat,
	subcat,
	maintenance
	)
	SELECT 		-- NO changes needed 
	id,   
	cat,
	subcat,
	maintenance
	FROM b_erp_px_cat_g1v2;

	SELECT 'Completed ';
	SELECT 'Total data ingestion COMPLETED';

END $$

DELIMITER ;
