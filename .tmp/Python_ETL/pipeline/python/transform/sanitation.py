# sanitize.py
import logging
import pandas as pd
import config as conf
logger = logging.getLogger("Pipeline")

def sanitize_data(df):
    """
    Sanitizes the DataFrame:
    1. Drops rows with missing 'amount' (critical field).
    2. Drops rows that are 100% empty.
    3. Trims whitespace from text columns.
    4. Convert date time
    """
    
    logger.info("Starting Data Sanitation...")
    initial_count = len(df)

    # 1. Data Conversion and Filtering
    # Data did not match the column 
    # datatype will be converted to null

    for key, index in conf.SETTINGS["SCHEMA"].items():
        if key in df.columns:
            if index == 'object':
                #object
                df[key] = df[key].astype(index)

            if index == 'float':
                #floate
                #df[key] = df[key].astype(index)
                df[key] = pd.to_numeric(df[key], errors='coerce').astype('float') 
                
            if index == 'Int64':
                #integer            
                #df[key] = df[key].astype(index)
                df[key] = pd.to_numeric(df[key], errors='coerce').astype('Int64') 
                                
            if index == 'int':
                #integer            
                #df[key] = df[key].astype(index)
                df[key] = pd.to_numeric(df[key], errors='coerce').astype('int') 
                                
            if index == 'datetime':
                # Convert to datetime if not already
                    df[key] = pd.to_datetime(df[key], format='%Y-%m-%d', errors='coerce')
                #    df['invoice_date'] = pd.to_datetime(df['invoice_date'], errors='coerce')
        # else:
        #     logger.warning(f" Warning Column | Column Not Found in the Dataframe")
        #     print(f"Warning: Column {key} not found in dataframe")        

    # 2. Checking if column email is valid
    # if not it will exclude or considered as null
    if 'email' in df.columns:
    # 1. Convert to string safely
    # This turns 123 -> "123" and NaN -> "nan"
        df['email'] = df['email'].astype(str)
    
    # 2. Define pattern
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

    # 3. Create mask for VALID emails
    # Note: "nan" string will NOT match this regex, which is good.
        is_valid = df['email'].str.contains(pattern, regex=True, na=False)
        
    # 4. Invalidate non-matches (set to actual NaN, not string "nan")
    # If it's NOT valid, set to np.nan
        df.loc[~is_valid, 'email'] = None

    # 3. TRIM whitespace from text columns
    text_cols = df.select_dtypes(include=['object']).columns
    for col in text_cols:
        # Convert to string (safe) then strip whitespace
        df[col] = df[col].astype(str).str.strip()
        # Optional: If "nan" string appears after strip, replace with actual NaN
        df[col] = df[col].replace('nan', pd.NA) 
        # Or if you prefer, replace 'nan' with 'Unknown'
        # df[col] = df[col].replace('nan', 'Unknown')

    # 4. Converting status columns to lower case       
    if 'status' in df.columns:
        df['status'] = df['status'].str.lower()

    
    # Excluding row with Null Data. Create a boolean mask: True if ANY column in the row has a null
    mask_has_nulls = df.isnull().any(axis=1)
    
    # 2. Separate rejected (has nulls) and accepted (no nulls)
    rejected_df = df[mask_has_nulls]       # Rows with at least one null
    df = df[~mask_has_nulls]      # Rows with NO nulls

    # 3. Export
    rejected_df.to_csv('rejected_users.csv', index=False)   

    final_count = len(df)
    dropped_count = initial_count - final_count
        

    if dropped_count > 0:
        logger.info(f"Sanitation complete. Rejected {dropped_count} rows. Final count: {final_count}")
    else:
        logger.info("Sanitation complete. No rows dropped.")
    
    return df




    # # 1. DROP ROW THAT ARE   
    # for columns in df.columns:

    #     missings = df[columns].isnull().sum()
    #     if missings > 0:
    #         logger.warning(f"Found {missings} rows with missing {columns}. Dropping them.")
    #         df = df.dropna(subset=[columns])
    #         logger.info(f"Dropped {missings} rows due to missing {columns}.")
    
    # # 2. DROP rows that are 100% empty (just in case)
    # empty_rows = df.isnull().all(axis=1).sum()
    # if empty_rows > 0:
    #     logger.warning(f"Found {empty_rows} rows that are 100% empty. Dropping them.")
    #     df = df.dropna(how='all')


    # # 4. Converting invoice date and due date
    # if 'due_date' in df.columns and 'invoice_date' in df.columns:
    #     # Convert to datetime if not already
    #     df['due_date'] = pd.to_datetime(df['due_date'], errors='coerce')
    #     df['invoice_date'] = pd.to_datetime(df['invoice_date'], errors='coerce')



# import pandas as pd
# import numpy as np
# from typing import Dict, List, Optional, Any
# import logging

# logger = logging.getLogger("Pipeline")

# class DataQualityError(Exception):
#     """Custom exception for data quality failures."""
#     pass

# def run_quality_checks(
#     df: pd.DataFrame, 
#     schema: Dict[str, str], 
#     rules: Optional[Dict[str, Any]] = None
# ) -> Dict[str, Any]:
#     """
#     Executes a comprehensive suite of data quality checks.
    
#     Args:
#         df: The DataFrame to validate.
#         schema: Dict mapping column names to expected types (e.g., {'id': 'int64', 'date': 'datetime64[ns]'}).
#         rules: Dict of custom validation rules.
    
