# Ischemic Heart Disease Risk Factors Analysis (PostgreSQL)

A comprehensive, database-driven analytical project focused on Ischemic Heart Disease (IHD). Utilizing the public UCI Heart Disease dataset (920 patient records, 16 clinical attributes), this project implements an end-to-end analytical pipeline inside PostgreSQL to extract epidemiological insights, build dynamic risk-scoring metrics, and track risk progression across aging cohorts.

##  Project Objective
To isolate key demographic drivers of heart disease, analyze the correlation between clinical biomarkers and positive diagnoses, and design a multi-factorial risk scoring framework to stratify patients.

##  Database Schema & Features
The project processes the `heart_disease_uci.csv` dataset, which includes the following features:
* **Demographics** *: `id`, `age`, `sex`
* **Clinical Markers** *:
  * `cp` — Chest pain type (typical angina, asymptomatic, etc.)
  * `trestbps` — Resting blood pressure (mm Hg)
  * `chol` — Serum cholesterol (mg/dl)
  * `fbs` — Fasting blood sugar > 120 mg/dl
  * `restecg` — Resting electrocardiographic results
  * `thalch` — Maximum heart rate achieved
  * `exang` — Exercise-induced angina
  * `oldpeak` — ST depression induced by exercise relative to rest
  * `slope` — The slope of the peak exercise ST segment
  * `ca` — Number of major vessels colored by fluoroscopy
  * `thal` — Thallium scintigraphy / stress test results
* **Target Variable:** `num` — Diagnosis of heart disease (0 = healthy, >0 = diseased status)

## Repository Structure
The analysis is broken down into 5 sequential scripts tracking the analytical lifecycle:
1. `01_sex_age_analysis.sql` — Baseline prevalence and disease rate calculations stratified by sex and age cohorts.
2. `02_modifiable_factors.sql` — Aggregation of metabolic markers (cholesterol, blood pressure, fasting blood sugar) relative to diagnosis.
3. `03_clinical_markers.sql` — Deep-dive diagnostic analysis incorporating ECG patterns, exercise-induced angina, Thallium stress tests, and fluoroscopy (`ca`).
4. `04_risk_score_cte.sql` — A custom multi-factorial risk scoring engine calculated via population averages using CTEs.
5. `05_risk_ranking.sql` — Dynamic risk profiling using SQL Window Functions (`LAG`) to analyze step-by-step risk score increases across aging cohorts.
##  Relational Database Architecture
For this project, the raw dataset was modeled into a relational structure inside PostgreSQL. The analysis evaluates data across key clinical entities:
* `Demographic Cohorts` — Stratified analysis by `sex` and partitioned `age_groups`.
* `Metabolic Profiles` — Combined evaluation of blood pressure (`trestbps`), serum cholesterol (`chol`), and fasting blood sugar (`fbs`).
* `Diagnostic Markers` — Electrocardiographic results (`restecg`), ST-depression metrics (`oldpeak`), and Thallium stress test outputs (`thal`).

##  Highlighted SQL Architecture

### 1. Multi-Factor Risk Stratification Engine (`04_risk_score_cte.sql`)
This script uses a `CROSS JOIN` against dynamically calculated baseline population averages to assign a custom risk score (0 to 6) for each patient, evaluating the exact correlation between cumulative risk factors and final disease rates.

```sql
WITH population_avg AS (
   SELECT 
      AVG(chol) AS avg_chol,
      AVG(trestbps) AS avg_bp,
      AVG(oldpeak) AS avg_st
   FROM heart
   WHERE chol > 0 AND trestbps > 0
),
risk_score AS (
    SELECT
      h.id, h.age, h.sex, h.num,
      CASE WHEN num > 0 THEN 'Diseased' ELSE 'Healthy' END AS status,
      (
         CASE WHEN h.chol > p.avg_chol THEN 1 ELSE 0 END +
         CASE WHEN h.trestbps > p.avg_bp THEN 1 ELSE 0 END +
         CASE WHEN h.oldpeak > p.avg_st THEN 1 ELSE 0 END +
         CASE WHEN h.exang = 'TRUE' THEN 1 ELSE 0 END +
         CASE WHEN h.fbs = 'TRUE' THEN 1 ELSE 0 END +
         CASE WHEN h.ca > 0 THEN 1 ELSE 0 END
      ) AS total_risk_score
    FROM heart h
    CROSS JOIN population_avg p
    WHERE h.chol > 0 AND h.trestbps > 0
)
SELECT 
    total_risk_score,
    COUNT(*) AS total_patients, 
    SUM(CASE WHEN num > 0 THEN 1 ELSE 0 END) AS diseased,
    ROUND(SUM(CASE WHEN num > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS disease_rate_pct
FROM risk_score
GROUP BY total_risk_score
ORDER BY total_risk_score; ```


