CREATE TABLE query (
    searchid SERIAL PRIMARY KEY,
    year INT,
    month INT,
    day INT,
    userid INT,
    ts BIGINT,
    devicetype VARCHAR(50),
    deviceid VARCHAR(100),
    query VARCHAR(255),
    is_final INT
);


INSERT INTO query (year, month, day, userid, ts, devicetype, deviceid, query) VALUES
(2024, 11, 25, 1, 1698321600, 'android', 'device_001', 'к'),
(2024, 11, 25, 1, 1698321660, 'android', 'device_001', 'ку'),
(2024, 11, 25, 1, 1698321720, 'android', 'device_001', 'куп'),
(2024, 11, 25, 1, 1698321780, 'android', 'device_001', 'купить'),
(2024, 11, 25, 1, 1698321840, 'android', 'device_001', 'купить кур'),
(2024, 11, 25, 1, 1698321900, 'android', 'device_001', 'купить куртку'),
(2024, 11, 25, 2, 1698321600, 'android', 'device_002', 'к'),
(2024, 11, 25, 2, 1698321660, 'android', 'device_002', 'ку'),
(2024, 11, 25, 2, 1698321720, 'android', 'device_002', 'куп'),
(2024, 11, 25, 2, 1698321780, 'android', 'device_002', 'купить'),
(2024, 11, 25, 2, 1698321840, 'android', 'device_002', 'купить кур'),
(2024, 11, 25, 2, 1698322000, 'android', 'device_002', 'купить куртку'),
(2024, 11, 25, 3, 1698321600, 'android', 'device_003', 'к'),
(2024, 11, 25, 3, 1698321660, 'android', 'device_003', 'ку'),
(2024, 11, 25, 3, 1698321720, 'android', 'device_003', 'куп'),
(2024, 11, 25, 3, 1698321780, 'android', 'device_003', 'купить'),
(2024, 11, 25, 3, 1698321900, 'android', 'device_003', 'купить кур'),
(2024, 11, 25, 3, 1698322020, 'android', 'device_003', 'купить куртку');



WITH ranked_queries AS (
    SELECT 
        q.searchid,
        q.year,
        q.month,
        q.day,
        q.userid,
        q.ts,
        q.devicetype,
        q.deviceid,
        q.query,
        LEAD(q.query) OVER (PARTITION BY q.userid, q.deviceid ORDER BY q.ts) AS next_query,
        LEAD(q.ts) OVER (PARTITION BY q.userid, q.deviceid ORDER BY q.ts) AS next_ts
    FROM 
        query q
)
UPDATE query q
SET 
    is_final = CASE
        -- Если прошло более 3-х минут или это последний запрос
        WHEN (rq.next_ts - q.ts) > 180 OR rq.next_query IS NULL THEN 1
        -- Если следующий запрос короче и прошло более минуты
        WHEN LENGTH(rq.next_query) < LENGTH(q.query) AND (rq.next_ts - q.ts) > 60 THEN 2
        ELSE 0
    END
FROM ranked_queries rq
WHERE q.searchid = rq.searchid;





WITH ranked_queries AS (
    SELECT 
        q.searchid,
        q.year,
        q.month,
        q.day,
        q.userid,
        q.ts,
        q.devicetype,
        q.deviceid,
        q.query,
        LEAD(q.query) OVER (PARTITION BY q.userid, q.deviceid ORDER BY q.ts) AS next_query,
        LEAD(q.ts) OVER (PARTITION BY q.userid, q.deviceid ORDER BY q.ts) AS next_ts
    FROM 
        query q
)
SELECT 
    q.year, 
    q.month, 
    q.day, 
    q.userid, 
    q.ts, 
    q.devicetype, 
    q.deviceid, 
    q.query, 
    rq.next_query, 
    q.is_final
FROM 
    query q
JOIN 
    ranked_queries rq ON q.searchid = rq.searchid
WHERE 
    q.year = 2024 
    AND q.month = 11 
    AND q.day = 25
    AND q.devicetype = 'android'
    AND (q.is_final = 1 OR q.is_final = 2)
ORDER BY 
    q.ts;
