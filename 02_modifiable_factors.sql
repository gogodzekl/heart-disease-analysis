SELECT 
  CASE WHEN num>0 THEN 'Diseased' ELSE 'Healthy' END AS status,
  ROUND (AVG(chol)::numeric, 1) AS avg_cholesterol,
  ROUND (AVG(trestbps)::numeric,1) AS avg_blood_pressure,
  ROUND (COUNT(CASE WHEN fbs = 'TRUE' THEN 1 END) * 100.0/ COUNT(*), 1) AS high_sugar_pct
FROM heart
WHERE chol > 0 AND trestbps > 0
GROUP BY status;