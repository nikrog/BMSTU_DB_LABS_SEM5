-----------------------------------Функции--------------------------------
-- 1. Скалярная функция.
-- Возвращает максимальную стоимость футболиста из указанной страны
-- c countryid=country_id(=60 по умолчанию)
CREATE OR REPLACE FUNCTION get_max_footballer_price(country_id int = 60)
RETURNS numeric AS '
    SELECT MAX(price)
    FROM footballers
    WHERE countryid = country_id'
LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_max_footballer_price2(country_id int = 60)
RETURNS numeric AS $$
    BEGIN
    RETURN (
        SELECT MAX(price)
        FROM footballers
        WHERE countryid = country_id);
    END;
    $$
LANGUAGE plpgsql;

-- вызов функции
SELECT get_max_footballer_price(7) AS max_price;
SELECT get_max_footballer_price2(7) AS max_price;

-- проверка результата функции
SELECT countryid, MAX(price)
FROM footballers
GROUP BY countryid
ORDER BY countryid;

-- 2. Подставляемая табличная функция.
-- Возвращает всех футболистов клуба
-- с nameclub = club(= 'FC Levy')
CREATE OR REPLACE FUNCTION get_footballers_club(club varchar(100) = 'FC Levy')
RETURNS TABLE(
    footballerid INT,
    nameclub VARCHAR(100),
    namefootballer VARCHAR(100),
    surname VARCHAR(100),
    countryid INT,
    positionf VARCHAR(100)
             )
AS '
    SELECT footballerid, nameclub, namefootballer, surname, f.countryid, positionf
    FROM footballers f JOIN clubs c on f.clubid = c.clubid
    WHERE c.nameclub = club
    '
LANGUAGE SQL;


CREATE OR REPLACE FUNCTION get_footballers_club2(club varchar(100) = 'FC Levy')
RETURNS TABLE(
    footballerid INT,
    nameclub VARCHAR(100),
    namefootballer VARCHAR(100),
    surname VARCHAR(100),
    countryid INT,
    positionf VARCHAR(100)
             )
AS $$
    BEGIN
    RETURN QUERY
    SELECT f.footballerid, c.nameclub, f.namefootballer, f.surname, f.countryid, f.positionf
    FROM footballers f JOIN clubs c on f.clubid = c.clubid
    WHERE c.nameclub = club;
    END;
    $$
LANGUAGE plpgsql;

-- вызов функции
SELECT *
FROM get_footballers_club('FC Brown');

SELECT *
FROM get_footballers_club2('FC Brown');

-- проверка результата функции
SELECT nameclub, count(footballerid) as num_footballers
FROM footballers f JOIN clubs c on f.clubid = c.clubid
GROUP BY nameclub
ORDER BY num_footballers desc;

-- 3. Многооператорная табличная функция.
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
FROM get_price_clubs_inf(0, 50);

-- проверка
SELECT MIN(price) as price_min, MAX(price) as price_max, AVG(price) as price_avg
FROM clubs
WHERE clubid BETWEEN 0 AND 50;

SELECT clubid, nameclub, price
FROM clubs
WHERE clubid BETWEEN 0 AND 50;

-- 4. Рекурсивная функция или функция с рекурсивным ОТВ
-- Генерация голов для футболистов с id от 1 до n в количестве до max_goals
CREATE OR REPLACE FUNCTION generate_goals(n INT = 10, max_goals INT = 5)
RETURNS TABLE(
    footballerid INT,
    n_goals INT
             )
AS $$
    -- Определение ОТВ (Обобщенное табличное выражение)
    WITH RECURSIVE goals_t(footballerid, goals) as (
    -- Определение закрепленного элемента
    SELECT footballerid, 0 as prev_goals
    FROM footballers as t
    WHERE t.footballerid <= n
    UNION ALL
    -- Определение рекурсивного элемента
    select footballerid, goals + 1
    from goals_t
    where goals < max_goals
    )
    SELECT *
    FROM goals_t
$$ LANGUAGE SQL;

SELECT *
from generate_goals(4, 3)

-----------------------------------Процедуры--------------------------------
-- 1. Хранимая процедура без параметров или с параметрами
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

