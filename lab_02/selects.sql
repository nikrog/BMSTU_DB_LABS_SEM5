-- 1. Инструкция SELECT, использующая предикат сравнения.
-- id футболиста и его трансф. стоимость для
-- форвардов, стоящих менее 15 миллионов евро
SELECT DISTINCT footballerid, price
FROM footballers
WHERE price < 15000000 and positionf = 'forward'
ORDER BY price, footballerid;

-- 2. Инструкция SELECT, использующая предикат BETWEEN.
-- id контракта и дата подписания
-- для контрактов, подписанных в период с 1 января 2022 по 30 марта 2022
SELECT DISTINCT contractid, signdate
FROM contracts
WHERE signdate BETWEEN '2022-01-01' AND '2022-03-30';

-- 3. Инструкция SELECT, использующая предикат LIKE.
-- Футболисты 2002 года рождения
SELECT DISTINCT surname, birthdate
FROM footballers
WHERE CAST(birthdate AS varchar(11)) LIKE '2002%';

-- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
-- id футболиста и фамилия для
-- футболистов, имеющих российское гражданство
SELECT DISTINCT footballerid, surname
FROM footballers
WHERE countryid IN
      (SELECT t1.countryid
       FROM footballers AS t1 JOIN countries AS t2 ON t1.countryid = t2.countryid
       WHERE t2.namecountry = 'Russian Federation');

-- 5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
-- id лиги и имя для
-- лиг, где менее 30 клубов и страна - Россия
SELECT DISTINCT leaugueid, nameleague
FROM leagues AS t
WHERE numberclubs < 30 AND
      EXISTS (SELECT t1.leaugueid, t1.nameleague
          FROM leagues AS t1 JOIN countries AS t2 ON t1.countryid = t2.countryid
          WHERE t2.namecountry = 'Russian Federation'
          AND t.leaugueid = t1.leaugueid);

-- 6. Инструкция SELECT, использующая предикат сравнения с квантором.
-- id, имя, количество клубов:
-- лига с количеством клубов больше, чем у любого клуба, основанного в 2002 году
SELECT leaugueid, nameleague, numberclubs
FROM leagues
WHERE numberclubs > ALL(SELECT numberclubs
                        FROM leagues
                        WHERE foundationyear = 2002);

-- 7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
-- средняя стоимость клубов (2 способа вычисления)
SELECT AVG(total_price) AS Actual_AVG,
       SUM(total_price)/COUNT(clubid) AS Calc_AVG
FROM (SELECT clubid, SUM(price) AS total_price
      FROM clubs
      GROUP BY clubid
      ) AS tot_clubs;

-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях
-- столбцов.
-- id, цена, средняя и минимальная длительности контрактов, имя футболиста
-- форварды с выводом минимальной и средней длины контрактов
SELECT footballerid, price,
       (SELECT AVG(duration)
        FROM contracts
        WHERE contracts.footballerid = footballers.footballerid) AS avg_duration,
    (SELECT MIN(duration)
     FROM contracts
     WHERE contracts.footballerid = footballers.footballerid) AS min_duration,
    namefootballer
FROM footballers
WHERE positionf = 'forward';

-- 9. Инструкция SELECT, использующая простое выражение CASE.
-- Определяет категорию контракта по его длительности
SELECT namefootballer, contractid,
       CASE (duration)
            WHEN 5 THEN 'Very long'
            WHEN 1 THEN 'Very short'
            ELSE 'Average'
        END AS contract_type
FROM contracts JOIN footballers ON contracts.footballerid = footballers.footballerid
order by contract_type;

-- 10. Инструкция SELECT, использующая поисковое выражение CASE.
-- Определяет категорию цены на футболистов
SELECT namefootballer, surname,
    CASE
        WHEN price < 1000000 THEN 'Inexpensive'
        WHEN price < 15000000 THEN 'Fair'
        WHEN price < 50000000 THEN 'Expensive'
        ELSE 'Very Expensive'
    END AS price_categ
FROM footballers;

