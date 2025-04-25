/*
===============================================
DDL Script: Create Silver layer tables
===============================================
Script purpose: 
  This script create tables for the silver layer,
  dropping if they already exist.
  Run the script to re-define the DDL structure 
  of silver layer
===============================================
*/
-- SELECT * FROM b_crm_cust_info;
-- SELECT * FROM b_crm_prd_info;
-- SELECT * FROM b_crm_sales_details;
-- SELECT * FROM b_erp_cust_az12;
-- SELECT * FROM b_erp_loc_a101;
-- SELECT * FROM b_erp_px_cat_g1v2;



-- ------------ Silver Layer 1st table (CRM) -------------- 
DROP TABLE IF EXISTS s_crm_cust_info;
CREATE TABLE s_crm_cust_info 
(
	cst_id INT,
	cst_key VARCHAR(50),
	cst_firstname VARCHAR(50),
	cst_lastname VARCHAR(50),
	cst_marital_status VARCHAR(50),
	cst_gndr VARCHAR(50),
	cst_create_date VARCHAR(50),
    dwh_create_date DATETIME DEFAULT NOW()
);

-- ------------ Silver Layer 2nd table (CRM) -------------- 
DROP TABLE IF EXISTS s_crm_prd_info;
CREATE TABLE s_crm_prd_info 
(
	prd_id INT,
    cat_id VARCHAR(50),
	prd_key VARCHAR (50),
	prd_nm VARCHAR(50),
	prd_cost INT NULL,
	prd_line VARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
    dwh_create_date DATETIME DEFAULT NOW()
);

-- ------------ Silver Layer 3rd table (CRM) -------------- 
DROP TABLE IF EXISTS s_crm_sales_details;
CREATE TABLE s_crm_sales_details
(
	sls_ord_num VARCHAR(50),
	sls_prd_key VARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
    dwh_create_date DATETIME DEFAULT NOW()
);


-- ------------ Silver Layer 4th table (ERP) -------------- 
DROP TABLE IF EXISTS s_erp_cust_az12;
CREATE TABLE s_erp_cust_az12
(
	cid VARCHAR(50),
	bdate DATE,
	gen VARCHAR(50) NULL,
    dwh_create_date DATETIME DEFAULT NOW()
);

-- ------------ Silver Layer 5th table (ERP) -------------- 
DROP TABLE IF EXISTS s_erp_loc_a101;
CREATE TABLE s_erp_loc_a101
(
	cid VARCHAR(50),
	cntry VARCHAR(50),
    dwh_create_date DATETIME DEFAULT NOW()
);

-- ------------ Silver Layer 6th table (ERP) -------------
DROP TABLE IF EXISTS s_erp_px_cat_g1v2;
CREATE TABLE s_erp_px_cat_g1v2
(
	id VARCHAR(50),
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(50),
    dwh_create_date DATETIME DEFAULT NOW()
);