-- 2. Рекурсивная хранимая процедура или хранимая процедура с рекурсивным ОТВ.
-- Увеличить число клубов до need_num в лигах, с текущим количеством клубов не более cur_num

drop table if exists leagues_copy;

SELECT *
INTO leagues_copy
FROM leagues;

CREATE OR REPLACE PROCEDURE inc_num_clubs(cur_num INT, need_num INT)
AS '
    BEGIN
        IF cur_num >= 0 THEN
            UPDATE leagues_copy
            SET numberclubs = numberclubs + (need_num - leagues_copy.numberclubs)
            WHERE numberclubs = cur_num;

            CALL inc_num_clubs(cur_num - 1, need_num);
        END IF;
    END;
'LANGUAGE plpgsql;

-- проверка
SELECT leaugueid, numberclubs
FROM leagues_copy
ORDER BY numberclubs;

-- вызов процедуры
CALL inc_num_clubs(15, 16);

-- проверка
SELECT leaugueid, numberclubs
FROM leagues_copy
ORDER BY numberclubs;

-- числа Фиббоначи
CREATE OR REPLACE PROCEDURE fib_nums
(
	result INOUT int,
	iter int,
	a int DEFAULT 1,
	b int DEFAULT 1
)
AS '
    BEGIN
	    IF iter > 0 THEN
		    RAISE NOTICE ''cur_ = %'', result;
		    result = a + b;

		    CALL fib_nums(result, iter - 1, b, a + b);
	    END IF;
    END;
' LANGUAGE plpgsql;

-- вызов процедуры
CALL fib_nums(1, 3);


-- 3. Хранимая процедура с курсором
-- Курсор - результирующая выборка (набор строк)
-- Поиск клубов из заданной страны
CREATE OR REPLACE PROCEDURE find_clubs(country VARCHAR(100))
AS '
    DECLARE
        club VARCHAR(100);
        MyCursor CURSOR
        FOR SELECT t1.nameclub
        FROM clubs t1 JOIN countries t2 on t1.countryid = t2.countryid
        WHERE t2.namecountry = country;
    BEGIN
        OPEN MyCursor;
        LOOP
            FETCH MyCursor INTO club;
             -- выход из цикла, если достигнут конец выборки.
            EXIT WHEN NOT FOUND;
            RAISE NOTICE ''Club =  %'', club;
        END LOOP;
        CLOSE MyCursor;
    END;
'LANGUAGE plpgsql;

-- вызов процедуры
CALL find_clubs('Russian Federation');

-- проверка
SELECT nameclub
FROM clubs JOIN countries c on c.countryid = clubs.countryid
WHERE namecountry = 'Russian Federation';

-- 4. Хранимая процедура доступа к метаданным.
-- Метаданные — информация о другой информации,
-- или данные, относящиеся к дополнительной информации о содержимом или объекте.
-- Для каждого атрибута указанной таблицы: имя столбца (атрибута) и его тип (используем курсор)
CREATE OR REPLACE PROCEDURE get_columns_info(t_name VARCHAR(100))
AS '
    DECLARE
        bufer RECORD;
        MyCursor CURSOR
        FOR SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_name = t_name;
    BEGIN
        OPEN MyCursor;
        LOOP
            FETCH MyCursor
            INTO bufer;
            EXIT WHEN NOT FOUND;
            RAISE NOTICE ''name of column: %; type of data: %'', bufer.column_name, bufer.data_type;
        END LOOP;
        CLOSE MyCursor;
    END;
'LANGUAGE plpgsql;

-- вызов процедуры
CALL get_columns_info('footballers');

-- Получаем размер указанной таблицы (не используем курсоры)
CREATE OR REPLACE PROCEDURE get_size_table(t_name VARCHAR(100))
AS '
    DECLARE
        bufer RECORD;
    BEGIN
        FOR bufer IN
            SELECT pg_relation_size(t_name) as table_size
            from information_schema.tables
            WHERE table_name = t_name
        LOOP
            RAISE NOTICE ''size of table % : % bytes'', t_name, bufer.table_size;
        END LOOP;
    END;
'LANGUAGE plpgsql;

-- вызов процедуры
CALL get_size_table('footballers');
CALL get_size_table('agents');

