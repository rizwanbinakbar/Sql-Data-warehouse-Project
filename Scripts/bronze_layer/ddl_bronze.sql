
/*
===============================================
DDL Script: Create Bronze layer Tables
===============================================
Script Purpose:
  This SQL script creates the table in the bronze layer, dropping exixting tables 
  if they already exist.
  Run this script to re-define the tables.
===============================================
 */

CREATE DATABASE datawarehouse;

USE datawarehouse;

-- ------------ Bronze Layer 1st table (CRM) -------------- 
DROP TABLE IF EXISTS b_crm_cust_info;
CREATE TABLE b_crm_cust_info 
(
	cst_id INT,
	cst_key VARCHAR(50),
	cst_firstname VARCHAR(50),
	cst_lastname VARCHAR(50),
	cst_marital_status VARCHAR(50),
	cst_gndr VARCHAR(50),
	cst_create_date VARCHAR(50)
);

-- ------------ Bronze Layer 2nd table (CRM) -------------- 
DROP TABLE IF EXISTS b_crm_prd_info;
CREATE TABLE b_crm_prd_info 
(
prd_id INT,
prd_key VARCHAR (50),
prd_nm VARCHAR(50),
prd_cost INT NULL,
prd_line VARCHAR(50),
prd_start_dt DATE,
prd_end_dt DATE
);

-- ------------ Bronze Layer 3rd table (CRM) -------------- 
DROP TABLE IF EXISTS b_crm_sales_details;
CREATE TABLE b_crm_sales_details
(
sls_ord_num VARCHAR(50),
sls_prd_key VARCHAR(50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt VARCHAR(50),
sls_due_dt VARCHAR(50),
sls_sales INT,
sls_quantity INT,
sls_price INT NULL
);


-- ------------ Bronze Layer 4th table (ERP) -------------- 
DROP TABLE IF EXISTS b_erp_cust_az12;
CREATE TABLE b_erp_cust_az12
(
cid VARCHAR(50),
bdate DATE,
gen VARCHAR(50) NULL
);

-- ------------ Bronze Layer 5th table (ERP) -------------- 
DROP TABLE IF EXISTS b_erp_loc_a101;
CREATE TABLE b_erp_loc_a101
(
cid VARCHAR(50),
cntry VARCHAR(50)
);

-- ------------ Bronze Layer 6th table (ERP) -------------
DROP TABLE IF EXISTS b_erp_px_cat_g1v2;
CREATE TABLE b_erp_px_cat_g1v2
(
id VARCHAR(50),
cat VARCHAR(50),
subcat VARCHAR(50),
maintenance VARCHAR(50)
);
