# validate.py
import logging
import pandas as pd
import numpy as np
from datetime import datetime

logger = logging.getLogger("Pipeline")

def validate_business_rules(df):
    """
    Applies business logic rules to the sanitized data.
    Raises an error if critical rules are violated.
    """
    logger.info("Starting Business Logic Validation...")
    
    issues = []
    
    # 1. RULE: Amount must be non-negative (or handle returns separately)
    # If your business allows negative amounts (returns), skip this.
    # If amounts MUST be positive, uncomment the next line:
    if 'payment_recieved' in df.columns:
        if (df['payment_recieved'] < 0).any():
            issues.append(f"Found {(df['payment_recieved'] < 0).sum()} rows with negative amounts.")
        
    # 2. RULE: Due Date must be >= Invoice Date
    if 'due_date' in df.columns and 'invoice_date' in df.columns:
        # Convert to datetime if not already
        # df['due_date'] = pd.to_datetime(df['due_date'], errors='coerce')
        # df['invoice_date'] = pd.to_datetime(df['invoice_date'], errors='coerce')
        
        invalid_dates = (df['due_date'] < df['invoice_date']).sum()
        if invalid_dates > 0:
            issues.append(f"Found {invalid_dates} rows where Due Date < Invoice Date.")
    
    # 3. RULE: Status must be one of the allowed values
    allowed_statuses = ["paid", "pending", "partially paid", "overdue", "partially returned","returned", "cancelled"]
    if 'status' in df.columns:
        invalid_status = ~df['status'].isin(allowed_statuses)
        if invalid_status.sum() > 0:
            invalid_values = df.loc[invalid_status, 'status'].unique()
            issues.append(f"Found invalid status values: {list(invalid_values)}")

    # 4. RULE: Client/Customer Code must not be empty
    if 'client_code' in df.columns:
        if df['client_code'].isnull().any() or (df['client_code'].astype(str) == "").any():
            issues.append("Found empty or null 'client_code' values.")

    # 5. RULE: Client/Customer Code must not be empty
    if 'customer_code' in df.columns:
        if df['customer_code'].isnull().any() or (df['customer_code'].astype(str) == "").any():
            issues.append("Found empty or null 'customer_code' values.")

    # 5. RULE: Client/Customer Code must not be empty
    if 'product_code' in df.columns:
        if df['product_code'].isnull().any() or (df['product_code'].astype(str) == "").any():
            issues.append("Found empty or null 'product_code' values.")

    # 5. RULE: Client/Customer Code must not be empty
    if 'vendor_code' in df.columns:
        if df['vendor_code'].isnull().any() or (df['vendor_code'].astype(str) == "").any():
            issues.append("Found empty or null 'vendor_code' values.")

    if issues:
        logger.error(f"Business Logic Validation Failed: {issues}")
        raise ValueError(f"Validation failed | {issues}")

    logger.info("All business logic rules passed.")

    # for columns in df.columns:
    #     df[columns] = df[columns].str.replace('"',"'")

    return True