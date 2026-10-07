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

print(f"🦽 Pending Approval Level 1 Start!")
    
try:
    try:        
        cur.execute(" CALL staging.import_workflow_approval_l1(%s,%s)",
                (session_id,'Bookkeeper')
                )
        conn.commit()
        print(f"🎉 Pending Approval Level 1 Complete !")

    except Exception as inner_e:
        print(f"⚠️ Approval Level 1 Procedure Fail : {inner_e}")
            
except Exception as e:
    err_message = str(e)
    print(f"⚠️ Approval Level 1 Script Failed : {err_message}")

finally:

    print(f"🎉 Import Complete! Approval Level 1 {session_id} ")

    if cur:
        cur.close()
    if conn:
        conn.close()
    print(" 🔒 Connections Closed")