-----------------------------------Триггеры--------------------------------
-- 1. Триггер AFTER.
-- Если изменить id страны у какой-то из лиг из этой страны,
-- то нужно изменить такие же id для других лиг этой страны.
-- Когда функция на PL/pgSQL срабатывает как триггер,
-- в блоке верхнего уровня автоматически создаются несколько специальных переменных: OLD, NEW
-- NEW - Тип данных RECORD. Переменная содержит новую строку базы данных
-- для команд INSERT/UPDATE в триггерах уровня строки.
-- OLD - Тип данных RECORD. Переменная содержит старую строку базы данных
-- для команд UPDATE/DELETE в триггерах уровня строки.
drop table if exists leagues_copy;

-- создание копии таблицы, чтобы не портить исходные
SELECT *
INTO leagues_copy
FROM leagues;

-- функция триггера
CREATE OR REPLACE FUNCTION update_trigger()
RETURNS TRIGGER
AS '
    BEGIN
        RAISE NOTICE ''Old =  %'', OLD;
        RAISE NOTICE ''New =  %'', NEW;
        UPDATE leagues_copy
        SET countryid = NEW.countryid
        WHERE leagues_copy.countryid = OLD.countryid;

        RETURN NEW;
    END;
'LANGUAGE plpgsql;

-- создание триггера
CREATE TRIGGER AfterUpdateLeague
AFTER UPDATE ON leagues_copy
FOR EACH ROW
EXECUTE PROCEDURE update_trigger();

-- проверка срабатывания триггера
SELECT leaugueid, countryid
FROM leagues_copy
WHERE countryid = 58
ORDER BY leaugueid;

UPDATE leagues_copy
SET countryid = 100
WHERE leaugueid = 1;

SELECT leaugueid, countryid
FROM leagues_copy
WHERE countryid = 100
ORDER BY leaugueid;

-- 2. Триггер INSTEAD OF.
-- При попытки удаления лиги, изменить название лиги на DELETED
drop view if exists leagues_view;

-- создание view на основе таблицы лиг
CREATE VIEW leagues_view AS
SELECT *
FROM leagues;

-- функция триггера
CREATE OR REPLACE FUNCTION delete_trigger()
RETURNS TRIGGER
AS '
    BEGIN
        RAISE NOTICE ''Old =  %'', OLD;
        RAISE NOTICE ''New =  %'', NEW;

        UPDATE leagues_view
        SET nameleague = ''DELETED''
        WHERE leaugueid = OLD.leaugueid;

        RETURN NEW;
    END;
'LANGUAGE plpgsql;

-- создание триггера
CREATE TRIGGER InsteadOfDeleteLeague
INSTEAD OF DELETE ON leagues_view
FOR EACH ROW
EXECUTE PROCEDURE delete_trigger();

-- проверка срабатывания триггера
SELECT *
FROM leagues_view
ORDER BY leaugueid;

DELETE FROM leagues_view
WHERE leaugueid = 1;

SELECT *
FROM leagues_view
ORDER BY leaugueid;

-- Процедура, удаляющая клубы (у которых есть футболист из США)
-- Триггер должен проверить, если пытаются удалить клуб с футболистом из США - запретить выполнение
drop table if exists clubs_copy;
SELECT *
INTO clubs_copy
FROM clubs;

CREATE OR REPLACE PROCEDURE delete_club(cl_id INT)
AS '
    BEGIN
        DELETE FROM clubs_copy
        WHERE clubid = cl_id;
    END;
' LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_cl_trigger()
RETURNS TRIGGER
AS '
    BEGIN
        IF EXISTS(SELECT footballerid FROM footballers WHERE clubid = old.clubid AND countryid = 98) THEN
            raise notice ''gtghtht'';
            RETURN NULL;
        END IF;
        RETURN OLD;
    END;
'LANGUAGE plpgsql;

CREATE TRIGGER BeforeDeleteClub
BEFORE DELETE ON clubs_copy
FOR EACH ROW
EXECUTE PROCEDURE delete_cl_trigger();

CALL delete_club(125);

-- клубы с футболистами из США
SELECT *
FROM clubs JOIN footballers f on clubs.clubid = f.clubid
WHERE f.countryid = 98;

SELECT *
FROM clubs_copy
WHERE countryid = 98;

SELECT *
FROM clubs_copy
