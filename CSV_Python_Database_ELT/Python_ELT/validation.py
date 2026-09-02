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

cur = conn.cursor()

session_id = 1
client_id = 1 
cur.execute(f"SET LOCAL app.get_permission_to_update = true")
cur.execute(f"SET LOCAL app.current_client_id ={client_id}")

print(f"🦽 Pending Validations Start!")
try:
    try:        
        cur.execute(" CALL Staging.main_import_workflow_validation(%s)",
                (session_id,)
                )
        conn.commit()
        print(f"🎉 Validation Complete !")
    except Exception as inner_e:
        print(f" ⚠️  Validation Procedure Fail : {inner_e}")
            
except Exception as e:
    err_message = str(e)
    print(f"⚠️  Validation Script Failed : {err_message}")

finally:

    print(f"🎉 Import Complete! Validations {session_id} ")

    if cur:
        cur.close()
    if conn:
        conn.close()
    print(" 🔒 Connections Closed")