-- Identify missing or nulls
SELECT COUNT(*) AS null_count, 
       SUM(CASE WHEN MonthlyIncome IS NULL THEN 1 ELSE 0 END) AS missing_income
FROM `hr_staging`;

-- Distinct counts for key categories
SELECT Department, COUNT(*) AS cnt
FROM `hr_staging`
GROUP BY Department;

-- Normalize Categorical Flags --
CREATE TABLE hr_clean AS
SELECT
  `EmployeeNumber`,
  Age,
  CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END AS churn_flag,
  Department,
  JobRole,
  MonthlyIncome,
  CASE WHEN OverTime = 'Yes' THEN 1 ELSE 0 END AS overtime_flag,
  TotalWorkingYears AS years_at_company,
  EnvironmentSatisfaction,
  PerformanceRating
  /* …other feature mappings… */
FROM `hr_staging`
WHERE `EmployeeNumber` IS NOT NULL;

-- Attrition by Department & Role
CREATE VIEW v_attrition_summary AS
SELECT
  `Department`,
  `JobRole`,
  ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2) AS attrition_pct,
  COUNT(*) AS headcount
FROM `hr_clean`
GROUP BY `Department`, `JobRole`;

-- KPI Calculation --
-- 3.1 Overall Churn Rate
SELECT 
  ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2) AS overall_attrition_pct
FROM `hr_clean`;

-- 3.2 Overtime vs. No-Overtime Attrition
SELECT
  overtime_flag,
  ROUND(100.0 * SUM(churn_flag) / COUNT(*), 2) AS attrition_pct
FROM `hr_clean`
GROUP BY overtime_flag;

-- 3.3 Tenure & Income Comparison
SELECT
  AVG(CASE WHEN churn_flag = 1 THEN years_at_company END) AS avg_tenure_exited,
  AVG(CASE WHEN churn_flag = 0 THEN years_at_company END) AS avg_tenure_retained,
  AVG(CASE WHEN churn_flag = 1 THEN MonthlyIncome END)     AS avg_income_exited,
  AVG(CASE WHEN churn_flag = 0 THEN MonthlyIncome END)     AS avg_income_retained
FROM `hr_clean`;

