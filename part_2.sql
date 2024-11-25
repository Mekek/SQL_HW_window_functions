CREATE TABLE goods (
    id_good BIGINT PRIMARY KEY,
    category VARCHAR(100),
    good_name VARCHAR(100),
    price NUMERIC
);

CREATE TABLE sales (
    date DATE,
    shopnumber INT,
    id_good BIGINT,
    qty INT
);

CREATE TABLE shops (
    shopnumber INT PRIMARY KEY,
    city VARCHAR(100),
    address VARCHAR(255)
);

-- Загрузка данных из CSV файлов
\COPY goods FROM 'path_to_GOODS.csv' DELIMITER ',' CSV HEADER;
\COPY sales FROM 'path_to_SALES.csv' DELIMITER ',' CSV HEADER;
\COPY shops FROM 'path_to_SHOPS.csv' DELIMITER ',' CSV HEADER;






SELECT 
    s.shopnumber, 
    sh.city, 
    sh.address, 
    SUM(sa.qty) AS sum_qty, 
    SUM(sa.qty * g.price) AS sum_qty_price
FROM 
    sales sa
JOIN 
    goods g ON sa.id_good = g.id_good
JOIN 
    shops sh ON sa.shopnumber = sh.shopnumber
WHERE 
    sa.date = '2016-01-02'
GROUP BY 
    s.shopnumber, sh.city, sh.address
ORDER BY 
    s.shopnumber;








WITH total_sales AS (
    SELECT 
        date, 
        SUM(s.qty * g.price) AS total_sales_value
    FROM 
        sales s
    JOIN 
        goods g ON s.id_good = g.id_good
    WHERE 
        g.category = 'ЧИСТОТА'
    GROUP BY 
        date
)
SELECT 
    s.date AS date_, 
    sh.city, 
    SUM(s.qty * g.price) / ts.total_sales_value AS sum_sales_rel
FROM 
    sales s
JOIN 
    goods g ON s.id_good = g.id_good
JOIN 
    shops sh ON s.shopnumber = sh.shopnumber
JOIN 
    total_sales ts ON s.date = ts.date
WHERE 
    g.category = 'ЧИСТОТА'
GROUP BY 
    s.date, sh.city, ts.total_sales_value
ORDER BY 
    s.date, sh.city;





WITH ranked_sales AS (
    SELECT 
        s.date, 
        s.shopnumber, 
        s.id_good, 
        SUM(s.qty) AS total_qty,
        RANK() OVER (PARTITION BY s.date, s.shopnumber ORDER BY SUM(s.qty) DESC) AS rank
    FROM 
        sales s
    GROUP BY 
        s.date, s.shopnumber, s.id_good
)
SELECT 
    rs.date AS date_, 
    rs.shopnumber, 
    rs.id_good
FROM 
    ranked_sales rs
WHERE 
    rs.rank <= 3
ORDER BY 
    rs.date, rs.shopnumber, rs.rank;






WITH prev_sales AS (
    SELECT 
        s.shopnumber, 
        s.date, 
        g.category, 
        SUM(s.qty * g.price) AS sales_value
    FROM 
        sales s
    JOIN 
        goods g ON s.id_good = g.id_good
    JOIN 
        shops sh ON s.shopnumber = sh.shopnumber
    WHERE 
        sh.city = 'СПб'
    GROUP BY 
        s.shopnumber, s.date, g.category
),
prev_sales_date AS (
    SELECT 
        ps.shopnumber, 
        ps.category, 
        ps.sales_value,
        ps.date,
        LAG(ps.sales_value) OVER (PARTITION BY ps.shopnumber, ps.category ORDER BY ps.date) AS prev_sales_value
    FROM 
        prev_sales ps
)
SELECT 
    psd.date AS date_, 
    psd.shopnumber, 
    psd.category, 
    COALESCE(psd.prev_sales_value, 0) AS prev_sales
FROM 
    prev_sales_date psd
ORDER BY 
    psd.date, psd.shopnumber, psd.category;
