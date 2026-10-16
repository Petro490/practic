--задание 1
-- задача 1.1
SELECT i.name
FROM order_items oi
JOIN items i ON oi.item_id = i.id
GROUP BY i.name
ORDER BY SUM(oi.quantity) DESC
LIMIT 1;

--Tesla Model 3 (Количество продаж: 7)

--задача 1.2
SELECT o.start_date
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
GROUP BY o.start_date
ORDER BY SUM(oi.quantity) DESC
LIMIT 1;

--2020-03-01 (Количество продаж в этот день: 5)
--задача 1.3
SELECT u.first_name
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
JOIN users u ON o.user_id = u.id
GROUP BY u.first_name, u.id
ORDER BY SUM(oi.quantity) DESC
LIMIT 1;

--John (Куплено машин: 3)

--задача 1.4
SELECT u.city
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
JOIN users u ON o.user_id = u.id
GROUP BY u.city
ORDER BY SUM(oi.quantity) DESC
LIMIT 1;

--Los Angeles (Куплено машин: 5)

--Задание 1.5
SELECT ROUND(AVG(i.price)::numeric, 2) AS max_avg_price
FROM order_items oi
JOIN items i ON oi.item_id = i.id
JOIN orders o ON oi.order_id = o.id
JOIN users u ON o.user_id = u.id
GROUP BY u.city
ORDER BY max_avg_price DESC
LIMIT 1;

--74990 (Для городов New York и Boston)
--или
SELECT city, max_avg_price
FROM (
    SELECT 
        u.city,
        ROUND(AVG(i.price)::numeric, 2) AS max_avg_price,
        -- Присваиваем 1 место всем городам с одинаковой максимальной ценой
        DENSE_RANK() OVER (ORDER BY ROUND(AVG(i.price)::numeric, 2) DESC) AS price_rank
    FROM order_items oi
    JOIN items i ON oi.item_id = i.id
    JOIN orders o ON oi.order_id = o.id
    JOIN users u ON o.user_id = u.id
    GROUP BY u.city
) subquery
WHERE price_rank = 1;




--Для оптимизации создадим индексы
-- Индексы для таблицы заказов (orders)
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_start_date ON orders(start_date);

-- Индексы для таблицы позиций заказа (order_items)
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_item_id ON order_items(item_id);

-- Индекс для фильтрации/группировки по городам в таблице пользователей
CREATE INDEX IF NOT EXISTS idx_users_city ON users(city);

--Чтобы не выполнять пять отдельных тяжелых запросов, мы можем объединить все таблицы один раз с помощью JOIN, а затем использовать оконные функции

WITH base_metrics AS (
    SELECT 
        i.name AS item_name,
        o.start_date,
        u.first_name AS user_name,
        u.city,
        oi.quantity,
        i.price
    FROM order_items oi
    JOIN items i ON oi.item_id = i.id
    JOIN orders o ON oi.order_id = o.id
    JOIN users u ON o.user_id = u.id
),
top_item AS (
    SELECT item_name FROM base_metrics GROUP BY item_name ORDER BY SUM(quantity) DESC LIMIT 1
),
top_date AS (
    SELECT start_date FROM base_metrics GROUP BY start_date ORDER BY SUM(quantity) DESC LIMIT 1
),
top_user AS (
    SELECT user_name FROM base_metrics GROUP BY user_name ORDER BY SUM(quantity) DESC LIMIT 1
),
top_city_cars AS (
    SELECT city FROM base_metrics GROUP BY city ORDER BY SUM(quantity) DESC LIMIT 1
),
top_city_price AS (
    SELECT city, ROUND(AVG(price)::numeric, 2) AS avg_price 
    FROM base_metrics 
    GROUP BY city 
    ORDER BY avg_price DESC LIMIT 1
)
SELECT 
    (SELECT item_name FROM top_item) AS most_selling_model,
    (SELECT start_date FROM top_date) AS peak_sales_date,
    (SELECT user_name FROM top_user) AS top_buyer_name,
    (SELECT city FROM top_city_cars) AS top_city_by_cars,
    (SELECT city FROM top_city_price) AS top_city_by_price,
    (SELECT avg_price FROM top_city_price) AS max_average_price;

