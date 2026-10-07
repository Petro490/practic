--задание 1.1
SELECT DISTINCT id 
FROM hosts 
WHERE host_since = '2020-04-06';

--Задание 1.2
SELECT DISTINCT reviewer_id 
FROM reviews 
WHERE date = '2020-04-06';

--Задание 1.3
SELECT COUNT(*) FROM (
    SELECT id FROM hosts WHERE host_since = '2020-04-06'
    UNION ALL
    SELECT reviewer_id FROM reviews WHERE date = '2020-04-06'
) as combined_all;
--Число 7

--Задание 1.4
SELECT COUNT(*) FROM (
    SELECT id FROM hosts WHERE host_since = '2020-04-06'
    UNION
    SELECT reviewer_id FROM reviews WHERE date = '2020-04-06'
) as unique_combined;
--Число 6

--часть 2
--Задание 2.1
SELECT id FROM hosts
UNION ALL
SELECT reviewer_id FROM reviews;

--Задание 2.2.
SELECT COUNT(*) 
FROM (
    SELECT id FROM hosts
    UNION ALL
    SELECT reviewer_id FROM reviews
) AS total_rows;
--число 236713

--задание 2.3
SELECT COUNT(*) 
FROM (
    SELECT id FROM hosts
    UNION
    SELECT reviewer_id FROM reviews
) AS unique_rows;
--число 222406

--Задача 2
--Задание 2.1
SELECT 
    host_id, 
    COUNT(*) AS listings_count, 
    AVG(price) AS avg_price
FROM listings
GROUP BY host_id;

--Задание 2.2
SELECT *
FROM hosts h
JOIN (
    SELECT 
        host_id, 
        COUNT(*) AS listings_count, 
        AVG(price) AS avg_price
FROM listings
GROUP BY host_id
) l ON h.id = l.host_id;

--или
WITH listings_summary AS (
    SELECT 
        host_id, 
        COUNT(*) AS listings_count, 
        AVG(price) AS avg_price  
    FROM listings  
    GROUP BY host_id  
)
SELECT *
FROM hosts h  
JOIN listings_summary l ON h.id = l.host_id;

--Задание 2.3
SELECT 
    id AS host_id,
    host_since AS registration_date,
    name as name_host,
    l.listings_count,
    l.avg_price
FROM hosts h
JOIN (
    SELECT 
        host_id, 
        COUNT(*) AS listings_count, 
        AVG(price) AS avg_price
    FROM listings
    GROUP BY host_id
) l ON h.id = l.host_id;

--Задача3
--Задание 3.1
SELECT *
FROM reviews r
JOIN listings l ON r.listing_id = l.id
JOIN hosts h ON l.host_id = h.id;

--Задание 3.2
SELECT COUNT(DISTINCT l.host_id) AS unique_hosts_count
FROM reviews r
JOIN listings l ON r.listing_id = l.id;

--число 2764

--Задание 3.3
SELECT COUNT(DISTINCT l.host_id) AS unique_hosts_2020
FROM reviews r
JOIN listings l ON r.listing_id = l.id
WHERE r.date BETWEEN '2020-01-01' AND '2020-12-31';


--число 874

--Задание 3.4
SELECT COUNT(DISTINCT l.host_id) AS unique_hosts_expensive
FROM reviews r
JOIN listings l ON r.listing_id = l.id
WHERE l.price >= 100

--число 1240

--Задание 3.5
SELECT COUNT(DISTINCT l.host_id) AS unique_superhosts_expensive
FROM reviews r
JOIN listings l ON r.listing_id = l.id
JOIN hosts h ON l.host_id = h.id
WHERE l.price >= 100 AND h.is_super_host = 't'

--число 248

--Задание 3.6
SELECT COUNT(DISTINCT l.host_id) AS unique_superhosts_expensive_2020
FROM reviews r
JOIN listings l ON r.listing_id = l.id
JOIN hosts h ON l.host_id = h.id
WHERE l.price >= 100 
  AND h.is_super_host = 't' 
  AND r.date LIKE '2020%'

--число 166

--Часть2
--Задание 3.1
SELECT *
FROM reviews
WHERE reviewer_id IN (SELECT id FROM hosts)

--задание 3.2
SELECT COUNT(*) AS total_reviews_by_hosts
FROM reviews
WHERE reviewer_id IN (SELECT id FROM hosts)

--число 263

--Задание 3.3
SELECT COUNT(DISTINCT reviewer_id) AS unique_hosts_authors
FROM reviews
WHERE reviewer_id IN (SELECT id FROM hosts)

--Число 196

--Задание 3.4
SELECT reviewer_id AS top_host_id
FROM reviews
WHERE reviewer_id IN (SELECT id FROM hosts)
GROUP BY reviewer_id
ORDER BY COUNT(*) DESC
LIMIT 1

--число  151687500

--Задание 3.5
SELECT COUNT(*) AS max_reviews_count
FROM reviews
WHERE reviewer_id IN (SELECT id FROM hosts)
GROUP BY reviewer_id
ORDER BY COUNT(*) DESC
LIMIT 1

--число 14
----------
--Решение можно было вывести и одним кодом в принципе, так требуются минимумы и максиму, содержащие по одной строке, для таблицы это читаемо.
SELECT 
    -- Задача 3.2: Сколько всего таких отзывов получилось?
    (SELECT COUNT(*) 
     FROM reviews 
     WHERE reviewer_id IN (SELECT id FROM hosts)) AS task_3_2_total_reviews,

    -- Задача 3.3: Сколько уникальных авторов оставили свой отзыв?
    (SELECT COUNT(DISTINCT reviewer_id) 
     FROM reviews 
     WHERE reviewer_id IN (SELECT id FROM hosts)) AS task_3_3_unique_authors,

    -- Задача 3.4: Кто из хостов оставил больше всего отзывов? (Укажите его id)
    (SELECT reviewer_id 
     FROM reviews 
     WHERE reviewer_id IN (SELECT id FROM hosts)
     GROUP BY reviewer_id 
     ORDER BY COUNT(*) DESC 
     LIMIT 1) AS task_3_4_top_host_id,

    -- Задача 3.5: Сколько отзывов он оставил?
    (SELECT COUNT(*) 
     FROM reviews 
     WHERE reviewer_id IN (SELECT id FROM hosts)
     GROUP BY reviewer_id 
     ORDER BY COUNT(*) DESC 
     LIMIT 1) AS task_3_5_max_reviews_count
---------------------

--Задание 4 выполним едим запросом
SELECT 
    -- Задача 4.1: Количество жилья с ценой ВЫШЕ средней
    (SELECT COUNT(*) 
     FROM listings 
     WHERE price > (SELECT AVG(price) FROM listings)) AS above_average,

    -- Задача 4.2: Количество жилья с ценой НИЖЕ средней
    (SELECT COUNT(*) 
     FROM listings 
     WHERE price < (SELECT AVG(price) FROM listings)) AS below_average


--4.1 Число 2500
--4.2 Число 6461


