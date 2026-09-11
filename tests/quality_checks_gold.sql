/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customer'
-- ====================================================================
-- Check for Uniqueness of Customer Key in gold.dim_customer
-- Expectation: No results 
SELECT 
    Customer_Number_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customer
GROUP BY Customer_Number_key 
HAVING COUNT(*) > 1;


-- ====================================================================
-- Checking 'gold.product_key'
-- ====================================================================
-- Check for Uniqueness of Product Key in gold_dim_products
-- Expectation: No results 
SELECT 
    Product_key,
    COUNT(*) AS duplicate_count
FROM gold_dim_product
GROUP BY Product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customer c
ON c.Customer_Number_key = f.Customer_Number_key
LEFT JOIN gold_dim_product p
ON p.product_key = f.product_key
WHERE c.Customer_Number_key IS NULL
