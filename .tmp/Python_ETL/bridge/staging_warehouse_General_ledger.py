import logging
import psycopg2
import config as conf
import pandas as pd

def staging_load():

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s | %(levelname)s | %(message)s"
    )

    logger = logging.getLogger("Pipeline")

    logger.info("Pipeline start | client=1 | entity=Account_receivables")
   # logger = logging.getLogger("Pipeline")
    logger.info("Starting Data loading...")
    

    # 1. Connect to the database
    conn = psycopg2.connect(
        host=conf.SETTINGS["database"]["host"],
        database=conf.SETTINGS["database"]["database"],
        user=conf.SETTINGS["database"]["user"],
        password=conf.SETTINGS["database"]["password"],
        port=conf.SETTINGS["database"]["port"]
    )

    conn2 = psycopg2.connect(
        host=conf.SETTINGS["config"]["host"],
        database=conf.SETTINGS["config"]["database"],
        user=conf.SETTINGS["config"]["user"],
        password=conf.SETTINGS["config"]["password"],
        port=conf.SETTINGS["config"]["port"]
    )

    cur = conn.cursor()
        
    cur2 = conn2.cursor()
    
    try:
        query = """ SELECT * FROM Staging.general_ledger_view; """    
        
        logger.info(" Query Pass! ")
            
        df = pd.read_sql_query(query, conn)

        logger.info(f"Extracted {len(df)} rows from staging.")

        logger.info(" Extracting Data ... ") 
        for index, row in df.iterrows():

            query = """ INSERT INTO Warehouse.fact_gl (
            transaction, 
            account_key, 
            client_key, 
            journal_date_key, 
            debit_amount, 
            credit_amount,
            source_system) 
            VALUES (%s,%s,%s,%s,%s,%s,%s)"""

            values = (
                row['transaction'],
                row['account_key'],
                row['client_key'], 
                row['journal_date_key'],
                row['debit_amount'],
                row['credit_amount'],
                row['source']
            )   
              
            cur2.execute(query,values)
        logger.info(" Succesful... ") 

        # 2. Define the SQL Query        
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