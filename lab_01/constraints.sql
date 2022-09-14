alter table countries
add constraint check_square check (Square > 0),
add constraint check_population check (Population > 0);

alter table leagues
add constraint fk_country_id foreign key (CountryId) references countries (CountryId),
add constraint check_country_id check (CountryId between 1 and 200),
add constraint check_number_clubs check (NumberClubs > 0),
add constraint check_foundation_year check (FoundationYear between 1850 and 2022);

alter table agents
add constraint fk_country_id foreign key (CountryId) references countries (CountryId),
add constraint check_country_id check (CountryId between 1 and 200);

alter table clubs
add constraint fk_country_id foreign key (CountryId) references countries (CountryId),
add constraint fk_league_id foreign key (LeagueId) references leagues (leaugueid),
add constraint check_country_id check (CountryId between 1 and 200),
add constraint check_league_id check (LeagueId between 1 and 1000),
add constraint check_foundation_year check (FoundationYear between 1850 and 2022),
add constraint check_price check (Price > 0);

alter table footballers
add constraint fk_country_id foreign key (CountryId) references countries (CountryId),
add constraint fk_club_id foreign key (ClubId) references clubs (ClubId),
add constraint check_country_id check (CountryId between 1 and 200),
add constraint check_club_id check (ClubId between 1 and 1000),
add constraint check_price check (Price > 0);

alter table contracts
add constraint fk_footballer_id foreign key (FootballerId) references footballers (FootballerId),
add constraint fk_agent_id foreign key (AgentId) references agents (AgentId),
add constraint check_footballer_id check (FootballerId between 1 and 1000),
add constraint check_agent_id check (AgentId between 1 and 1000),
add constraint check_duration check (Duration > 0);
