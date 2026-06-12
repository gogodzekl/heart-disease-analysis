SELECT 
  CASE WHEN num>0 THEN 'Diseased' ELSE 'Healthy' END AS status,
  -- числовые маркеры
  ROUND(AVG(thalch)::numeric, 1) AS avg_max_heartrate,
  ROUND(AVG(oldpeak)::numeric, 2) AS avg_st_depression,
  -- тип боли в груди
  ROUND (COUNT (CASE WHEN cp= 'typical angina' THEN 1 END) * 100.0/ COUNT (*), 1) AS typical_angina_pct,
  ROUND (COUNT (CASE WHEN cp= 'asymptomatic' THEN 1 END) * 100.0/ COUNT(*), 1) AS asymptomatic_pct,
  -- стенокардия при нагрузке
  ROUND(COUNT(CASE WHEN exang = 'TRUE' THEN 1 END) * 100.0 / COUNT(*), 1) AS exercise_angina_pct,
  -- ЭКГ
  ROUND(COUNT(CASE WHEN restecg = 'lv hypertrophy' THEN 1 END) * 100.0 / COUNT(*), 1) AS lv_hypertrophy_pct,
  ROUND(COUNT(CASE WHEN restecg = 'st-t abnormality' THEN 1 END) * 100.0 / COUNT(*), 1) AS st_abnormality_pct,
  -- Таллиевый тест
  ROUND(COUNT(CASE WHEN thal = 'reversable defect' THEN 1 END) * 100.0 / COUNT(*), 1) AS reversable_defect_pct,
  ROUND(COUNT(CASE WHEN thal = 'fixed defect' THEN 1 END) * 100.0 / COUNT(*), 1) AS fixed_defect_pct,
  -- Поражённые сосуды
  ROUND(AVG(ca)::numeric, 1) AS avg_vessels_affected
  FROM heart
  WHERE thalch>0
  GROUP BY status;