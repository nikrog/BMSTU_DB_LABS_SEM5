-- Доп. задание 1 (К ЛР2) Артюхин Николай ИУ7-51Б

--Создать таблицы:
--• Table1{id: integer, var1: string, valid_from_dttm: date, valid_to_dttm: date}
--• Table2{id: integer, var2: string, valid_from_dttm: date, valid_to_dttm: date}
--Версионность в таблицах непрерывная, разрывов нет (если valid_to_dttm =
--'2018-09-05', то для следующей строки соответствующего ID valid_from_dttm =
--'2018-09-06', т.е. на день больше). Для каждого ID дата начала версионности и
--дата конца версионности в Table1 и Table2 совпадают.
--Выполнить версионное соединение двух талиц по полю id.

-- функция GREATEST возвращает наибольшее значение в списке выражений
-- функция LEAST возвращает наименьшее значение в списке выражений

--CASE case-expression
--    WHEN when-expression-1 THEN value-1
--  [ WHEN when-expression-n THEN value-n ... ]
--  [ ELSE else-value ]
-- END

DROP TABLE IF EXISTS Table1;
DROP TABLE IF EXISTS Table2;

CREATE TABLE IF NOT EXISTS Table1(
    id INT,
    var1 VARCHAR(10) NOT NULL,
    valid_from_dttm DATE NOT NULL,
    valid_to_dttm DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS Table2(
    id INT,
    var2 VARCHAR(10) NOT NULL,
    valid_from_dttm DATE NOT NULL,
    valid_to_dttm DATE NOT NULL
);

INSERT INTO Table1(id, var1, valid_from_dttm, valid_to_dttm)
VALUES (1, 'A', '2018-09-01', '2018-09-15');

INSERT INTO Table1(id, var1, valid_from_dttm, valid_to_dttm)
VALUES (1, 'B', '2018-09-16', '5999-12-31');

INSERT INTO Table2(id, var2, valid_from_dttm, valid_to_dttm)
VALUES (1, 'A', '2018-09-01', '2018-09-18');

INSERT INTO Table2(id, var2, valid_from_dttm, valid_to_dttm)
VALUES (1, 'B', '2018-09-19', '5999-12-31');

-- 1 способ (с GREATEST и LEAST)
SELECT * FROM (
    SELECT t1.id, var1, var2,
    GREATEST(t1.valid_from_dttm, t2.valid_from_dttm) AS valid_from_dttm,
    LEAST(t1.valid_to_dttm, t2.valid_to_dttm) AS valid_to_dttm
    FROM Table1 t1 FULL OUTER JOIN Table2 t2 ON t1.id = t2.id) AS result
WHERE valid_from_dttm <= valid_to_dttm
ORDER BY id, valid_from_dttm;


-- 2 способ (с CASE)
SELECT * FROM (
    SELECT t1.id, var1, var2,
                CASE
                    WHEN t1.valid_from_dttm >= t2.valid_from_dttm
                    THEN t1.valid_from_dttm
                    ELSE t2.valid_from_dttm
                    END AS valid_from_dttm,
                CASE
                    WHEN t1.valid_to_dttm <= t2.valid_to_dttm
                    THEN t1.valid_to_dttm
                    ELSE t2.valid_to_dttm
                    END AS valid_to_dttm
        FROM Table1 t1 FULL OUTER JOIN Table2 t2 ON t1.id = t2.id) AS result
WHERE valid_from_dttm <= valid_to_dttm
ORDER BY id, valid_from_dttm;