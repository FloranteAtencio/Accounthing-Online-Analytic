import psycopg2
import json
import csv
import os
import sys

conn = psycopg2.connect(
    host = "localhost",
       database = "erp_db",
       user = "admin_user",
       password = "change_me_in_production",
       port=5432
)

session_id = 1


cur = conn.cursor()
cur.execute("SET LOCAL app.import_source_file = 'data.csv'")

try:
    print(f"🦽 Pending Posting Start!")
    try:        
        cur.execute(" CALL staging.import_workflow_posting(1)",
                (session_id,)
                )
        conn.commit()
        print(f"🎉 Posting Complete !")
    except Exception as inner_e:
        print(f"⚠️ Posting procedure fail : {inner_e}")
            
except Exception as e:
    err_message = str(e)
    print(f"⚠️  Posting script Failed : {err_message}")

finally:

    print(f"🎉 Import Complete! Validations {session_id} ")

    if cur:
        cur.close()
    if conn:
        conn.close()
    print(" 🔒 Connections Closed")