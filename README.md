# OLAP_DATAWAREHOUSE_ACCOUNTING_ANALYTIC
Datawarehouse

sudo chown -R 999:999 /var/lib/docker/volumes/duckdb_wal_archive_duckdb/_data



                  ERP / OLTP
                 PostgreSQL 15
                      │
                      │ EXTRACT
                      ▼
                 Python ETL
                      │
                      ▼
                  STAGING
                      │
             ┌────────┴────────┐
             │                 │
        VALIDATION         TRANSFORM
             │                 │
             └────────┬────────┘
                      ▼
                   DuckDB
                  OLAP/WH
                      │
               ┌──────┴──────┐
               ▼             ▼
           DIMENSIONS       FACTS
               │             │
               └──────┬──────┘
                      ▼
                  ANALYTICS# olap_database
# olap-datawarehouse
