# Planning: Data Initial Study	
      
### Stage – 1	

* **Phase 1 Business and Data requirements Analysis**

  * To Ensure financial stability and Optimize capital Structure. To Serve a Planning advisory, To monitor Activities on fniance management and Analysis to its client.	

* **Stage 2 issues and imperatives are characterized.**

  * Collect and process data with proper handle and following the governance, risk and compliance to ensure reliability and  transparency	

* **Stage 3 goals are characterized**	

  * the core components: 
    * FP and A (Financial Planning and analysis)  
    * Treasury and Cash flow management  
    * Core Accounting and General Ledger (GL)  
    * Working Capital and AR/AP optimization 	

* **Stage 4 the scopes  and  boundaries are characterized**

  * -Financial Planning and Analysis (FP&A) 
    * serves as the strategic engine, focusing on forward-looking activities such as budgeting, forecasting, and scenario modeling to guide executive decision-making and resource allocation. 	
  * -Treasury and Cash Flow Management 
    * handles the company’s liquidity, managing cash reserves, debt, equity, and banking relationships to ensure financial stability and optimize capital structure.  	
  * -Core Accounting and the General Ledger (GL)
    * act as the historical record-keeping backbone, documenting all financial transactions, ensuring regulatory compliance, and producing the financial statements that FP&A and Treasury rely on. 	
  * -Working Capital and AR/AP Optimization 
    * focuses on managing short-term assets and liabilities—specifically accounts receivable, accounts payable, and inventory—to improve the cash conversion cycle and free up capital for operations. 	
      
### Stage – 2	
* System and  Data  Architecture Design	
  * I am using PostgreSQL for the Transactional Layer (OLTP) because it guarantees ACID compliance for financial records. For the Analytical Layer (OLAP), I will use DuckDB to handle heavy reporting without slowing down daily operations." 	

* DBMS Software Selection	

* OLTP: Postgresql	
  * In-database Transactional Engine	
      
* OLAP: Duckdb	
  * In-database Analytical Engine	
---
```      
Logical Design:	
OLTP 
[CSV/ API/ SPREAD_SHEET_IMPORT]
      
    ↓ ---------------> [log the import details in summary and every succes/fail transaction]

[Staging] ----------------> [log to import workflows status]
   
    ↓ ---------------> [update the import workflow status]

[Sanitation] ----------------> [] 
   
    ↓ ----------------> [update the import workflow status]

[Validations] ----------------> []
   
    ↓ ----------------> [update the workflow status]

[Approval Chain] ----------------> []

    ↓ ----------------> [update the workflow status]

[Posting] ----------------> [Record Lineage]
      
    ↓ ----------------> [update the workflow status and import workflow end here]

    ↓ ----------------> [Trigger guard work on this part to prevent by passing or cut the process]

[ AR / AP / Inventory Transactions and so on] ----------------> [Record Lineage, Audit Log, and transaction lifecycle] 
      
    ↓ ----------------> [Trigger guard work on this part to prevent by passing or cut the process]

[Journals] -> [Audit Log/ update transaction life cycle]    

    ↓ ----------------> [Trigger guard work on this part to prevent by passing or cut the process]

[Accounting Module/Inventory Module] ----------------> [Audit Log]

    ↓ ----------------> [Trigger guard work on this part to prevent by passing or cut the process]

[Validations at core production] ----------------> [Record Lineage]

    ↓ ----------------> [update the transaction life cycle status]

[Approval Chain at core production ] ----------------> [Record Lineage]

    ↓ ----------------> [update the transaction life cycle status]

[Transaction business/reports/reconcile]

    ↓

[Archive( 12 months)]

```



OLAP:

Design / Workflow
---
```
                    SOURCES
             ┌────────┼─────────┐
             │        │         │
            OLTP     CSV       API
             │        │         │
             └────────┼─────────┘
                      ▼
                   BRONZE
                      │
                      ▼
                     SQL
              ┌───────┼────────┐
              │       │        │
          sanitize validate  logging
              │       │        │
              └───────┼────────┘
                      ▼
                    SILVER
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
                    GOLD
                      │
                      ▼
                  PRESENTATION
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
       Reports     Dashboard    Analysis
```
      
Physical design	
* OLTP:
  * Actual Code

* OLAP:
  * Actual code


## Stage – 3	
*  **Implementation and loading**
* At this stage in the lifecycle: Create a database storage group. Create a database within the storage group. Assign permissions to database administrators to use the database. Create tablespaces within the database. 	
      
## Stage - 4. Testing and Evaluation	
* Testing and evaluation is a way to determine the subject merit, worth, and significance, using the criteria governed by a set of standards phase occur in parallel with the application programming. Programmers use database tools such as report generators, screen painters, and menu generators to prototype the application during the coding of the programs.	
      
## Stage – 5. Operation	
* The testing and evaluation phase is followed by the operation phase. At the start of the operation phase, the process of system development always begins, as the system evolves from a simple to a more complex form.	
      
## Stage – 6. Maintenance	
* The maintenance phase plays a crucial role in database development as it includes major tasks such as access management, database recovery, database backup, enhancing security, software updates, and hardware maintenance.	

# Online Analytic
Datawarehouse

---
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
