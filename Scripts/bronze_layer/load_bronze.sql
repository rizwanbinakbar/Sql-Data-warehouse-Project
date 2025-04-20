/*
====================================
Load data in Bronze layer

Script Purpose:
  This scripts loads the data from two different sources (CRM) & (ERP) as-is
  -It truncates the already existing blank tables and loads them with the data.
  -Uses LOAD DATA INFILE to load data into the tables as-is
*/

-- ------ LOADING THE DATA AS-IS -- ------


-- ------------ Bronze Layer 1st table (CRM) -------------- 
SELECT '=====================================================';
SELECT 'Loading Bronze layer';
SELECT '=====================================================';

TRUNCATE TABLE b_crm_cust_info;
LOAD DATA INFILE 'D:\\DE\\My SQL-DataWarehouse-Project\\datasets\\source_crm\\cust_info.csv'
INTO TABLE b_crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ------------ Bronze Layer 2nd table (CRM) ------------

TRUNCATE TABLE b_crm_prd_info;
LOAD DATA INFILE 'D:\\DE\\My SQL-DataWarehouse-Project\\datasets\\source_crm\\prd_info.csv'
INTO TABLE b_crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@prd_id, @prd_key, @prd_nm, @prd_cost, @prd_line, @prd_start_dt, @prd_end_dt)
SET
    prd_id = @prd_id,
    prd_key = @prd_key,
    prd_nm = @prd_nm,
    prd_cost = NULLIF(@prd_cost, ''),
    prd_line = @prd_line,
    prd_start_dt = NULLIF(@prd_start_dt, ''),
    prd_end_dt = NULLIF(@prd_end_dt, '');

-- ------------ Bronze Layer 3rd table (CRM) -------------- 

TRUNCATE TABLE b_crm_sales_details;
LOAD DATA INFILE 'D:\\DE\\My SQL-DataWarehouse-Project\\datasets\\source_crm\\sales_details.csv'
INTO TABLE b_crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ------------ Bronze Layer 4th table (ERP) -------------- 

TRUNCATE TABLE b_erp_cust_az12;
LOAD DATA INFILE 'D:\\DE\\My SQL-DataWarehouse-Project\\datasets\\source_erp\\CUST_AZ12.csv'
INTO TABLE b_erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(cid, bdate, gen)
SET 
	gen = NULLIF(gen, '');


-- ------------ Bronze Layer 5th table (ERP) -------------- 
TRUNCATE TABLE b_erp_loc_a101;
LOAD DATA INFILE 'D:\\DE\\My SQL-DataWarehouse-Project\\datasets\\source_erp\\LOC_A101.csv'
INTO TABLE b_erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ------------ Bronze Layer 6th table (ERP) -------------- 
TRUNCATE TABLE b_erp_px_cat_g1v2;
LOAD DATA INFILE 'D:\\DE\\My SQL-DataWarehouse-Project\\datasets\\source_erp\\PX_CAT_G1V2.csv'
INTO TABLE b_erp_px_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
