WITH population_avg AS (
   SELECT 
      AVG (chol)AS avg_chol,
	  AVG (trestbps) AS avg_bp,
	  AVG (oldpeak) AS avg_st
	FROM heart
	WHERE chol>0 AND trestbps>0
),
    risk_score AS (
    SELECT
	h.id, h.age, h.sex, h.num,
	CASE WHEN num>0 THEN 'Diseased' ELSE 'Healthy' END AS status,
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
ORDER BY total_risk_score;