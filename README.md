# Corporate Patient Retention Analytics Pipeline

## Project Purpose
This project provides a complete automated data engineering solution to ingest raw hospital dataset files, clean and separate the flat records into structured relational tables, and prepare the database for advanced patient churn analytics.

---

## Technical Execution (What the Code Does)

The SQL script executes programmatically in three distinct phases:

### Phase 1: Database Creation and Storage Setup
*   **Staging Initialization**: Spins up an unconstrained staging table (`patient_churn_dataset`) to accept raw text, numeric, and date data fields without failing.
*   **Target Schema Deployment**: Deploys 5 distinct relational database tables (`patient_details`, `patient_engagement`, `patient_satisfaction`, `patient_financials`, and `churn_status`). 
*   **Relational Mapping**: Configures automatic auto-incrementing serial keys (`SERIAL PRIMARY KEY`) and establishes relational integrity using foreign key constraints (`REFERENCES`) linking back to the master patient file.

### Phase 2: Native Data Streaming (Ingestion)
*   Executes a high-velocity server block command (`COPY`) to inject the localized CSV flat file records directly into the staging layer using standard comma delimiters.

### Phase 3: Relational Transformation & Record Migration (ETL)
*   **Demographic Separation**: Populates core tracking data fields directly into the primary dimension table.
*   **Relational Lookups**: Executes inner joins between the raw staging tables and your new master identity tables (`ON s.PatientID = p.patient_id`). This processes, validates, and aligns matching records across your operational schemas.
*   **Boolean Evaluation**: Isolates categorical integer numbers from the raw storage file and maps them into active database flags (`::boolean`) inside the target retention table.

---

## System Outcome (Data Results After Execution)

Upon successful, error-free execution of the pipeline script, your database environment will transition from a single flat data object into a highly organized relational database network containing the following outcomes:

| Executed Table Target | Generated Structural Columns | Concrete Analytical Value / Business Outcome |
| :--- | :--- | :--- |
| **`patient_details`** | `patient_key`, `patient_id`, `age`, `gender`, `states`, `insurance_type` | Forms the master identity directory; cleans demographics for segmenting localized churn behaviors. |
| **`patient_engagement`** | `engagement_key`, `patient_key`, `Tenure_Months`, `Specialty`, `Visits_Last_Year`, `Missed_Appointments`, `Days_Since_Last_Visit`, `Last_Interaction_Date`, `Portal_Usage`, `Referrals_Made`, `Distance_To_Facility_Miles` | Couples clinical attendance records with proximity stats to find patterns in missed clinic appointments. |
| **`patient_satisfaction`** | `satisfaction_key`, `patient_key`, `overall_satisfaction`, `wait_time_satisfaction`, `staff_satisfaction`, `provider_rating` | Formats loose survey data into accurate decimal ratings (`NUMERIC`) to isolate human performance issues. |
| **`patient_financials`** | `financial_key`, `patient_key`, `avg_out_of_pocket_cost`, `billing_issues` | Collects transactional issues to test if financial disputes drive patients to find alternative healthcare providers. |
| **`churn_status`** | `churn_key`, `patient_key`, `churned` | Serves as the binary prediction column (`TRUE`/`FALSE`) to train retention forecasting and ML models. |
