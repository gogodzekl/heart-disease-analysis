SELECT 
sex,
CASE 
  WHEN age < 45 THEN 'under 45'
  WHEN age BETWEEN 45 AND 54 THEN '45-54'
  WHEN age BETWEEN 55 AND 64 THEN '55-64'
  ELSE '65+'
END AS age_group,
  COUNT(*) AS total_patients,
  SUM (CASE WHEN num>0 THEN 1 ELSE 0 END) AS diseased,
  ROUND (SUM(CASE WHEN num>0 THEN 1 ELSE 0 END)*100.0/ COUNT(*),1) AS disease_rate_pct
FROM heart
GROUP BY sex, age_group
ORDER BY sex, age_group;