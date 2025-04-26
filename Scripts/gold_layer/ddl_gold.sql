/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/


-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
CREATE VIEW g_dim_customers AS
	SELECT
		ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, 
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_number,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		la.cntry AS country,
		CASE WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr -- CRM is the Master table
			 ELSE COALESCE(ca.gen, 'N/A')
		END AS gender,
		ci.cst_marital_status AS marital_status,
		ca.bdate AS birth_date,
		ci.cst_create_date AS create_date
	FROM s_crm_cust_info AS ci
	LEFT JOIN s_erp_cust_az12 AS ca
		ON ci.cst_key = ca.cid
	LEFT JOIN s_erp_loc_a101 la
		ON ci.cst_key = la.cid;
        
SELECT * FROM g_dim_customers;

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
CREATE VIEW g_dim_products AS 
SELECT 
	ROW_NUMBER() OVER(ORDER BY pa.prd_start_dt,pa.prd_key) AS product_key,
	pa.prd_id AS product_id,
    pa.prd_key AS product_number,
    pa.prd_nm AS product_name,
	pa.cat_id AS category_id,
	ea.cat AS category,
	ea.subcat AS sub_category,
    ea.maintenance,
	pa.prd_line AS product_ine,
	pa.prd_cost AS cost,
	pa.prd_start_dt AS start_date
FROM s_crm_prd_info AS pa
LEFT JOIN s_erp_px_cat_g1v2 AS ea
ON pa.cat_id = ea.id
WHERE pa.prd_end_dt IS NULL; -- Filter out all historical data

SELECT * FROM g_dim_products;

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
CREATE VIEW g_fact_sales AS 
SELECT
	sd.sls_ord_num AS order_number,
	cr.customer_key,
	pr.product_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM s_crm_sales_details sd
LEFT JOIN g_dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN g_dim_customers cr
ON sd.sls_cust_id = cr.customer_id;


