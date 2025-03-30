ALTER TABLE hr.`wa_fn-usec_-hr-employee-attrition` RENAME TO hr.`employee_attrition`;

-- Attrition rate by department
WITH cte AS (
	SELECT Department, COUNT(*) AS employees
    FROM employee_attrition
    GROUP BY Department
),
cte2 AS (
	SELECT Department, COUNT(*) AS employees_attrition
    FROM employee_attrition
	WHERE Attrition = 'Yes'
	GROUP BY Department
)
    
SELECT c1.Department, ROUND((COALESCE(c2.employees_attrition, 0) / c1.employees) * 100, 2) AS attrition_rate
FROM cte c1 LEFT JOIN cte2 c2 ON c1.Department = c2.Department
ORDER BY attrition_rate DESC;

-- Impact of OverTime in attrition
SELECT attrition, ROUND((SUM(CASE WHEN OverTime = 'Yes' THEN 1 ELSE 0 END)/COUNT(*)) * 100, 2) AS overtime_rate
FROM employee_attrition
GROUP BY Attrition;

-- Impact of years of experience on performance
SELECT YearsAtCompany, ROUND(AVG(PerformanceRating), 2) AS avg_performance
FROM EmployeeData
GROUP BY YearsAtCompany
ORDER BY YearsAtCompany;

