-- сохранение json
COPY (SELECT row_to_json(row) FROM clubs row) TO '/db_data/json_files/clubs.json';

CREATE TABLE IF NOT EXISTS clubs_json_lb7
(
    file JSON
);

COPY clubs_json_lb7 FROM '/db_data/json_files/clubs.json';

SELECT * FROM clubs_json_lb7

SELECT *
INTO countries_copy
FROM countries;

Drop table if exists clubs2;
CREATE TABLE IF NOT EXISTS Clubs2(
    ClubId SERIAL PRIMARY KEY,
    NameClub VARCHAR(100) NOT NULL,
    CountryId INT NOT NULL,
    LeagueId INT NOT NULL,
    FoundationYear INT NOT NULL,
    Price numeric(15,2) NOT NULL
);
copy clubs2 (nameclub, countryid, leagueid, foundationyear, price) from '/db_data/club.csv' delimiter ';';


CREATE OR REPLACE PROCEDURE change_club(f_id INT, new_cl_id INT)
AS '
    BEGIN
        UPDATE footballers_copy
        SET clubid = new_cl_id
        WHERE footballerid = f_id;
    END;
' LANGUAGE plpgsql;

CALL change_club(1, 100);

CREATE OR REPLACE PROCEDURE change_clubs_league(cl_id INT, new_l INT)
AS $$
    BEGIN
        UPDATE clubs2
        SET leagueid = new_l
        WHERE clubid = cl_id;
    END;
$$ LANGUAGE plpgsql;

SELECT * FROM clubs2;
CALL change_clubs_league(1, 292);
SELECT * FROM clubs2;