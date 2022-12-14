select * from clubs_copy;
DROP table if exists clubs_copy;
SELECT *
INTO clubs_copy
FROM clubs;

INSERT INTO clubs(nameclub, countryid, leagueid, foundationyear, price)
VALUES('FC A', 1, 2, 1987, 235)