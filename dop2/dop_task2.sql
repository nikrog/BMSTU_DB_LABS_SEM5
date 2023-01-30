DROP TABLE IF EXISTS Employee;
CREATE TABLE IF NOT EXISTS Employee(
    id INT NOT NULL,
    fio VARCHAR,
    date_status DATE NOT NULL,
    status VARCHAR
);

INSERT INTO Employee(id, fio, date_status, status)
VALUES (
        1, 'Иванов Иван Иванович', '2022-12-12', 'Работа offline'
       );
INSERT INTO Employee(id, fio, date_status, status)
VALUES
        (1, 'Иванов Иван Иванович', '2022-12-13', 'Работа offline'),
        (1, 'Иванов Иван Иванович', '2022-12-14', 'Больничный'),
        (1, 'Иванов Иван Иванович', '2022-12-15', 'Больничный'),
        (1, 'Иванов Иван Иванович', '2022-12-16', 'Удаленная работа'),
        (2, 'Петров Петр Петрович', '2022-12-12', 'Работа offline'),
        (2, 'Петров Петр Петрович', '2022-12-13', 'Работа offline'),
        (2, 'Петров Петр Петрович', '2022-12-14', 'Удаленная работа'),
        (2, 'Петров Петр Петрович', '2022-12-15', 'Удаленная работа'),
        (2, 'Петров Петр Петрович', '2022-12-16', 'Работа offline');

SELECT * FROM Employee;

--SELECT id, fio, min(date_status) as date_from, max(date_status) as date_to, status
--FROM Employee
--GROUP BY id, fio, status;

DROP FUNCTION collapse_table_on_status();

CREATE OR REPLACE FUNCTION collapse_table_on_status()
RETURNS TABLE(
    id INT,
    fio VARCHAR,
    date_from DATE,
    date_to DATE,
    status VARCHAR
    )
AS $$
    q = plpy.execute(f"SELECT id, fio, date_status as date_from, date_status as date_to, status FROM Employee ORDER by id")
    result = []
    cur_id = q[0]["id"]
    cur_status = q[0]["status"]
    result.append(q[0])
    for i in range(len(q)):
        if q[i]["status"] != cur_status or q[i]["id"] != cur_id:
            result[-1]["date_to"] = q[i - 1]["date_from"]
            result.append(q[i])
            cur_id = q[i]["id"]
            cur_status = q[i]["status"]
    result[-1]["date_to"] = q[-1]["date_to"]
    return result
$$ LANGUAGE plpython3u;

SELECT * FROM collapse_table_on_status();

SELECT id, fio, min(date_status) as date_from, max(date_status) as date_to, status
FROM (SELECT id, ROW_NUMBER() OVER(
    PARTITION BY id, fio, status
    ORDER BY date_status
    ) AS n, fio, status, date_status FROM Employee) as t
GROUP BY id, fio, status, date_status - n::int ORDER BY id, fio, date_from;

