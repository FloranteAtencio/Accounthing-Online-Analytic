# quality.py
import logging
import pandas as pd

logger = logging.getLogger("Pipeline")

def validate_quality(df, required_columns=None):
    """
    Main entry point for quality checks.
    """
    logger.info("Starting Data quality check...")
    # 1. Empty Check
    if len(df) == 0:
        logger.error("Critical: Dataset is empty")
        raise ValueError("Landing quality failed | dataset is empty")

    logger.info(f"Data check passed: {len(df)} rows found")

    # 2. Column Check
    if required_columns:
        #check_columns(df, required_columns)
        check_unlisted_columns(df, required_columns)  # ✅ Now we check the return value implicitly
    
    # 3. Null Check
    check_empty_rows(df)
    check_nulls(df)
    logger.info("All quality checks passed.")
    return True

def check_columns(df, required_columns):
    """Check if expected columns exist."""
    expected = set(required_columns)
    actual = set(df.columns)
    missing = expected - actual

    if missing:
        logger.error(f"Missing Columns | Expected: {missing}")
        raise ValueError(f"Critical: Missing Columns {missing}")
    
    logger.info(f"Columns validated: {len(expected)} found")
    return True

def check_unlisted_columns(df, allowed_columns):
    """Check if there are unexpected columns (strict mode)."""
    expected = set(allowed_columns)
    actual = set(df.columns)
    unexpected = actual - expected

    if unexpected:
        logger.warning(f"Unexpected columns | found (ignored): {unexpected}")
        raise ValueError(f"Critical : Exceeding column detected!")
    return True

def check_empty_rows(df):
    """Check for completely empty rows."""
    total_null_rows = df.isnull().all(axis=1).sum()

    if total_null_rows > 0:
        logger.warning(f"Null Detected | {total_null_rows} rows are 100% empty")
        logger.info("These will be dropped during cleaning")
        return True
    
    logger.info("Dataset clear | No completely empty rows")
    return True

def check_nulls(df):
    for columns in df.columns:
        sum = df[columns].isnull().sum()
        if sum > 0:
            logger.warning(f" Warning | column {columns}: Null Detected : {sum}")
            print(df[df[columns].isnull()])    
            
    logger.info("Dataset Clear | Complete rows")
    return True