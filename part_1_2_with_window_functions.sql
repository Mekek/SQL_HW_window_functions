DROP TABLE IF EXISTS salary CASCADE;

CREATE TABLE salary (
    id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    salary NUMERIC,
    industry VARCHAR(100)
);

COPY salary FROM 'C:\\Code\\WB\\SQL_HW_3\\Salary.csv' DELIMITER ',' CSV HEADER;

WITH min_salary_per_industry AS (
    SELECT industry, MIN(salary) AS min_salary
    FROM salary
    GROUP BY industry
)
SELECT 
    s.first_name, 
    s.last_name, 
    s.salary, 
    s.industry, 
    FIRST_VALUE(s.first_name) OVER (PARTITION BY s.industry ORDER BY s.salary ASC) AS name_lowest_sal
FROM 
    salary s
JOIN min_salary_per_industry m
    ON s.industry = m.industry
    AND s.salary = m.min_salary
ORDER BY 
    s.industry, s.salary ASC;
