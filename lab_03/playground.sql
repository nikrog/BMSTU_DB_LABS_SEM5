CREATE OR REPLACE FUNCTION plsy() RETURNS TRIGGER
AS
$$
    DECLARE
        zov int;
    BEGIN
        SELECT P.y FROM play P WHERE P.x = old.x INTO zov;
        IF zov = 12 THEN
            RETURN NULL;
        END IF;
        RETURN old;
    END;$$ LANGUAGE plpgsql;


CREATE TABLE play (
    x int,
    y int
);

CREATE TRIGGER thouhruogprthtpjpirt
BEFORE DELETE ON play
FOR EACH ROW
EXECUTE PROCEDURE plsy();