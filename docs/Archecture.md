Snapshot of the whole design for this learning project

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

Continue learning project of part 1 