-- ==========================================
-- Healthcare Patient Churn ETL Pipeline
-- Database Schema Setup and Data Ingestion
-- ==========================================

-- ------------------------------------------
-- 1. STAGING TABLE SETUP
-- ------------------------------------------

CREATE TABLE patient_churn_dataset (
    PatientID 				VARCHAR,
	Age						INT,
	Gender					VARCHAR,
	States					VARCHAR,
	Tenure_Months			INT,
	Specialty				VARCHAR,
	Insurance_Type			VARCHAR,
	Visits_Last_Year		INT,
	Missed_Appointments		INT,
	Days_Since_Last_Visit	INT,
	Last_Interaction_Date	DATE,
	Overall_Satisfaction	FLOAT,
	Wait_Time_Satisfaction	FLOAT,
	Staff_Satisfaction		FLOAT,
	Provider_Rating			FLOAT,
	Avg_Out_Of_Pocket_Cost	INT,
	Billing_Issues			INT,
	Portal_Usage			INT,
	Referrals_Made			INT,
	Distance_To_Facility_Miles	FLOAT,
	Churned						INT

);
	
-- ------------------------------------------
-- 2. DATA INGESTION (FROM CSV)
-- ------------------------------------------
COPY  patient_churn_dataset
FROM 'C:\project sql\hospital\patient_churn_dataset.csv' 
WITH (
    FORMAT CSV,
    HEADER true,
    DELIMITER ','
);
SELECT*FROM patient_churn_dataset;


-- ------------------------------------------
-- 3. CORE DIMENSION & FACT TABLES
-- ------------------------------------------


-- Patient Personal Details
CREATE TABLE patient_details(
patient_key SERIAL PRIMARY KEY,
patient_id VARCHAR(20) UNIQUE,
age INT NOT NULL,
gender VARCHAR(20) NOT NULL,
states VARCHAR(20),
insurance_type VARCHAR(20)NOT NULL
);
SELECT*FROM patient_details;

--  Patient Engagement Metrics
CREATE TABLE patient_engagement (
	engagement_key SERIAL PRIMARY KEY,
	patient_key INT REFERENCES patient_details(patient_key),
    Tenure_Months			INT,
	Specialty				VARCHAR(100),
	Visits_Last_Year		INT,
	Missed_Appointments		INT,
	Days_Since_Last_Visit	INT,
	Last_Interaction_Date	DATE,
	Portal_Usage			INT,
	Referrals_Made			INT,
	Distance_To_Facility_Miles	FLOAT
);
SELECT*FROM patient_engagement;


-- Patient Satisfaction Surveys
CREATE TABLE patient_satisfaction (
	satisfaction_key SERIAL PRIMARY KEY,
	patient_key INT REFERENCES patient_details(patient_key),
	overall_satisfaction NUMERIC(3,2),
	wait_time_satisfaction NUMERIC(3,2),
	staff_satisfaction NUMERIC(3,2),
	provider_rating NUMERIC(3,2)
	);


-- Patient Financial Records
CREATE TABLE patient_financials(
	 financial_key SERIAL PRIMARY KEY,
	 patient_key INT REFERENCES patient_details(patient_key),
	 avg_out_of_pocket_cost INT,
	 billing_issues INT
);
SELECT*FROM patient_financials;


-- Patient Churn Status
CREATE TABLE churn_status (
	churn_key SERIAL PRIMARY KEY,
	patient_key INT REFERENCES patient_details(patient_key),
	churned BOOLEAN
	);



-- ------------------------------------------
-- 4. DATA TRANSFORMATION & POPULATION (ETL)
-- ------------------------------------------


-- Populate Patient Details
INSERT INTO patient_details(patient_id, age, gender, states, insurance_type)
SELECT 
	PatientID,
	Age,
	Gender,
	States,
	Insurance_type
FROM  patient_churn_dataset;


-- Populate Patient Engagement
INSERT INTO patient_engagement (patient_key, Tenure_Months, Specialty, Visits_Last_Year, Missed_Appointments, Days_Since_Last_Visit,
	Last_Interaction_Date, Portal_Usage, Referrals_Made, Distance_To_Facility_Miles)
SELECT
	p.patient_key,
	s.Tenure_Months,
	s.Specialty,				
	s.Visits_Last_Year,
	s.Missed_Appointments,
	s.Days_Since_Last_Visit,
	s.Last_Interaction_Date,
	s.Portal_Usage,
	s.Referrals_Made,
	s.Distance_To_Facility_Miles
FROM patient_churn_dataset s
JOIN patient_details p
ON s.PatientID =p.patient_id;

SELECT*FROM  patient_engagement;


-- Populate Patient Satisfaction
INSERT INTO  patient_satisfaction (
	patient_key, 
	overall_satisfaction,
	wait_time_satisfaction,
	staff_satisfaction,
	provider_rating
	)
SELECT
	p.patient_key,
	s.Overall_Satisfaction,
	s.Wait_Time_Satisfaction,
	s.Staff_Satisfaction,
	s.Provider_Rating	
FROM patient_churn_dataset s
JOIN patient_details p
ON s.patientID =p.patient_id;

SELECT*FROM  patient_satisfaction;


-- Populate Patient Financials
INSERT INTO patient_financials(
	 patient_key,
	 avg_out_of_pocket_cost,
	 billing_issues
)
SELECT 
	p.Patient_key,
	s.Avg_Out_Of_Pocket_Cost,
	s.Billing_Issues
FROM patient_churn_dataset s
JOIN patient_details p
ON s.patientID =p.patient_id;

SELECT*FROM  patient_financials;



-- Populate Churn Status
INSERT INTO churn_status (patient_key, churned)
SELECT 
	p.patient_key,
	CASE 
		WHEN s.Churned = 1 THEN TRUE 
		ELSE FALSE 
	END
FROM patient_churn_dataset s
JOIN patient_details p
ON s.PatientID =p.patient_id;

SELECT* FROM churn_status;
