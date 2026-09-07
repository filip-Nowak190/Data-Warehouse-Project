/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script initializes the tables within the 'bronze' schema, dropping any 
    pre-existing tables if they already exist.
    Execute this script to reset and re-define the DDL structure of the 'bronze' tables.
===============================================================================
*/


IF OBJECT_ID ('bronze.crm_cust_info' , 'U') IS NOT NULL 
	DROP TABLE bronze.crm_cust_info;
GO

Create table bronze.crm_cust_info (
cst_id INT ,
cst_key NVARCHAR (60),
cst_firstname NVARCHAR (60),
cst_marital_status NVARCHAR (60),
cst_gndr NVARCHAR (60),
cst_create_date DATE
);
GO

IF OBJECT_ID ('bronze.crm_prd_info' , 'U') IS NOT NULL 
	DROP TABLE bronze.crm_prd_info;
GO

Create table bronze.crm_prd_info (
prd_id INT, 
prd_key NVARCHAR (60),
prd_nm NVARCHAR (60),
prd_cost INT,
prd_line NVARCHAR (60),
prd_start_dt DATETIME,
prd_end_dt DATETIME
);
GO

IF OBJECT_ID ('bronze.crm_sales_details' , 'U') IS NOT NULL 
	DROP TABLE bronze.crm_sales_details;
GO
Create table bronze.crm_sales_details (
sls_ord_num NVARCHAR (60),
sls_prd_key NVARCHAR (60),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,
sls_quantity INT,
sls_price INT 
);
GO

IF OBJECT_ID ('bronze.erp_cust_az12' , 'U') IS NOT NULL 
	DROP TABLE bronze.erp_cust_az12;
GO

Create table bronze.erp_cust_az12 (
Cid NVARCHAR (60),
BDate Date,
Gen NVARCHAR (60)
);
GO

IF OBJECT_ID ('bronze.erp_loc_a101' , 'U') IS NOT NULL 
	DROP TABLE bronze.erp_loc_a101;
GO

Create table bronze.erp_loc_a101 (
Cid NVARCHAR (60),
cntry NVARCHAR (60)
);

GO

IF OBJECT_ID ('bronze.erp_px_cat_g1v2' , 'U') IS NOT NULL 
	DROP TABLE bronze.erp_px_cat_g1v2;
GO

Create table bronze.erp_px_cat_g1v2 (
ID NVARCHAR (60),
cat NVARCHAR (60),
subcat NVARCHAR (60),
maintence NVARCHAR (60)
);
GO
