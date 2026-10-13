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



