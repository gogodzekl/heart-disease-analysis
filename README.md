# Ischemic Heart Disease — Risk Factor Analysis

A data analytics project on the UCI Heart Disease dataset (920 patients, 
16 clinical attributes), built across two tools: PostgreSQL and Excel. 
The project covers the full analytical pipeline — from data quality 
assessment to interactive dashboard and risk scoring.

## Project Goal
Identify key demographic and clinical drivers of Ischemic Heart Disease, 
build a multi-factor risk scoring model, and visualize findings through 
an interactive Excel dashboard.

## Dataset
`heart_disease_uci.csv` — public UCI dataset including:
- **Demographics**: age, sex
- **Clinical Markers**: cholesterol, blood pressure, ECG results, 
max heart rate, ST depression, exercise angina, Thallium stress test
- **Target**: `num` — diagnosis (0 = healthy, >0 = diseased)

---

## Part 1 — SQL Analysis (PostgreSQL)

### Repository Structure
1. `01_sex_age_analysis.sql` — Disease rate by sex and age group
2. `02_modifiable_factors.sql` — Cholesterol, BP, fasting blood sugar vs diagnosis
3. `03_clinical_markers.sql` — ECG patterns, exercise angina, Thallium stress test, fluoroscopy
4. `04_risk_score_cte.sql` — Multi-factor risk scoring engine using CTEs
5. `05_risk_ranking.sql` — Risk progression across age cohorts using Window Functions

### Key SQL Concepts Demonstrated
- **CTEs** — multi-layer Common Table Expressions for population averages 
and risk score calculation
- **CROSS JOIN** — dynamic baseline comparison against population averages
- **Window Functions** — `LAG() OVER (PARTITION BY sex ORDER BY age_group)` 
for tracking risk progression across aging cohorts
- **DENSE_RANK()** — patient ranking within demographic segments
- **Conditional Aggregation** — `CASE WHEN` inside `SUM()` for disease 
rate calculations
- **Data Quality** — handling missing values coded as 0 via `WHERE chol > 0`

### Highlighted Query — Risk Scoring Engine (`04_risk_score_cte.sql`)
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
    ROUND(SUM(CASE WHEN num > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) 
    AS disease_rate_pct
FROM risk_score
GROUP BY total_risk_score
ORDER BY total_risk_score;
```

---

## Part 2 — Excel Dashboard & Analysis

### Workbook Structure
- **Raw Data** — Source data as structured Excel Table (HeartData)
- **Data Quality** — Dynamic missing value assessment using COUNTIF, COUNTBLANK
- **Analysis** — Risk Score per patient replicating SQL logic via IF, AVERAGEIFS
- **Pivot Tables** — Disease rate by Risk Score, Age/Sex breakdown, Chest Pain Type
- **Dashboard** — Interactive charts, KPI cards, and Slicers
- **Patient Lookup** — VLOOKUP-based patient search with conditional formatting
- **Summary Stats** — Clinical indicators by sex and diagnosis using AVERAGEIFS, COUNTIFS

### Key Excel Skills Demonstrated
- **Power Query** — data transformation and cleaning pipeline
- **VLOOKUP, IFERROR** — interactive patient lookup tool
- **AVERAGEIFS, COUNTIFS** — multi-condition clinical aggregations
- **Pivot Tables + Slicers** — interactive filtering across all charts
- **Conditional Formatting** — risk level visualization (green/yellow/red)
- **Dashboard design** — KPI cards, grouped charts, key findings panel

---

## Key Findings
- Males show ~2.4x higher disease rate than females across all age groups
- Disease rate reaches 100% at Risk Score 6 — patients with 3+ risk 
factors fall into extreme-risk tier
- 79% of asymptomatic patients are diagnosed with heart disease — 
highlighting the danger of silent ischemia
- Max heart rate and ST depression (oldpeak) are the strongest 
clinical markers of IHD

## Tech Stack
PostgreSQL · Microsoft Excel 
