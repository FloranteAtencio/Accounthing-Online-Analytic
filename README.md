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

Road Map

☑ Source → staging
☑ Staging validation
☑ Transformation
☑ Dimension loading
☑ Surrogate keys
☑ Fact loading
☑ Grain verification
☑ Referential integrity checks
☑ Reconciliation
☑ Row counts
☑ Financial amount reconciliation
☑ ETL logging
☑ Error handling
☑ Basic automation
