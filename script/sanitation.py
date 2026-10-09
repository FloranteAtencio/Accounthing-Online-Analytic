import psycopg2
import json
import csv
import os
import sys
import config as conf

def call_main(session_id,client_id):
    
    conn = psycopg2.connect(
        host=conf.SETTINGS["database"]["host"],
        database=conf.SETTINGS["database"]["database"],
        user=conf.SETTINGS["database"]["user"],
        password=conf.SETTINGS["database"]["password"],
        port=conf.SETTINGS["database"]["port"]
    )

    cur = conn.cursor()

    cur.execute(f"SET LOCAL app.get_permission_to_update = true")
    cur.execute(f"SET LOCAL app.current_client_id ={client_id}")

    print(f"🦽 Pending Validations Start!")
    try:
        try:        
            cur.execute("CALL Staging.import_workflow_sanitation(%s)", (session_id,))
            conn.commit()
            print(f"🎉 Sanitation Complete !")
        except Exception as e:
            print(f"Error: {e}")
                
    except Exception as e:
        err_message = str(e)
        print(f"⚠️  Validation Script Failed : {err_message}")

    finally:

        if cur:
            cur.close()
        if conn:
            conn.close()
        print(" 🔒 Connections Closed")