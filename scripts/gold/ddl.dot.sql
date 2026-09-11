IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customer AS 
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_key) AS Customer_Number_key,
	ci.cst_id AS Customer_id,
	ci.cst_key AS Customer_Number,
	ci.cst_firstname AS First_Name,
	ci.cst_lastname AS Last_Name,
	la.cntry AS Country, 
	ci.cst_marital_status AS Maritial_Status,
	CASE WHEN  ci.cst_gndr != 'Unknown' THEN ci.cst_gndr -- CRM IS THE MASTER TABLE for gender info 
		ELSE COALESCE(ca.gen,  'Unknown')
	END AS Gender, 
	ca.bdate AS Birth_Date,
	ci.cst_create_date AS Create_Date
FROM silver.crm_cust_info as ci
LEFT JOIN silver.erp_cust_az12 as ca 
ON ci.cst_key = ca.cid 
LEFT JOIN silver.erp_loc_a101 as la
ON ci.cst_key = la.cid
GO




IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold_dim_product AS 
SELECT
    ROW_NUMBER() OVER( ORDER BY  pn.prd_start_dt,pn.prd_key ) AS Product_key, 
    pn.prd_id AS Product_id,
    pn.prd_key AS Product_Number,
    pn.prd_nm AS Product_Name,
    pn.cat_id AS Category_id,
    pc.cat AS Category,
    pc.subcat AS Subcategory,
    pc.maintenance AS Maintenance, 
    pn.prd_cost AS Product_cost,
    pn.prd_line AS Product_Line,
    pn.prd_start_dt AS Start_Date 
FROM silver.crm_prd_info as pn
LEFT JOIN silver.erp_px_cat_g1v2 as pc 
ON pn.cat_id = pc.id 
WHERE prd_end_dt IS NULL -- FILTER OUT HISTORICAL DATA 
GO


IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS 
SELECT
    sd.sls_ord_num AS Order_Number,
    pr.Product_key,
    cu.Customer_Number_key,
    sd.sls_order_dt AS Order_Date,
    sd.sls_ship_dt AS Shipping_Date,
    sd.sls_due_dt AS Due_Date,
    sd.sls_sales AS Sales_Amount,
    sd.sls_quantity AS Sales_Quantity,
    sd.sls_price AS Price
FROM silver.crm_sales_details sd
LEFT JOIN gold_dim_product pr
ON sd.sls_prd_key = pr.product_Number 
LEFT JOIN gold.dim_customer cu
ON sd.sls_cust_id = cu.customer_id  
GO