#     Returns:
#         Dict with 'passed' (bool) and 'details' (list of issues).
    
#     Raises:
#         DataQualityError: If critical checks fail.
#     """
    
#     issues = []
#     critical_issues = []
    
#     # 1. STRUCTURAL CHECKS
#     # ---------------------
#     if df.empty:
#         critical_issues.append("Dataset is empty")
#         raise DataQualityError("Landing quality failed | dataset is empty")
    
#     # Check expected columns exist
#     expected_cols = set(schema.keys())
#     actual_cols = set(df.columns)
#     missing_cols = expected_cols - actual_cols
    
#     if missing_cols:
#         critical_issues.append(f"Missing columns: {missing_cols}")
#         raise DataQualityError(f"Landing quality failed | missing_columns={missing_cols}")
    
#     # Check for unexpected columns (optional strict mode)
#     extra_cols = actual_cols - expected_cols
#     if extra_cols:
#         logger.warning(f"Unexpected columns found (ignored): {extra_cols}")

#     # 2. TYPE VALIDATION
#     # ------------------
#     for col, expected_type in schema.items():
#         actual_type = str(df[col].dtype)
#         if expected_type == "datetime":
#             # Try to parse to verify it's actually parseable
#             try:
#                 pd.to_datetime(df[col], errors='raise')
#             except (ValueError, TypeError) as e:
#                 critical_issues.append(f"Column '{col}' is not valid datetime: {str(e)[:50]}")
#         elif actual_type != expected_type:
#             # Allow some flexibility (e.g., int32 vs int64)
#             if not (expected_type.startswith('int') and actual_type.startswith('int')) and \
#                not (expected_type.startswith('float') and actual_type.startswith('float')):
#                 issues.append(f"Type mismatch: {col} is {actual_type}, expected {expected_type}")

#     # 3. COMPLETENESS (NULLS & DUPLICATES)
#     # ------------------------------------
#     null_counts = df.isnull().sum()
#     null_threshold = 0.05  # 5% threshold for warnings
    
#     for col in expected_cols:
#         null_pct = null_counts[col] / len(df)
#         if null_pct == 1.0:
#             critical_issues.append(f"Column '{col}' is 100% null")
#         elif null_pct > null_threshold:
#             issues.append(f"High null rate in '{col}': {null_pct:.2%}")
#         elif null_pct > 0:
#             logger.info(f"Low null rate in '{col}': {null_pct:.2%}")

#     # Duplicate check (primary key or full row)
#     # Assuming 'order_id' is a likely PK, adjust based on schema
#     pk_col = [c for c in expected_cols if 'id' in c.lower()]
#     if pk_col:
#         dupes = df[pk_col[0]].duplicated().sum()
#         if dupes > 0:
#             critical_issues.append(f"Duplicate primary keys found: {dupes}")
    
#     if df.duplicated().any():
#         issues.append(f"Found {df.duplicated().sum()} fully duplicate rows")

#     # 4. VALIDITY (RANGES & FORMATS)
#     # ------------------------------
#     if rules:
#         for col, rule in rules.items():
#             if col not in df.columns:
#                 continue
            
#             if rule.get("type") == "range":
#                 min_val = rule.get("min")
#                 max_val = rule.get("max")
#                 if min_val is not None:
#                     violations = (df[col] < min_val).sum()
#                     if violations > 0:
#                         issues.append(f"Column '{col}': {violations} values below {min_val}")
#                 if max_val is not None:
#                     violations = (df[col] > max_val).sum()
#                     if violations > 0:
#                         issues.append(f"Column '{col}': {violations} values above {max_val}")
            
#             elif rule.get("type") == "regex":
#                 pattern = rule.get("pattern")
#                 if pattern:
#                     # Only check string columns
#                     if df[col].dtype == 'object':
#                         # ~ ensures we find non-matches
#                         invalid_mask = ~df[col].astype(str).str.match(pattern, na=False)
#                         invalid_count = invalid_mask.sum()
#                         if invalid_count > 0:
#                             issues.append(f"Column '{col}': {invalid_count} values do not match pattern {pattern}")

#     # 5. BUSINESS LOGIC (Cross-column)
#     # --------------------------------
#     if "amount" in df.columns and "quantity" in df.columns and "unit_price" in df.columns:
#         # Example: amount should equal quantity * unit_price (with tolerance for rounding)
#         expected_amount = df["quantity"] * df["unit_price"]
#         tolerance = 0.01
#         diff = (df["amount"] - expected_amount).abs()
#         logic_errors = (diff > tolerance).sum()
#         if logic_errors > 0:
#             critical_issues.append(f"Business logic failure: {logic_errors} rows where amount != qty * price")

#     # --- FINAL AGGREGATION ---
#     all_issues = critical_issues + issues
    
#     if critical_issues:
#         logger.error(f"CRITICAL QUALITY FAILURES: {critical_issues}")
#         raise DataQualityError(
#             f"Landing quality failed | critical_issues={len(critical_issues)} | "
#             f"details={str(critical_issues)}"
#         )
    
#     if issues:
#         logger.warning(f"Non-critical quality issues found: {len(issues)}")
#         for issue in issues:
#             logger.warning(f"  - {issue}")
#     else:
#         logger.info("Data quality checks passed successfully")

#     return {
#         "passed": True,
#         "row_count": len(df),
#         "issues": issues,
#         "critical_count": len(critical_issues)
#     }