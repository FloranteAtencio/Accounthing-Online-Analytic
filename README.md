### Online Analytic
Datawarehouse

Design / Workflow
---
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
---
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
Phase 1 - DONE
OLTP / CSV
 ↓
ETL
 ↓
Staging
 ↓
Star Schema
 ↓
Warehouse

Phase 2 - NEXT

Warehouse
 ↓
OLAP SQL
 ↓
Business questions
 ↓
Power BI

Phase 3

Full Refresh
      ↓
Incremental Load

Phase 4

Incremental Load
      ↓
SCD Type 2

Phase 5

PostgreSQL OLTP
      ↓
CDC
      ↓
ETL/ELT
      ↓
Warehouse

Phase 6

ETL
 ↓
Orchestration
 ↓
Monitoring
 ↓
Data quality
 ↓
Production-style pipeline


Current Progression
☑ Source → staging
☑ Staging validation
☑ Transformation
☑ Dimension loading
☑ Surrogate keys
☑ Fact loading
☑ Grain verification
☑ Referential integrity checks
Reconciliation < --- NEXT
Row counts
Financial amount reconciliation
ETL logging
Error handling
Basic automation
```
