/*
======================================================
Quality Check + EDA script: Silver Layer tables
======================================================
Script purpose:
  This script checks the uality of data by performing 
  various operations & EDA.
======================================================
*/


-- Checking for Nulls or duplicates in Primary key
-- Expectation: No result

SELECT 
cst_id, COUNT(*) 
FROM s_crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

SELECT 
*
FROM 
(SELECT
*, 
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_test
FROM s_crm_cust_info) as f
WHERE flag_test !=1;

-- Check for unwanted spaces
-- Expectation: No Results

SELECT cst_gndr
FROM s_crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Data Standardization & Consistency
SELECT 
DISTINCT cst_gndr
FROM s_crm_cust_info;

SELECT 
DISTINCT cst_marital_status
FROM s_crm_cust_info;

SELECT cst_marital_status 
FROM s_crm_cust_info
WHERE cst_marital_status = '';

-- Checking for Nulls or duplicates in Primary key
-- Expectation: No result

SELECT * FROM b_crm_prd_info;
DESCRIBE b_crm_prd_info;

SELECT 
COUNT(*), prd_key
FROM b_crm_prd_info
GROUP BY prd_key
HAVING COUNT(*) >1 OR prd_key IS NULL;

SELECT 
COUNT(*), prd_end_dt
FROM b_crm_prd_info
GROUP BY prd_end_dt
HAVING prd_end_dt IS NULL;

-- Checking for unwanted spaces

SELECT 
prd_nm
FROM s_crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Checking for NULL values
-- Expextations: No result
SELECT 
prd_cost
FROM s_crm_prd_info
WHERE prd_cost is NULL OR prd_cost =0 OR prd_cost <0;

SELECT 
DISTINCT(prd_line)
FROM s_crm_prd_info;

SELECT *
FROM s_crm_prd_info
WHERE prd_start_dt > prd_end_dt;

SELECT 
prd_end_dt
FROM s_crm_prd_info 
WHERE prd_end_dt IS NULL;

SELECT 
prd_id,
prd_key,
prd_nm,
prd_start_dt,
prd_end_dt,
DATE_SUB(
LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt),
INTERVAL 1 DAY)
AS prd_end_test
FROM s_crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R','AC-HE-HL-U509');

-- Checking slaes details column
SELECT * FROM b_crm_sales_details;

-- Checking for invalid dates
SELECT 
NULLIF(sls_order_dt, 0) sls_order_dt
FROM b_crm_sales_details
WHERE sls_order_dt <=0 OR LENGTH(sls_order_dt) != 8;

-- Check for NULL values
SELECT sls_sales
FROM b_crm_sales_details
WHERE sls_price IS NULL;

-- Check for Incorrect Dates
SELECT * 
FROM b_crm_sales_details
WHERE sls_order_dt > sls_due_dt OR sls_order_dt > sls_due_dt;

-- Check for Invalid sales price

SELECT DISTINCT
sls_sales,
sls_quantity,
CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != ABS(sls_price) * sls_quantity
	 THEN sls_price * sls_quantity
     ELSE sls_sales
END sls_sales
FROM s_crm_sales_details
WHERE sls_sales != sls_price * sls_quantity
OR sls_sales IS NULL OR sls_price IS NULL OR sls_quantity IS NULL
OR sls_sales <=0 OR sls_price <=0 OR sls_quantity <=0;

-- b_erp_cust_az12 EDA

SELECT * FROM b_erp_cust_az12;

-- Checking for NULL values
SELECT 
gen
FROM b_erp_cust_az12
WHERE gen IS NULL;

-- Check for unwanted spaces
SELECT 
cid,
gen,
bdate
FROM b_erp_cust_az12
WHERE gen != TRIM(gen);

SELECT 
bdate
FROM b_erp_cust_az12
WHERE bdate != TRIM(bdate);

-- Checking Distinct typoes of Gen
SELECT 
DISTINCT gen
FROM s_erp_cust_az12;

-- Identifying out-of-range Dates
SELECT 
bdate
FROM b_erp_cust_az12
WHERE bdate < 1924 OR bdate > NOW();


-- s_crm_prd_info

-- Check NULL values
SELECT * 
FROM b_erp_loc_a101
WHERE cntry IS NULL;

-- Different Countries
SELECT 
DISTINCT cntry
FROM b_erp_loc_a101;

-- Check for extra spaces
SELECT 
cntry as Old_cntry,

CASE 
    WHEN UPPER(TRIM(cntry)) LIKE 'DE%' THEN 'Germany'
    WHEN UPPER(TRIM(cntry)) LIKE 'US%' OR UPPER(TRIM(cntry)) LIKE 'USA%' THEN 'United States'
    WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
    ELSE SUBSTRING_INDEX(TRIM(cntry), CHAR(13), 1) -- Remove everything after carriage return
END AS country_name
FROM b_erp_loc_a101;


-- b_erp_px_cat_g1v2

SELECT * FROM b_erp_px_cat_g1v2

-- NO CLEANING NEEDED