--
--Результат выполнения единого запроса:
--most_selling_model	peak_sales_date	top_buyer_name	top_city_by_cars	top_city_by_price	max_average_price
--Tesla Model 3	         2020-03-01	     John	           Los Angeles	         New York (или Boston)

--Задача2
--Задание 2.1
SELECT u.first_name || ' from ' || u.city AS user_location
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
JOIN users u ON o.user_id = u.id
GROUP BY u.first_name, u.city, u.id
ORDER BY SUM(oi.quantity) DESC
LIMIT 1;

--John from Los Angeles

--задание 2.2

SELECT LENGTH(email) AS email_length
FROM users
WHERE id = 9;

-- ответ 19

--задание 2.3
UPDATE users
SET email = REPLACE(email, 'example', 'tesla');


--Задача 3
--задание 3.1
-- Создание представления
CREATE OR REPLACE VIEW los_angeles_users AS
SELECT *
FROM users
WHERE city = 'Los Angeles';

-- Обращение к созданному представлению
SELECT * FROM los_angeles_users;


--Задание 3.2
-- Создание табличного выражения и немедленное обращение к нему
WITH los_angeles_users_cte AS (
    SELECT *
    FROM users
    WHERE city = 'Los Angeles'
)
SELECT * FROM los_angeles_users_cte;


--немного улучим запросы с рассчетом на будщее расширение
-- 1. Создаем материализованное представление
CREATE MATERIALIZED VIEW mv_los_angeles_users AS
SELECT id, first_name, last_name, email, city  -- Рекомендуется перечислять колонки явно
FROM users
WHERE city = 'Los Angeles';

-- 2. Создаем обязательный УНИКАЛЬНЫЙ индекс по колонке id
CREATE UNIQUE INDEX idx_mv_la_users_id ON mv_los_angeles_users(id);

-- 3. Пример быстрого фонового обновления данных (без блокировки запросов SELECT)
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_los_angeles_users;

-- 4. Обращение к представлению (работает мгновенно)
SELECT * FROM mv_los_angeles_users;


--Задача 4 
--задание 4.1.
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_item_id ON order_items(item_id);

--задание 4.2
EXPLAIN SELECT * FROM order_items WHERE order_id = 1 AND item_id = 2;


-- Если в таблице мало строк (как в текущем тестовом датасете), 
-- планировщик может выбрать последовательное сканирование (Seq Scan), так как оно быстрее для крошечных объемов.

-- Для детального анализа со сбором реального времени выполнения используйте:
EXPLAIN ANALYZE SELECT * FROM order_items WHERE order_id = 1 AND item_id = 2;

--"Seq Scan on order_items  (cost=0.00..1.20 rows=1 width=16) (actual time=0.027..0.030 rows=1 loops=1)"
--"  Filter: ((order_id = 1) AND (item_id = 2))"
--"  Rows Removed by Filter: 12"
--"Planning Time: 0.176 ms"
--"Execution Time: 0.055 ms"


-- Задача 5
--задание 5.1

SELECT 
    id,
    name,
    price,
    RANK() OVER (ORDER BY price DESC) AS price_rank
FROM items;

--Задание 5.2

WITH daily_sales AS (
    SELECT 
        o.start_date AS order_date,
        SUM(oi.quantity) AS daily_cars_sold
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.id
    GROUP BY o.start_date
)
SELECT 
    order_date,
    daily_cars_sold,
    SUM(daily_cars_sold) OVER (ORDER BY order_date ASC) AS cumulative_cars_sold
FROM daily_sales
ORDER BY order_date ASC;


--ВСе кода работают, проверно в PostgreSql




