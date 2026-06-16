 -- total rows
 SELECT COUNT (*) AS total_rows FROM heart;
 -- missing values
 SELECT 
    COUNT (*) AS total_rows,
	COUNT (CASE WHEN age IS NULL OR age = 0 THEN 1 END) AS missing_age,
	COUNT (CASE WHEN sex IS NULL OR sex ='' THEN 1 END) AS missing_sex,
	COUNT (CASE WHEN trestbps IS NULL OR trestbps = 0 THEN 1 END) AS missing_trestbps,
	COUNT (CASE WHEN chol IS NULL OR chol = 0 THEN 1 END) AS missing_chol,
    COUNT (CASE WHEN thalch IS NULL OR thalch = 0 THEN 1 END) AS missing_thalch,
    COUNT (CASE WHEN oldpeak IS NULL THEN 1 END) AS missing_oldpeak,
    COUNT (CASE WHEN ca IS NULL THEN 1 END) AS missing_ca,
    COUNT (CASE WHEN thal IS NULL OR thal = '' THEN 1 END) AS missing_thal 
FROM heart;
-- duplicates
SELECT id, COUNT (*) AS count
FROM heart
GROUP BY  id
HAVING COUNT (*) >1;
-- outliers check

SELECT
    MIN(age) AS min_age, MAX(age) AS max_age,
    MIN(chol) AS min_chol, MAX(chol) AS max_chol,
    MIN(trestbps) AS min_bp, MAX(trestbps) AS max_bp,
    MIN(oldpeak) AS min_oldpeak, MAX(oldpeak) AS max_oldpeak,
    MIN(thalch) AS min_hr, MAX(thalch) AS max_hr
FROM heart;
-- unique values for categorical columns
SELECT DISTINCT cp FROM heart ORDER BY cp;
SELECT DISTINCT thal FROM heart ORDER BY thal;
SELECT DISTINCT restecg FROM heart ORDER BY restecg;
SELECT DISTINCT slope FROM heart ORDER BY slope;
