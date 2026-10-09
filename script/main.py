import Import as IS
import import_line as il
import sanitation as Sa
import validation as val
import config as conf
try:
        
    client_id = 1
    import_type = 'SPREADSHEET_IMPORT'
    #'MANUAL_ENTRY', 'SPREADSHEET_IMPORT', 'API_IMPORT', 'SYSTEM_GENERATED', 'CORRECTION', 'REVERSAL'
    ar_import_file_location  = conf.SETTINGS["data"]["path"]
    ar_line_import_file_location  = conf.SETTINGS["data_extension"]["path"]
    
    # ar
    session_id= IS.call_main(client_id,import_type,ar_import_file_location)
    Sa.call_main(session_id,client_id)
    val.call_main(session_id,client_id)
    post.call_main(session_id,import_type,ar_import_file_location)
    
    # ar line
    session_id= il.call_main(client_id,import_type,ar_line_import_file_location)
    Sa.call_main(session_id,client_id)
    val.call_main(session_id,client_id)
    post.call_main(session_id,import_type,ar_line_import_file_location)

except Exception as e:
    print(f"ERROR {e}")