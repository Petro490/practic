--Для удобного и наглядного решения задач создадим базу texts_database.db 
--Задача 1
SELECT 
    id,
    word AS "Исходный текст",
    -- Из длины строки вычитаем длину строки без пробелов и прибавляем 1
    LENGTH(word) - LENGTH(REPLACE(word, ' ', '')) + 1 AS word_count
FROM texts;

--Задача 2

SELECT 
    word, 
    COUNT(*) AS word_count
FROM texts
GROUP BY word
HAVING COUNT(*) > 10
ORDER BY word_count DESC;
 -- или для проверки запроса
SELECT 
    word, 
    COUNT(*) AS word_count
FROM texts
GROUP BY word
HAVING COUNT(*) > 0
ORDER BY word_count DESC;

--Задача 3
SELECT 
    id,
    word AS "Исходный текст",
    ROUND(
        LENGTH(REPLACE(word, ' ', '')) * 1.0 / 
        (LENGTH(word) - LENGTH(REPLACE(word, ' ', '')) + 1), 
        2
    ) AS avg_word_length
FROM texts;

--Задача 4
-- Создаем временный набор данных, так как у нас в базе этой таблицы нет
WITH users_list AS (
    SELECT 1 AS id, 'Алексей' AS name UNION ALL
    SELECT 2, 'Иван' UNION ALL
    SELECT 3, 'Михаил' UNION ALL
    SELECT 4, 'Антон' UNION ALL
    SELECT 5, 'Василий' UNION ALL
    SELECT 6, 'Иван'
)
SELECT 
    id,
    name,
    DENSE_RANK() OVER (ORDER BY name ASC) AS alphabet_rank
FROM users_list;


--Задача 5 Для PostgreSQL
-- Тестируем на временной строке 'Smith, John'
WITH test_data AS (
    SELECT 'Smith, John'::VARCHAR AS full_name
)
SELECT 
    -- Вырезаем часть ДО запятой (Фамилия) и форматируем
    INITCAP(TRIM(split_part(full_name, ',', 1))) AS last_name,
    
    -- Вырезаем часть ПОСЛЕ запятой (Имя) и форматируем
    INITCAP(TRIM(split_part(full_name, ',', 2))) AS first_name
FROM test_data;

--Задача 5 для SQLlite
WITH test_data AS (
    SELECT 'Smith, John' AS full_name
)
SELECT 
    -- Фамилия (все до запятой): первую букву в верхний регистр, остальное в нижний
    UPPER(SUBSTR(TRIM(SUBSTR(full_name, 1, INSTR(full_name, ',') - 1)), 1, 1)) || 
    LOWER(SUBSTR(TRIM(SUBSTR(full_name, 1, INSTR(full_name, ',') - 1)), 2)) AS last_name,
    
    -- Имя (все после запятой): первую букву в верхний регистр, остальное в нижний
    UPPER(SUBSTR(TRIM(SUBSTR(full_name, INSTR(full_name, ',') + 1)), 1, 1)) || 
    LOWER(SUBSTR(TRIM(SUBSTR(full_name, INSTR(full_name, ',') + 1)), 2)) AS first_name
FROM test_data;


--Все задания работают