-- 11. Создание новой временной локальной таблицы из результирующего набора
-- данных инструкции SELECT.
-- создание временной таблицы с футболистами из России (в формате - имя, фамилия)
CREATE TEMP TABLE IF NOT EXISTS rus_footballers as
    SELECT t1.namefootballer, t1.surname
    FROM footballers AS t1 JOIN countries AS t2 ON t1.countryid = t2.countryid
       WHERE t2.namecountry = 'Russian Federation';

-- 12. Инструкция SELECT, использующая вложенные коррелированные
-- подзапросы в качестве производных таблиц в предложении FROM.
-- Коррелированным подзапросом называется подзапрос,
-- который ссылается на значения столбцов внешнего запроса.
-- агенты с самыми долгими контрактами в сумме, по среднему значению

SELECT 'By sum duration' AS Criteria, t.nameagent, t.surname, SD as duration
FROM agents AS t JOIN
    (
        SELECT agentid, SUM(duration) AS SD
        FROM contracts
        GROUP BY agentid
        ORDER BY SD DESC) AS ct on ct.agentid = t.agentid
UNION
SELECT 'By avg duration' AS Criteria, t.nameagent, t.surname, SA as duration
FROM agents AS t JOIN
    (
        SELECT agentid, AVG(duration) AS SA
        FROM contracts
        GROUP BY agentid
        ORDER BY SA DESC) AS ct on ct.agentid = t.agentid;

-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем
-- вложенности 3.
-- Оператор SQL HAVING является указателем на результат выполнения агрегатных функций.
-- футболист с самыми длительными суммарно контрактами
SELECT 'By sum duration' AS Criteria, namefootballer, surname, footballerid
FROM footballers
WHERE footballerid = ( SELECT footballerid
                    FROM contracts
                    GROUP BY footballerid
                    HAVING SUM(duration) = ( SELECT MAX(AD)
                                            FROM ( SELECT SUM(duration) AS AD
                                            FROM contracts
                                            GROUP BY contracts.footballerid
                                            ) AS ct
                    )
);

-- 14. Инструкция SELECT, консолидирующая данные с помощью предложения
-- GROUP BY, но без предложения HAVING.
-- Вывести футболистов, родившихся после 2000 года, со средней и минимальной длительностю контрактов
SELECT t.footballerid, t.price, t.namefootballer, t.surname,
       AVG(ct.duration) AS AvgDuration,
       MIN(ct.duration) AS MinDuration
FROM footballers AS t JOIN contracts AS ct ON ct.footballerid = t.footballerid
WHERE CAST(t.birthdate AS varchar(11)) LIKE '20%'
GROUP BY t.footballerid, t.price, t.namefootballer;


-- 15. Инструкция SELECT, консолидирующая данные с помощью предложения
-- GROUP BY и предложения HAVING.
-- агенты, средняя продолжительность контрактов которых
-- больше средней продолжительности контрактов среди всех агентов

SELECT t.agentid, AVG(t.duration) AS avg_price
FROM contracts AS t
GROUP BY agentid
HAVING AVG(t.duration) > ( SELECT AVG(t1.duration) AS MPrice
FROM contracts AS t1);

-- 16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной
-- строки значений.
INSERT INTO footballers(namefootballer, surname, countryid, positionf, clubid, price, birthdate)
VALUES ('Mark', 'Ivanov', 90, 'forward', 777, 3500000.00, '2001-09-27');

-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу
-- результирующего набора данных вложенного подзапроса.
-- вставим в таблицу контракты новые записи, где id футболиста = максимальное id футболиста-защитника,
-- id агента из страны с id=1, дата контракта 27.09.2022, длительность контракта 2 года
INSERT INTO contracts(footballerid, agentid, signdate, duration)
SELECT ( SELECT MAX(footballerid)
FROM footballers
WHERE positionf='defender'),
agentid, '2022-09-27', 2
FROM agents
WHERE countryid = 1;

-- 18. Простая инструкция UPDATE.
-- в лиге с id = 1000 увеличить число клубов на 2
SELECT leaugueid, numberclubs
FROM leagues
WHERE leaugueid = 1000;

UPDATE leagues
SET numberclubs = numberclubs + 2
WHERE leaugueid = 1000;

SELECT leaugueid, numberclubs
FROM leagues
WHERE leaugueid = 1000;

-- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET.
-- Изменяет id страны у футболиста с id = 7 на максимальное id страны его агентов
-- Было 133, стало 90