-- Attrition rate by years at company
SELECT YearsAtCompany, ROUND(SUM(CASE WHEN Attrition = "Yes" THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM employee_attrition
GROUP BY YearsAtCompany
ORDER BY attrition_rate DESC;

-- overTime rate and attrition rate comparaison
SELECT yearsAtCompany, ROUND(SUM(CASE WHEN OverTime = "Yes" THEN 1 ELSE 0 END) / COUNT(*), 2) AS over_time_rate, 
	   ROUND(SUM(CASE WHEN attrition = "Yes" THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM employee_attrition
GROUP BY yearsAtCompany ;

-- average income (attrition, non-attrition)
SELECT attrition, ROUND(AVG(MonthlyIncome)) as monthly_income
FROM employee_attrition
GROUP BY attrition;

-- Imapct of monthly income in the attrition
CREATE TEMPORARY TABLE temp AS
SELECT *, CASE WHEN MonthlyIncome <= 2500 THEN "bas"
			   WHEN MonthlyIncome > 2500 AND MonthlyIncome <= 5000 THEN "Moyen-bas"
               WHEN  MonthlyIncome > 5000 AND MonthlyIncome <= 7500 THEN "Moyen"
               WHEN MonthlyIncome > 7500 AND MonthlyIncome <= 10000 THEN "Moyen-haut"
               WHEN MonthlyIncome > 10000 THEN "haut" END AS income_cat
FROM employee_attrition;

SELECT income_cat, ROUND(SUM(CASE WHEN Attrition = "Yes" THEN 1 ELSE 0 END) / COUNT(*) * 100) AS attrition_rate
FROM temp
GROUP BY income_cat;

-- Attrition rate by age_cat
CREATE TEMPORARY TABLE temp2 AS
SELECT *, CASE WHEN `ï»¿Age` >= 18 AND `ï»¿Age`< 23 THEN "18-23"
		       WHEN `ï»¿Age` >= 23 AND `ï»¿Age`< 28 THEN "23-28"
               WHEN `ï»¿Age` >= 28 AND `ï»¿Age`< 33 THEN "28-33"
               WHEN `ï»¿Age` >= 33 AND `ï»¿Age`< 38 THEN "33-38"
               WHEN `ï»¿Age` >= 38 AND `ï»¿Age`< 43 THEN "38-43"
               WHEN `ï»¿Age` >= 43 AND `ï»¿Age`< 49 THEN "43-49"
			   WHEN `ï»¿Age` >= 49 AND `ï»¿Age`< 54 THEN "49-54"
			   WHEN `ï»¿Age` >= 54 AND `ï»¿Age`< 59 THEN "54-59"
			   ELSE "59-64"
			END AS age_cat
FROM employee_attrition;

SELECT age_cat, ROUND(SUM(CASE WHEN Attrition = "Yes" THEN 1 ELSE 0 END) / COUNT(*) * 100) AS attrition_rate
FROM temp2
GROUP BY age_cat;

-- Impact of education level on attrition
SELECT Education, ROUND(SUM(CASE WHEN Attrition = "Yes" THEN 1 ELSE 0 END) / COUNT(*) * 100) AS attrition_rate
FROM employee_attrition
GROUP BY Education
ORDER BY Education;

-- Imapct of work-life-balance on attrition rate
SELECT WorkLifeBalance, ROUND(SUM(CASE WHEN Attrition = "Yes" THEN 1 ELSE 0 END) / COUNT(*) * 100) AS attrition_rate
FROM employee_attrition
GROUP BY WorkLifeBalance
ORDER BY WorkLifeBalance;

-- Impact of performance on attrition rate
SELECT PerformanceRating, ROUND(SUM(CASE WHEN Attrition = "Yes" THEN 1 ELSE 0 END) / COUNT(*) * 100) AS attrition_rate
FROM employee_attrition
GROUP BY PerformanceRating
ORDER BY PerformanceRating;

-- Impact of promotio on attrition rate
SELECT YearsSinceLastPromotion, ROUND(SUM(CASE WHEN Attrition = "Yes" THEN 1 ELSE 0 END) / COUNT(*) * 100) AS attrition_rate
FROM employee_attrition
GROUP BY YearsSinceLastPromotion
ORDER BY YearsSinceLastPromotion;

-- Impact of distance from home on attrition rate
SELECT DistanceFromHome, ROUND(SUM(CASE WHEN Attrition = "Yes" THEN 1 ELSE 0 END) / COUNT(*) * 100) AS attrition_rate
FROM employee_attrition
GROUP BY DistanceFromHome
ORDER BY DistanceFromHome;

-- attrition rate by job Role
SELECT JobRole, ROUND(SUM(CASE WHEN Attrition = "Yes" THEN 1 ELSE 0 END) / COUNT(*) * 100) AS attrition_rate
FROM employee_attrition
GROUP BY JobRole;

-- Impact of Buisness travel on attrition
SELECT BusinessTravel, ROUND(SUM(CASE WHEN Attrition = "Yes" THEN 1 ELSE 0 END) / COUNT(*) * 100) AS attrition_rate
FROM employee_attrition
GROUP BY BusinessTravel;

-- average daily rate by job role
SELECT JobRole, AVG(DailyRate) AS daily_rate
FROM employee_attrition
GROUP BY 1
ORDER BY 2 DESC;

-- Travel frequency by job role
WITH cte AS (
	SELECT JobRole, SUM(CASE WHEN BusinessTravel = "Travel_Rarely" THEN 1 ELSE 0 END) AS Travel_rarely,
				SUM(CASE WHEN BusinessTravel = "Travel_Frequently" THEN 1 ELSE 0 END) AS Travel_frequently,
                SUM(CASE WHEN BusinessTravel = "Non-Travel" THEN 1 ELSE 0 END) AS Non_travel
	FROM employee_attrition
	GROUP BY 1
)

SELECT JobRole, 
       CASE 
           WHEN Travel_Rarely >= Travel_Frequently AND Travel_Rarely >= Non_Travel THEN 'Travel_Rarely'
           WHEN Travel_Frequently >= Travel_Rarely AND Travel_Frequently >= Non_Travel THEN 'Travel_Frequently'
           ELSE 'Non_Travel'
       END AS Travel
FROM cte;

-- Attrition rate by marital status
SELECT MaritalStatus, ROUND(SUM(CASE WHEN Attrition = "Yes" THEN 1 ELSE 0 END) / COUNT(*) * 100) AS attrition_rate
FROM employee_attrition
GROUP BY 1;

