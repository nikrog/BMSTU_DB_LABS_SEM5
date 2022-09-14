CREATE TABLE IF NOT EXISTS Countries(
    CountryId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NameCountry VARCHAR(100) NOT NULL,
    Capital VARCHAR(100) NOT NULL,
    Square numeric(15, 2),
    Population numeric(15, 2)
);

CREATE TABLE IF NOT EXISTS Leagues(
    LeaugueId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NameLeague VARCHAR(100) NOT NULL,
    CountryId INT NOT NULL,
    NumberClubs INT NOT NULL,
    FoundationYear INT NOT NULL
);

CREATE TABLE IF NOT EXISTS Agents(
    AgentId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NameAgent VARCHAR(100) NOT NULL,
    Surname VARCHAR(100) NOT NULL,
    CountryId INT NOT NULL,
    BirthDate DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS Clubs(
    ClubId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NameClub VARCHAR(100) NOT NULL,
    CountryId INT NOT NULL,
    LeagueId INT NOT NULL,
    FoundationYear INT NOT NULL,
    Price numeric(15,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS Footballers(
    FootballerId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NameFootballer VARCHAR(100) NOT NULL,
    Surname VARCHAR(100) NOT NULL,
    CountryId INT NOT NULL,
    PositionF VARCHAR(100) NOT NULL,
    ClubId INT NOT NULL,
    Price numeric(15,2) NOT NULL,
    BirthDate DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS Contracts(
    ContractId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    FootballerId INT NOT NULL,
    AgentId INT NOT NULL,
    SignDate DATE NOT NULL,
    Duration INT NOT NULL
);