SELECT footballerid, countryid
FROM footballers
WHERE footballerid = 7;

UPDATE footballers
SET countryid = (
                SELECT MAX(countryid)
                FROM contracts as t1 JOIN agents as t2 ON t1.agentid = t2.agentid
                WHERE t1.footballerid = 7
                )
WHERE footballerid = 7;

SELECT footballerid, countryid
FROM footballers
WHERE footballerid = 7;

-- 20. Простая инструкция DELETE.
-- Удаляем футболиста с id > 1000
SELECT * FROM footballers;

DELETE FROM footballers
WHERE footballerid > 1000;

SELECT * FROM footballers;

-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в
-- предложении WHERE.
-- Удалим клубы название которых начинается с PFC (Professional Football Club)
-- Предварительно добавим строку в таблицу

INSERT INTO clubs (nameclub, countryid, leagueid, foundationyear, price)
VALUES ('PFC CSKA Moscow', 90, 100, 1911, 71650000);

SELECT * FROM clubs;

DELETE FROM clubs
WHERE clubid IN (
                SELECT clubid
                FROM clubs
                WHERE nameclub LIKE 'PFC%'
                ORDER BY clubid DESC
                );

SELECT * FROM clubs;

-- 22. Инструкция SELECT, использующая простое обобщенное табличное
-- выражение.
-- Кол-во и средняя продолжительность контрактов, подписанных за каждый год
WITH CTE_contracts(signyear, contractscount, averageduration) AS (
    SELECT EXTRACT(YEAR FROM signdate) as signyear, COUNT(contractid), AVG(duration)
    FROM contracts
    GROUP BY EXTRACT(YEAR FROM signdate)
)
SELECT * FROM CTE_contracts
ORDER BY signyear;

-- среднее число контрактов за год
--SELECT AVG(contractscount) AS average_contracts
--FROM CTE_contracts

-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное
-- выражение.
-- UNION ALL в отличие от UNION выводит в результате объединения результатов нескольких запросов дубли (повторы)
-- Рекурсивно увеличиваем число голов у футболистов с id < 20

-- Определение ОТВ (Обобщенное табличное выражение)
WITH RECURSIVE contracts_t(footballerid, goals) as (
-- Определение закрепленного элемента
SELECT footballerid, 0 as prev_goals
FROM footballers as t
WHERE t.footballerid < 20
--WHERE t.positionf = 'forward'
UNION ALL
-- Определение рекурсивного элемента
select footballerid, goals + 1
from contracts_t
where goals < 5
)
-- Инструкция, использующая ОТВ
select *
from contracts_t;

-- 24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER().
-- INNER JOIN (JOIN) позволяет не учитывать клубы без футболистов
-- LEFT OUTER JOIN будет учитывать клубы без футболистов
-- DISTINCT удаляет повторы (дубли) в SELECT
-- OVER PARTITION BY(столбец для группировки) — это свойство для задания размеров окна.
-- Здесь можно указывать дополнительную информацию, давать служебные команды, например добавить номер строки.
-- Синтаксис оконной функции вписывается прямо в выборку столбцов.
-- Средння цена футболистов у клубов

--drop table if exists new_table;

SELECT DISTINCT t.clubid, t.nameclub, t.price,
       AVG(cf.price) OVER(PARTITION BY t.clubid, t.nameclub) AS AvgPrice
--INTO new_table
FROM clubs AS t JOIN footballers AS cf
ON t.clubid = cf.clubid
ORDER BY t.clubid;

--SELECT *
--FROM new_table
--WHERE AvgPrice is not null;

-- 25. Оконные фнкции для устранения дублей.
-- Устранить дублирующиеся строки с использованием функции ROW_NUMBER() - какой раз встретилась
-- данная строка в таблице.
WITH duplicates as (
    SELECT *
    FROM leagues
    WHERE numberclubs < 30
    UNION ALL
    SELECT *
    FROM leagues
    WHERE numberclubs < 18
    )
SELECT *
FROM (SELECT leaugueid, nameleague, numberclubs, row_number() OVER(PARTITION BY leaugueid) as rn
FROM duplicates) AS d
WHERE d.rn = 1
ORDER BY leaugueid

