SELECT * FROM clubs ORDER BY price DESC LIMIT(10);

DROP TABLE IF EXISTS  leagues_copy;
SELECT * INTO leagues_copy FROM leagues;