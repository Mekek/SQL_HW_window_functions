CREATE TABLE salary (
    id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    salary NUMERIC,
    industry VARCHAR(100)
);

\COPY salary FROM 'Salary.csv' DELIMITER ',' CSV HEADER;

SELECT 
    s.first_name, 
    s.last_name, 
    s.salary, 
    s.industry, 
    (
        SELECT first_name
        FROM salary s2
        WHERE s2.salary = (SELECT MIN(salary) FROM salary s3 WHERE s3.industry = s.industry)
        AND s2.industry = s.industry
        LIMIT 1
    ) AS name_lowest_sal
FROM 
    salary s
ORDER BY 
    s.industry;
