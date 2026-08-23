# OLAP_DATAWAREHOUSE_ACCOUNTING_ANALYTIC
Datawarehouse

sudo chown -R 999:999 /var/lib/docker/volumes/duckdb_wal_archive_duckdb/_data


                    SOURCES
             ┌────────┼─────────┐
             │        │         │
            OLTP     CSV       API
             │        │         │
             └────────┼─────────┘
                      ▼
                   EXTRACT
                      │
                      ▼
                   PYTHON
              ┌───────┼────────┐
              │       │        │
          sanitize validate  logging
              │       │        │
              └───────┼────────┘
                      ▼
                  STAGING
                      │
                      ▼
                TRANSFORMATION
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
     DIMENSIONS   DIMENSIONS   DIMENSIONS
          │           │           │
          └───────────┼───────────┘
                      ▼
                    FACTS
                      │
                      ▼
                 DATA WAREHOUSE
                      │
                      ▼
                 ANALYTICS
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
       Reports     Dashboard    Analysis


Table Hierarchy
```
data-warehouse-project/
│
├── README.md
│
├── docs/
│   ├── architecture.md
│   ├── data-model.md
│   └── etl-process.md
│
├── source/
│   └── sample/
│
├── etl/
│   ├── python/
│   └── sql/
│
├── staging/
│   └── sql/
│
├── warehouse/
│   ├── dimensions/
│   └── facts/
│
├── analytics/
│   └── queries/
│
└── docker/
```

Road Map
```
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
```
