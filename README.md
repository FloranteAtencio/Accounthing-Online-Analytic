### Online Analytic
Datawarehouse

Part 2 of Learning Project - Datawarehouse

This is part 2 of my database journey. 
Here is the link for the Part 1 https://github.com/FloranteAtencio/Part-1-OLTP-Database. All of the configuration, application and setup are in the Part 1 Fell free to check it.
- Tools:
  Postgresql Duckdb -> OLAP Database
  Python -> Pipeline
  Postgresql 15.15 -> OLTP Database
- I intended not to apply all what I've done at the part 1 like:
  Domain
  Constrain
  Partition
  RBAC
  RLS
  Security Definer
  Search path
  Audits
  and so on.
Because this part 2 project is for data warehousing.

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
