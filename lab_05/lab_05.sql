-- 1. Из таблиц базы данных, созданной в первой лабораторной работе, извлечь
-- данные в XML (MSSQL) или JSON(Oracle, Postgres). Для выгрузки в XML
-- проверить все режимы конструкции FOR XML.

SELECT row_to_json(row) ftb_json FROM footballers row;
SELECT row_to_json(row) agt_json FROM agents row;
SELECT row_to_json(row) clb_json FROM clubs row;
SELECT row_to_json(row) cntr_json FROM contracts row;
SELECT row_to_json(row) lg_json FROM leagues row;
SELECT row_to_json(row) cns_json FROM countries row;

-- 2. Выполнить загрузку и сохранение XML или JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.

-- сохранение json
COPY (SELECT row_to_json(row) FROM clubs row) TO '/db_data/json_files/clubs.json';

drop table if exists clubs_lb5;
-- создание таблицы
CREATE TABLE IF NOT EXISTS clubs_lb5
(
    ClubId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NameClub VARCHAR(100) NOT NULL,
    CountryId INT NOT NULL CHECK (CountryId BETWEEN 1 AND 200),
    LeagueId INT NOT NULL CHECK (LeagueId BETWEEN 1 AND 1000),
    FoundationYear INT NOT NULL CHECK (FoundationYear BETWEEN 1850 AND 2022),
    Price numeric(15,2) NOT NULL CHECK (Price > 0),
    FOREIGN KEY (CountryId) REFERENCES countries(countryid),
    FOREIGN KEY (LeagueId) REFERENCES leagues(leaugueid)
);

drop table if exists clubs_import;

-- таблица для импорта с одним атрибутом типа json
CREATE TABLE IF NOT EXISTS clubs_import
(
    file json
);
COPY clubs_import FROM '/db_data/json_files/clubs.json';
SELECT * FROM clubs_import;

-- из json в таблицу
INSERT INTO clubs_lb5 (nameclub, countryid, leagueid, foundationyear, price)
SELECT file->>'nameclub', (file->>'countryid')::INT, (file->>'leagueid')::INT, (file->>'foundationyear')::INT,
	   (file->>'price')::numeric FROM clubs_import;
SELECT * FROM clubs_lb5;

-- 3. Создать таблицу, в которой будет атрибут(-ы) с типом JSON, или
-- добавить атрибут с типом JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT или UPDATE.
drop table if exists clubs_json;

CREATE TABLE IF NOT EXISTS clubs_json
(
    cl_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    attr json
);

INSERT INTO clubs_json (attr)
VALUES (json_object('{clubid, nameclub, countryid, leagueid, foundationyear, price}',
    '{1234, "FC Barcelona", 100, 77, 1899, 800000000}'));

drop table if exists aircrafts;
CREATE TABLE IF NOT EXISTS aircrafts
(
    a_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(20),
    info json
);

INSERT INTO aircrafts (name, info)
VALUES ('Batman', '{"air_company": {"c_name": "Turkish Airlines", "country": "Turkey"}, "age": 10, "reg_country": "Germany", "model": "a321"}'::json),
        ('Tupolev', '{"air_company": {"c_name": "Red wings air.", "country": "Russia"}, "age": 24, "reg_country": "Russia", "model": "tu154"}'::json),
        ('Esenin', '{"air_company": {"c_name": "Aeroflot", "country": "Russia"}, "age": 4, "reg_country": "Russia", "model": "sukhoi100"}'::json),
        ('Pushkin', '{"air_company": {"c_name": "Ural airlines", "country": "Russia"}, "age": 16, "reg_country": "Panama", "model": "a320"}'::json);

SELECT * FROM aircrafts;

-- 4. Выполнить следующие действия:
-- 4.1. Извлечь XML/JSON фрагмент из XML/JSON документа.
SELECT file->'clubid' AS clubid, file->'nameclub' AS nameclub, file->'foundationyear' AS year
FROM clubs_import;

-- 4.2 Извлечь значения конкретных узлов или атрибутов JSON документа.
SELECT info->'air_company'->'c_name' as company_name
FROM aircrafts
WHERE (info->>'age')::INT > 10;

-- 4.3 Выполнить проверку существования узла или атрибута

-- проверка существования узла с данным id
DROP FUNCTION if exists check_exist;
CREATE OR REPLACE FUNCTION check_exist(id INT)
RETURNS VARCHAR AS $$
    SELECT CASE
               WHEN count.cnt > 0 THEN 'EXIST'
               ELSE 'NOT EXIST'
               END AS res
    FROM (
             SELECT COUNT(info->'air_company') as cnt
             FROM aircrafts
             WHERE a_id = id
         ) AS count;
$$ LANGUAGE sql;

SELECT * FROM aircrafts;

SELECT check_exist(0);

-- проверка существования атрибута
CREATE OR REPLACE FUNCTION check_exist2(json_date JSON, attr TEXT)
RETURNS BOOLEAN
AS $$
BEGIN
    RETURN (json_date->attr) IS NOT NULL;
END;
$$ LANGUAGE plpgsql;

SELECT check_exist2(aircrafts.info, 'reg_country')
FROM aircrafts;

-- 4.4 Изменить XML/JSON документ.
-- Увеличиваем возраст самолета до 5 с текущим возрастом = 4
UPDATE aircrafts
SET info = '{"air_company": {"c_name": "Aeroflot", "country": "Russia"}, "age": 5, "reg_country": "Russia", "model": "sukhoi100"}'::json
WHERE (info->>'age')::INT = 4;

SELECT * FROM aircrafts;

-- 4.5 Разделить XML/JSON документ на несколько строк по узлам.
drop table if exists aircrafts2;
CREATE TABLE IF NOT EXISTS aircrafts2
(
    file json
);

INSERT INTO aircrafts2 (file)
VALUES ('[{"air_company": {"c_name": "Turkish Airlines", "country": "Turkey"}, "age": 10, "reg_country": "Germany", "model": "a321"},
        {"air_company": {"c_name": "Red wings air.", "country": "Russia"}, "age": 24, "reg_country": "Russia", "model": "tu154"},
        {"air_company": {"c_name": "Aeroflot", "country": "Russia"}, "age": 4, "reg_country": "Russia", "model": "sukhoi100"},
        {"air_company": {"c_name": "Ural airlines", "country": "Russia"}, "age": 16, "reg_country": "Panama", "model": "a320"}]');

SELECT json_array_elements(file::json)
FROM aircrafts2;

SELECT * FROM aircrafts2;