### 2. Cohort Cohere Tracking via Window Functions (05_risk_ranking.sql)
``` WITH 
age_groups AS (
 SELECT *,
   CASE WHEN age < 45 THEN 'Under 45'
   WHEN age BETWEEN 45 AND 54 THEN '45-54'
   WHEN age BETWEEN 55 AND 64 THEN '55-64'
   ELSE '65+' END AS age_group
  FROM heart
  WHERE chol > 0 AND trestbps > 0),
population_avg AS (
  SELECT 
      AVG(chol) AS avg_chol,
      AVG(trestbps) AS avg_bp,
      AVG(oldpeak) AS avg_st
    FROM heart
    WHERE chol > 0 AND trestbps > 0),
risk_score AS (
  SELECT a.sex, a.age_group, a.num,
       (CASE WHEN a.chol > p.avg_chol THEN 1 ELSE 0 END +
        CASE WHEN a.trestbps > p.avg_bp THEN 1 ELSE 0 END +
        CASE WHEN a.oldpeak > p.avg_st THEN 1 ELSE 0 END +
        CASE WHEN a.exang = 'TRUE' THEN 1 ELSE 0 END +
        CASE WHEN a.fbs = 'TRUE' THEN 1 ELSE 0 END +
        CASE WHEN a.ca > 0 THEN 1 ELSE 0 END) 
		AS total_risk_score
    FROM age_groups a
    CROSS JOIN population_avg p),
group_stats AS (
  SELECT sex, age_group, 
    ROUND(AVG(total_risk_score)::numeric, 1) AS avg_risk_score,
    ROUND(SUM(CASE WHEN num > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS disease_rate_pct
  FROM risk_score
  GROUP BY sex, age_group
)
SELECT sex, age_group, avg_risk_score, disease_rate_pct,
    LAG(avg_risk_score) OVER (PARTITION BY sex ORDER BY age_group) AS prev_age_group_score,
    ROUND((avg_risk_score - LAG(avg_risk_score) OVER (PARTITION BY sex ORDER BY age_group))::numeric, 1) AS score_increase
FROM group_stats
ORDER BY sex, age_group; ```


## Tech Stack & Core Concepts Demonstrated
* **Database Engine:** PostgreSQL
* **Advanced SQL Mastery:** Complex Common Table Expressions (CTEs), Multi-Layer Aggregations, Relational Data Stratification.
* **Analytical Window Functions:** `LAG() OVER (PARTITION BY ... ORDER BY ...)` for trend analysis.
* **Domain Expertise:** Translation of critical clinical variables (ST depression, fasting blood sugar, thallium stress test results) into structured analytical database queries.


##  Key Analytical Insights & Clinical Findings

### 1. Demographic & Gender Disparities (From `01_sex_age_analysis.sql`)
The Gender Gap: The dataset reveals a significantly higher heart disease prevalence (`disease_rate_pct`) among Male patients compared to Female patients across almost all age groups. 
Age Aggravation: In both genders, the disease rate escalates sharply after the age of 45, showing that age is a non-modifiable risk factor that exponentially compounds other clinical risks.

### 2. The Metabolic Triad (From `02_modifiable_factors.sql` & `03_clinical_markers.sql`)
Cholesterol & BP Shifts: The `Diseased` cohort exhibits noticeably higher average serum cholesterol (`avg_cholesterol`) and resting blood pressure (`avg_blood_pressure`) compared to the `Healthy` group.
Asymptomatic Danger: A massive percentage of patients diagnosed with heart disease presented as asymptomatic (`asymptomatic_pct`) regarding chest pain type (`cp`). This highlights the critical clinical danger of "silent" ischemia and underscores why routine screenings (like ECG and Thallium stress tests) are vital.
Ischemia Markers: Exercise-induced angina (`exercise_angina_pct`) and significant ST depression (`avg_st_depression`) showed a powerful positive correlation with a confirmed heart disease diagnosis (`num > 0`).

### 3. Cumulative Risk Dynamics (From `04_risk_score_cte.sql` & `05_risk_ranking.sql`)
The Tipping Point: The custom risk scoring engine clearly demonstrates that as the `total_risk_score` moves from 0 toward 6, the `disease_rate_pct` approaches nearly 100%. Patients with 3 or more co-existing risk factors fall into an extreme-risk tier.
Risk Progression Velocity (`score_increase`): Using the `LAG()` function to track shifts between age cohorts showed that the average risk score doesn't just grow linearly; it spikes during the transition into the 55-64 and 65+ brackets, with men experiencing an earlier onset of high composite risk scores than women.
