#ingestion.py
import pandas as pd
import config as conf

def extract_from_csv(file_path):
    # ✅ USE THE LIST, NOT THE KEYS
    missing_values = conf.SETTINGS["missing_string_map"]

    df = pd.read_csv(
        file_path,
        na_values=missing_values,      # 👈 Pass the list of bad strings
        keep_default_na=True,          # Keep standard NaN detection
        skipinitialspace=True,
        na_filter=True,
        quotechar='"',
        #sep='"',
        header=0 if conf.SETTINGS["files"]["header"] else None
    )
    
    return df



# if __name__ == "__main__":
#     file_path = conf.SETTINGS["files"]["path"]
#     df = extract_from_csv(file_path)
#     print(df.head())  # quick chec