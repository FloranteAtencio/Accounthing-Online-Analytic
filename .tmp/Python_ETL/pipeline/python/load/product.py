import logging
import psycopg2
import config as conf
from datetime import datetime
import pandas as pd
from psycopg2.extras import execute_batch

def staging_load(df):
    logger = logging.getLogger("Pipeline")
    logger.info("Starting Data loading...")
    conn = psycopg2.connect(
        host=conf.SETTINGS["database"]["host"],
        database=conf.SETTINGS["database"]["database"],
        user=conf.SETTINGS["database"]["user"],
        password=conf.SETTINGS["database"]["password"],
        port=conf.SETTINGS["database"]["port"]
    )
    cur = conn.cursor()

    print(" Starting load session")
    try:   
        for index, row in df.iterrows():
            # Helper to format date safely
            def format_date(val):
                if pd.isna(val):
                    return None # Inserts NULL if date is missing
                if isinstance(val, str):
                    return val # Assume already correct format 'YYYY-MM-DD'
                # Handles pandas Timestamp and datetime objects
                return val.strftime('%Y-%m-%d')

            # Prepare data list
            records = []
            for _, row in df.iterrows():
                records.append((
                    row['product_code'],
                    row['product_name'],
                    row['description'],
                    row['product_unit'],
                    row['quantity'],                                                  
                    row['cost'],
                    row['price'],                                                  
#                    row['cost'],
                    #format_date(row['invoice_date']),
                    #format_date(row['due_date']),
                    format_date(row['purchase_date'])
                ))

            query = """
                INSERT INTO staging.product
                (product_code, product_name, description, product_unit, quantity, cost, price, purchase_date)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """
            
            # Execute in batches (default 100 rows per batch)
        execute_batch(cur, query, records)
        conn.commit()
        print(f" Load completed successfully: {len(records)} rows inserted.")

    except Exception as e:
        print(f" Failed: {e}")
        conn.rollback()

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()
        print(" Connection closed. ")   

# INSERT INTO Staging.stg_ar_imports ( invoice_code, customer_code, client_code, amount, invoice_date, due_date, status)VALUES ( 2026080086,1,3,72,'2026-08-28','2026-07-29','Partially Returned' );        