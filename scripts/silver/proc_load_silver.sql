CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    PRINT '>>>>>>>> Trucating Table: silver.crm_cust_info ';
    TRUNCATE TABLE silver.crm_cust_info;
    PRINT '>>>>>>>> Inserting Data Into: silver.crm_cust_info'
    INSERT INTO silver.crm_cust_info (
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
    trim(cst_firstname) as cst_firstname,
    trim(cst_lastname) as cst_lastname,
    CASE 
	     WHEN UPPER(trim(cst_marital_status)) = 'S' THEN 'Single'
	     WHEN UPPER(trim(cst_marital_status)) = 'M' THEN 'Married'
	     ELSE 'Unknown'
    END cst_marital_status, -- Standardize marital status values for better readability
    CASE 
	     WHEN UPPER(trim(cst_gndr)) = 'F' THEN 'Female'
	     WHEN UPPER(trim(cst_gndr)) = 'M' THEN 'Male'
	     ELSE 'Unknown'
    END cst_gndr,  -- Standardize gender values for better readability 
    cst_create_date
    FROM (
	    select 
	    *,
	    ROW_NUMBER() over (PARTITION BY cst_id ORDER BY cst_create_date desc ) as flag_number
	    from bronze.crm_cust_info 
	    WHERE cst_id IS NOT NULL 
    ) t 
    WHERE flag_number = 1  -- Select the most recent record per customer 

    PRINT '>>>>>>>> Trucating Table: silver.crm_prd_info ';
    TRUNCATE TABLE silver.crm_prd_info;
    PRINT '>>>>>>>> Inserting Data Into: silver.crm_prd_info' 
    INSERT INTO silver.crm_prd_info (
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
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extract category ID
        SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,        -- Extract product key
        prd_nm,
        ISNULL(prd_cost, 0) AS prd_cost,
        CASE UPPER(TRIM(prd_line))
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'T' THEN 'Touring'
            ELSE 'Unknown'
        END AS prd_line,  -- Map product line codes to descriptive values
        CAST(prd_start_dt AS DATE) AS prd_start_dt,
        CAST
        (LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) 
        AS prd_end_dt  -- Calculate end date as one day before the next start date 
    FROM bronze.crm_prd_info

    PRINT '>>>>>>>> Trucating Table: silver.crm_sales_details  ';
    TRUNCATE TABLE silver.crm_sales_details ;
    PRINT '>>>>>>>> Inserting Data Into: silver.crm_sales_details' 
    insert into silver.crm_sales_details (
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
        CASE 
            WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL 
            ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
            END AS sls_order_dt, 
        CASE 
            WHEN  sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL 
            ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
            END AS sls_ship_dt, 
        CASE 
            WHEN  sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL 
            ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
            END AS sls_due_dt,
         Case 
            When sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price) 
            ELSE sls_sales
            END AS sls_sales, -- Recalculate sales if original value is missing or incorrect 
        sls_quantity,
        Case 
            When sls_price IS NULL OR sls_price <0 
            Then sls_sales / NULLIF(sls_quantity, 0) 
            ELSE sls_price 
            END AS sls_price   -- Derive price if original value is invalid
    FROM bronze.crm_sales_details 

    PRINT '>>>>>>>> Trucating Table: silver.erp_cust_az12  ';
    TRUNCATE TABLE silver.erp_cust_az12 ;
    PRINT '>>>>>>>> Inserting Data Into: silver.erp_cust_az12' 
    INSERT INTO silver.erp_cust_az12 (
        cid,
        bdate,
        gen
        )
    SELECT
        CASE WHEN cid like 'NAS%' THEN SUBSTRING(cid,4, LEN(cid))  -- 'Remove NAS'
            ELSE cid
        end cid,
        CASE WHEN bdate > GETDATE() THEN NULL 
        ELSE bdate -- Convert future birthdates to NULL
    END AS bdate,
        CASE WHEN UPPER(TRIM(gen))  IN ( 'F' , 'Female') THEN 'Female'
             WHEN UPPER(TRIM(gen))  IN ( 'M' , 'Male') THEN 'Male'
        ELSE 'Unknown'
    END AS gen -- Normalize gender values and handle unknown cases
    FROM bronze.erp_cust_az12  

    PRINT '>>>>>>>> Trucating Table: silver.erp_loc_a101  ';
    TRUNCATE TABLE silver.erp_loc_a101;
    PRINT '>>>>>>>> Inserting Data Into: silver.erp_loc_a101 ' 
    INSERT INTO silver.erp_loc_a101 (
        cid,
        cntry
    )
    Select 
    REPLACE(cid, '-', '') cid,
    CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END AS cntry  -- Standardize country codes and manage missing or empty values 
    FROM bronze.erp_loc_a101

    PRINT '>>>>>>>> Trucating Table: silver.erp_px_cat_g1v2 ';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    PRINT '>>>>>>>> Inserting Data Into: silver.erp_px_cat_g1v2' 
    INSERT INTO silver.erp_px_cat_g1v2 (
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT
        id,
        cat,
        subcat,
        maintenance
    FROM bronze.erp_px_cat_g1v2
END
