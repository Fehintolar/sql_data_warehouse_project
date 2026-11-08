/*

Quality Checks - Silver Layer (PostgreSQL Version)

Purpose: 
    To check data quality after loading silver layer
    Checks for: duplicates, nulls, unwanted spaces, invalid dates, 
    data standardization, data consistency

Run after: CALL silver.load_silver();

*/

-- ============================================================================
-- 1. silver.crm_cust_info
-- ============================================================================

-- Check for NULLs or Duplicates in Primary Key (cst_id)
-- Expectation: No Result
SELECT cst_id, COUNT(*) 
FROM silver.crm_cust_info 
GROUP BY cst_id 
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces in firstname, lastname, gndr, marital_status
-- Expectation: No Results
SELECT cst_firstname 
FROM silver.crm_cust_info 
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname 
FROM silver.crm_cust_info 
WHERE cst_lastname != TRIM(cst_lastname);

-- Check Data Standardization & Consistency
SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info;
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info;

-- Final check
SELECT * FROM silver.crm_cust_info LIMIT 10;

-- ============================================================================
-- 2. silver.crm_prd_info
-- ============================================================================

-- Check for NULLs or Duplicates in Primary Key (prd_id)
-- Expectation: No Result
SELECT prd_id, COUNT(*) 
FROM silver.crm_prd_info 
GROUP BY prd_id 
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces in prd_nm
SELECT prd_nm 
FROM silver.crm_prd_info 
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative Values in Cost
-- Expectation: No Result
SELECT prd_cost 
FROM silver.crm_prd_info 
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Check Data Standardization & Consistency
SELECT DISTINCT prd_line FROM silver.crm_prd_info;

-- Check for Invalid Date Orders (start date > end date)
-- Expectation: No Results
SELECT * 
FROM silver.crm_prd_info 
WHERE prd_end_dt < prd_start_dt;

-- Final check
SELECT * FROM silver.crm_prd_info LIMIT 10;

-- ============================================================================
-- 3. silver.crm_sales_details
-- ============================================================================

-- Check for Invalid Dates (order date > ship date or due date)
-- Expectation: No Results
SELECT * 
FROM silver.crm_sales_details 
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT DISTINCT
    sls_sales, sls_quantity, sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- Final check
SELECT * FROM silver.crm_sales_details LIMIT 10;

-- ============================================================================
-- 4. silver.erp_loc_a101
-- ============================================================================

-- Check for Duplicates in Primary Key (cid)
-- Expectation: No Result
SELECT cid, COUNT(*) 
FROM silver.erp_loc_a101 
GROUP BY cid 
HAVING COUNT(*) > 1;

-- Data Standardization & Consistency
SELECT DISTINCT cntry 
FROM silver.erp_loc_a101 
ORDER BY cntry;

-- Final check
SELECT * FROM silver.erp_loc_a101 LIMIT 10;

-- ============================================================================
-- 5. silver.erp_cust_az12
-- ============================================================================

-- Check for Duplicates in Primary Key (cid)
-- Expectation: No Result
SELECT cid, COUNT(*) 
FROM silver.erp_cust_az12 
GROUP BY cid 
HAVING COUNT(*) > 1;

-- Check for Invalid Birthdates (bdate in the future)
-- Expectation: No Result
SELECT DISTINCT bdate 
FROM silver.erp_cust_az12 
WHERE bdate > CURRENT_DATE;

-- Check Data Standardization & Consistency
SELECT DISTINCT gen FROM silver.erp_cust_az12;

-- Final check
SELECT * FROM silver.erp_cust_az12 LIMIT 10;

-- ============================================================================
-- 6. silver.erp_px_cat_g1v2
-- ============================================================================

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT * FROM silver.erp_px_cat_g1v2 
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Data Standardization & Consistency
SELECT DISTINCT maintenance FROM silver.erp_px_cat_g1v2;
SELECT DISTINCT cat FROM silver.erp_px_cat_g1v2;
SELECT DISTINCT subcat FROM silver.erp_px_cat_g1v2;

-- Final check
SELECT * FROM silver.erp_px_cat_g1v2 LIMIT 10;
