--SELECT EXTRACT(YEAR FROM birthdate) as byear, count(*) FROM footballers GROUP BY byear ORDER BY byear
-- таблица всех лиг
SELECT * from leagues;
-- количество футболистов, родившихся в определенную дату (график)
SELECT birthdate, count(*) FROM footballers GROUP BY birthdate;

-- типы подписанных контрактов (по длительности) - pie
SELECT count(*),
       CASE (duration)
            WHEN 5 THEN 'Very long'
            WHEN 1 THEN 'Very short'
            ELSE 'Average'
        END AS contract_type
FROM contracts JOIN footballers ON contracts.footballerid = footballers.footballerid
GROUP BY contract_type
order by contract_type;


-- число контрактов, подписанных за указанный год - bar chart (столбчатая диаграмма)
SELECT count(*),
       CASE
            WHEN EXTRACT(YEAR FROM signdate) = 2020  THEN '2020'
            WHEN EXTRACT(YEAR FROM signdate) = 2021 THEN '2021'
            ELSE '2022'
        END AS contract_type
FROM contracts
GROUP BY contract_type
order by contract_type;

-- количество футболистов-нападающих в каждой ценовой категории - "спидометр"
SELECT count(*),
    CASE
        WHEN price < 15000000 THEN 'Inexpensive'
        WHEN price < 50000000 THEN 'Expensive'
        ELSE 'Very Expensive'
    END AS price_categ
FROM footballers
WHERE positionf = 'forward'
GROUP BY price_categ;
