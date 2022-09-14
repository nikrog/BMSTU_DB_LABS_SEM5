copy countries (namecountry, capital, square, population) from '/db_data/country.csv' delimiter ';';
copy leagues (nameleague, countryid, numberclubs, foundationyear) from '/db_data/league.csv' delimiter ';';
copy agents (nameagent, surname, countryid, birthdate) from '/db_data/agent.csv' delimiter ';' csv;
copy clubs (nameclub, countryid, leagueid, foundationyear, price) from '/db_data/club.csv' delimiter ';';
copy footballers (namefootballer, surname, countryid, positionf, clubid, price, birthdate) from '/db_data/footballer.csv' delimiter ';';
copy contracts (footballerid, agentid, signdate, duration) from '/db_data/contract.csv' delimiter ';';
