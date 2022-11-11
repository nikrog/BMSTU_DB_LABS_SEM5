select * from pg_language;
--SELECT name, default_version, installed_version FROM pg_available_extensions;
create extension plpython3u;

-- 1. Определяемую пользователем скалярную функцию CLR.
-- название клуба по его по id.
CREATE OR REPLACE FUNCTION get_club_name(c_id INT)
RETURNS VARCHAR
AS $$
    res = plpy.execute(f" \
                        SELECT nameclub \
                        FROM clubs  \
                        WHERE clubid = {c_id};")
    if res:
        return res[0]['nameclub']
    else:
        return 'ERROR: NOT FOUND'
$$ LANGUAGE plpython3u;

-- проверка
SELECT get_club_name(1) as res;

SELECT *
FROM clubs
WHERE nameclub = get_club_name(1);

-- 2. Пользовательскую агрегатную функцию CLR.
-- Агрегатная функция выполняет вычисление на наборе значений и возвращает одиночное значение.
-- Возвращает количество футболистов заданной страны
-- a (stype) - переменная для хранения текущего значения после обработки очередной строки
CREATE OR REPLACE FUNCTION count_footballers(a int, country int)
RETURNS INT
AS $$
    count = 0
    res = plpy.execute(f" \
                        SELECT * \
                        FROM footballers")
    for f in res:
        if f["countryid"] == country:
            count += 1
    return count
$$ LANGUAGE plpython3u;

CREATE AGGREGATE footballer_in_country(int)
(
    sfunc = count_footballers,
    stype =  int
);

-- проверка
SELECT footballer_in_country(2);

SELECT countryid, count(countryid)
FROM footballers
GROUP BY countryid
ORDER BY countryid;

-- 3. Определяемую пользователем табличную функцию CLR.
-- Возвращает всех футболистов клуба с указанным именем
CREATE OR REPLACE FUNCTION get_footballers_club(club varchar(100) = 'FC Levy')
RETURNS TABLE(
    footballerid INT,
    nameclub VARCHAR(100),
    namefootballer VARCHAR(100),
    surname VARCHAR(100),
    countryid INT,
    positionf VARCHAR(100)
             )
AS $$
    tmp = plpy.execute(f" SELECT f.footballerid, c.nameclub, f.namefootballer, f.surname, f.countryid, f.positionf \
                          FROM footballers f JOIN clubs c on f.clubid = c.clubid;")
    res = []
    for f in tmp:
        if f['nameclub'] == club:
            res.append(f)
    return res
$$ LANGUAGE plpython3u;

-- проверка
SELECT *
FROM get_footballers_club('FC Brown');

SELECT nameclub, count(footballerid) as num_footballers
FROM footballers f JOIN clubs c on f.clubid = c.clubid
GROUP BY nameclub
ORDER BY num_footballers desc;

-- 4. Хранимую процедуру CLR.
-- Поменять клуб футболиста с id = f_id на клуб с id = new_cl_id
drop table if exists footballers_copy;

SELECT *
INTO footballers_copy
FROM footballers;

CREATE OR REPLACE PROCEDURE change_club(f_id INT, new_cl_id INT)
AS '
    plan = plpy.prepare("UPDATE footballers_copy \
                        SET clubid = $1 \
                        WHERE footballerid = $2", ["INT", "INT"])
    plpy.execute(plan, [new_cl_id, f_id])

' LANGUAGE plpython3u;

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

-- 5. Триггер CLR.
-- Если изменить id страны у какой-то из лиг из этой страны,
-- то нужно изменить такие же id для других лиг этой страны.
-- Когда функция используется как триггер, словарь TD содержит значения, связанные с работой триггера.

drop table if exists leagues_copy;

-- создание копии таблицы, чтобы не портить исходные
SELECT *
INTO leagues_copy
FROM leagues;

-- функция триггера
CREATE OR REPLACE FUNCTION update_leagues()
RETURNS TRIGGER
AS '
        old_id = TD["old"]["countryid"]
        new_id = TD["new"]["countryid"]
        plpy.execute(f"UPDATE leagues_copy \
                            SET countryid = {new_id} \
                            WHERE leagues_copy.countryid = {old_id}")
        return None
'LANGUAGE plpython3u;

-- создание триггера
CREATE TRIGGER AfterUpdateLeague
AFTER UPDATE ON leagues_copy
FOR EACH ROW
EXECUTE PROCEDURE update_leagues();

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

-- 6. Определяемый пользователем тип данных CLR.
-- Получение самого дорогого игрока из заданного клуба.
-- Пользовательский тип данных содержит id и цену футболиста
-- nrows() - возвращает количество строк в результате

DROP TYPE IF EXISTS footb_price CASCADE;

CREATE TYPE footb_price AS
(
    id INT,
    price numeric(15, 2)
);

CREATE OR REPLACE FUNCTION get_most_expensive(cl_id INT)
RETURNS footb_price
AS $$
    plan = plpy.prepare("SELECT footballerid, price \
                        FROM footballers \
                        WHERE clubid = $1 \
                        ORDER BY price DESC;", ["INT"])
    res = plpy.execute(plan, [cl_id])
    if res.nrows():
        return res[0]["footballerid"], res[0]["price"]
$$ LANGUAGE plpython3u;

-- проверка
SELECT *
FROM get_most_expensive(35);


-- защита (сравнение времени выполнения табличной функции, написаннной на plpgsql и plpython3u (SQL CLR).

-- табличная функция SQL
CREATE OR REPLACE FUNCTION get_footballers_club_sql(club varchar(100) = 'FC Levy')
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
$$ LANGUAGE plpgsql;



-- табличная функция SQL CLR (Python)
CREATE OR REPLACE FUNCTION get_footballers_club_pt(club varchar(100) = 'FC Levy')
RETURNS TABLE(
    footballerid INT,
    nameclub VARCHAR(100),
    namefootballer VARCHAR(100),
    surname VARCHAR(100),
    countryid INT,
    positionf VARCHAR(100)
             )
AS $$
    tmp = plpy.execute(f" SELECT f.footballerid, c.nameclub, f.namefootballer, f.surname, f.countryid, f.positionf \
                          FROM footballers f JOIN clubs c on f.clubid = c.clubid;")
    res = []
    for f in tmp:
        if f['nameclub'] == club:
            res.append(f)
    return res
$$ LANGUAGE plpython3u;

-- проверка SQL CLR
SELECT *
FROM get_footballers_club_pt('FC Brown');

-- проверка SQL
SELECT *
FROM get_footballers_club_sql('FC Brown');