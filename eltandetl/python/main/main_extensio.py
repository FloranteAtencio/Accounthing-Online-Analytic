# main.py
import logging
import ingestion as ing
import config as conf
import quality as qual
import sanitation as san
import validation as val  # <--- Import validation
import logs as logs
import data_extension as de
import product as pro
import load as load
logger = logging.getLogger("Pipeline")

try:

    logs.logger_start()
    
    file_path = conf.SETTINGS["data_extension"]["path"]
    
    # 1. Extract
    df = ing.extract_from_csv(file_path=file_path)

    # 2. Validate Quality (Structure)
    required_cols = list(conf.SETTINGS["SCHEMA"].keys())
    qual.validate_quality(df=df, required_columns=required_cols)

    # 3. Sanitize (Clean)
    df = san.sanitize_data(df)

    

    # 4. Validate Business Rules (Logic)
    val.validate_business_rules(df)

    logger.info("Pipeline Complete! Data is clean, validated, and ready for loading.")

    #Loading
    de.staging_load(df)
    
    # Final Summary
    print(f"\n✅ Final Data Summary:")
    print(f"   Total Rows: {len(df)}")
    print(f"   Columns: {list(df.columns)}")
    print(f"   Sample:\n{df.head()}")

except Exception as e:
    logger.critical(f"Pipeline Failed | Error: {e}")
    raise