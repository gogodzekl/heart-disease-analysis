WITH 
age_groups AS (
 SELECT *,
   CASE WHEN age < 45 THEN 'Under 45'
   WHEN age BETWEEN 45 and 54 THEN '45-54'
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
    ROUND (AVG(total_risk_score):: numeric,1) AS avg_risk_score,
    ROUND (SUM(CASE WHEN num>0 THEN 1 ELSE 0 END)*100.0/COUNT (*),1) AS disease_rate_pct
  FROM risk_score
  GROUP BY sex, age_group)
 SELECT sex, age_group, avg_risk_score, disease_rate_pct,
    LAG (avg_risk_score) OVER (PARTITION BY sex ORDER BY age_group) AS prev_age_group_score,
	ROUND ((avg_risk_score - LAG (avg_risk_score) OVER (PARTITION BY sex ORDER BY age_group))::numeric, 1) AS score_increase
 FROM group_stats
 ORDER BY sex, age_group;