CREATE TABLE salary (
    id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    salary NUMERIC,
    industry VARCHAR(100)
);

\COPY salary FROM 'Salary.csv' DELIMITER ',' CSV HEADER;


SELECT DISTINCT ON (s.industry) 
    s.first_name, 
    s.last_name, 
    s.salary, 
    s.industry, 
    FIRST_VALUE(s.first_name) OVER (PARTITION BY s.industry ORDER BY s.salary DESC) AS name_highest_sal
FROM 
    salary s
ORDER BY 
    s.industry, s.salary DESC;