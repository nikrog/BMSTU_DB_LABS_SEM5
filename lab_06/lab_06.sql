-- 1. Выполнить скалярный запрос.
-- Получить среднюю стоимость клубов, созданных ранее 2000 года
SELECT AVG(price)
FROM clubs
WHERE foundationyear < 2000;

-- 2. Выполнить запрос с несколькими соединениями (JOIN)
-- Найти футболистов (Имя, Фамилия, страна - название, название клуба, цена)
-- из клубов, со стоимостью выше 995 миллионов
SELECT namefootballer, surname, namecountry, nameclub, fc.price
FROM (footballers f JOIN countries c on f.countryid = c.countryid) AS fc JOIN clubs cl on fc.clubid = cl.clubid
WHERE cl.price > 995000000;

-- 3. Выполнить запрос с ОТВ(CTE) и оконными функциями
-- ОТВ (обобщенное табличное выражение) id клуба, имя клуба, цена клуба,
-- стоимость самого дорогого футболиста из данного клуба для клубов с id < 20
WITH CTE (clubid, nameclub, price, max_footb_price)
AS (
    SELECT c.clubid, nameclub, c.price, MAX(f.price) OVER(PARTITION BY c.clubid) AS max_footb_price
    FROM clubs c JOIN footballers f on c.clubid = f.clubid
    WHERE c.clubid < 20
    ORDER BY c.clubid
)
-- удаление дубликатов с помощью оконной функции
SELECT clubid, nameclub, price, max_footb_price
FROM (SELECT clubid, nameclub, price, max_footb_price, row_number() OVER(PARTITION BY clubid) as rn
FROM CTE) AS d
WHERE d.rn = 1
ORDER BY clubid;

-- 4. Выполнить запрос к метаданным
-- Получить индексы указанной таблицы
SELECT * FROM pg_indexes
WHERE tablename = 'agents';

-- 5. Вызвать скалярную функцию
-- Возвращает максимальную стоимость футболиста из указанной страны
-- c countryid=country_id(=60 по умолчанию)
CREATE OR REPLACE FUNCTION get_max_footballer_price(country_id int = 60)
RETURNS numeric AS $$
    BEGIN
    RETURN (
        SELECT MAX(price)
        FROM footballers
        WHERE countryid = country_id);
    END;
    $$
LANGUAGE plpgsql;

SELECT get_max_footballer_price(7) AS max_price;

-- 6. Вызвать многооператорную или табличную функцию
-- Сравнение клубов по стоимости с id в отрезке [bid, eid]
-- по умолчанию от 0 до 10
CREATE OR REPLACE FUNCTION get_price_clubs_inf(bid INT = 0, eid INT = 10)
RETURNS TABLE(
    clubid INT,
    nameclub VARCHAR(100),
    price_diff numeric(15, 2),
    price_min numeric(15, 2),
    price_max numeric(15, 2)
             )
AS $$
    DECLARE
        price_avg numeric(15, 2);
        price_max numeric(15, 2);
        price_min numeric(15, 2);

    BEGIN
        SELECT MAX(price)
        INTO price_max
        FROM clubs
        WHERE  clubs.clubid BETWEEN bid AND eid;

        SELECT MIN(price)
        INTO price_min
        FROM clubs
        WHERE clubs.clubid BETWEEN bid AND eid;

        SELECT AVG(price)
        INTO price_avg
        FROM clubs
        WHERE clubs.clubid BETWEEN bid AND eid;

        RETURN QUERY
            SELECT clubs.clubid, clubs.nameclub, clubs.price - price_avg AS price_diff,
            price_min, price_max
            FROM clubs
            WHERE clubs.clubid BETWEEN bid AND eid;
    END;
$$
LANGUAGE plpgsql;

-- вызов функции
SELECT *
FROM get_price_clubs_inf(0, 1);

-- 7. Вызвать хранимую процедуру.
-- Поменять клуб футболиста с id = f_id на клуб с id = new_cl_id
drop table if exists footballers_copy;

SELECT *
INTO footballers_copy
FROM footballers;

CREATE OR REPLACE PROCEDURE change_club(f_id INT, new_cl_id INT)
AS '
    BEGIN
        UPDATE footballers_copy
        SET clubid = new_cl_id
        WHERE footballerid = f_id;
    END;
' LANGUAGE plpgsql;

-- проверка
SELECT footballerid, clubid
FROM footballers_copy
ORDER BY footballerid;

-- вызов процедуры
CALL change_club(1, 100);

-- проверка
SELECT footballerid, clubid
FROM footballers_copy
ORDER BY footballerid;

-- 8. Вызвать системную функцию или процедуру.
-- current_database() name of current database
-- current_user	user name of current execution context
SELECT current_database(), current_user;

-- 9. Создать таблицу в базе данных, соответствующую тематике БД.
-- создаем таблицу тренеров клубов
DROP TABLE IF EXISTS Coaches;
CREATE TABLE IF NOT EXISTS Coaches(
    CoachId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NameCoach VARCHAR(100) NOT NULL,
    Surname VARCHAR(100) NOT NULL,
    ClubId INT NOT NULL check (ClubId BETWEEN 1 and 1000)
);

-- 10. Выполнить вставку данных в созданную таблицу с использованием
-- инструкции INSERT
INSERT INTO Coaches(namecoach, surname, clubid) VALUES
('Igor', 'Petrov', 25);

SELECT *
FROM coaches;