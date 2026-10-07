import logging
import psycopg2
import config as conf
import pandas as pd

def staging_load():
    logger = logging.getLogger("Pipeline")
    logger.info("Starting Data loading...")
    
    conn = None
    try:
        # 1. Connect to the database
        conn = psycopg2.connect(
            host=conf.SETTINGS["database"]["host"],
            database=conf.SETTINGS["database"]["database"],
            user=conf.SETTINGS["database"]["user"],
            password=conf.SETTINGS["database"]["password"],
            port=conf.SETTINGS["database"]["port"]
        )
        
        # 2. Define the SQL Query
        query = """

-- Sales Discount
SELECT 

    format('Invoice - %s (%s) ',sai.invoice_code, p.product_name) as transaction,
    'Sales Discount' as account_key,
    sai.client_code as  client_key,
    sai.invoice_date as journal_date_key,
    round(((p.price * al.discount) * al.quantity ),2) as credit_amount,
    ' ' as debit_amount,
    'CSV_Import'

FROM Staging.stg_ar_imports sai
LEFT JOIN staging.ar_line al USING(invoice_code)
LEFT JOIN staging.product p USING(product_code)
WHERE al.discount > 0 and sai.status IN ('returned');

        """
        
        # 3. Read SQL directly into a Pandas DataFrame
        # This handles the connection, execution, and fetching automatically
        df = pd.read_sql_query(query, conn)
        
        # 4. Save to CSV
        output_file = 'staging_data/staging_fact_General_ledger_Return_salesdiscount.csv'
        df.to_csv(output_file, index=False) # index=False prevents writing row numbers
        
        logger.info(f"Successfully loaded {len(df)} rows to {output_file}")
        
    except Exception as e:
        logger.error(f"Error during data extraction: {e}")
        raise e
    finally:
        if conn:
            conn.close()
            logger.info("Database connection closed.")

staging_load()
# Usage
# staging_load()