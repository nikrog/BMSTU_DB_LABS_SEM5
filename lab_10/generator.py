from faker import Faker
from random import randint, random
from random import choice

from mimesis import Datetime

MAX_N = 1000
MAX_COUNTRY = 200

datetime = Datetime()
t_pos = ["goalkeeper", "defender", "midfielder", "forward"]


def generate_country():
    faker = Faker()
    f = open('country.csv', 'w')
    co_set = set()
    cap_set = set()
    for i in range(MAX_COUNTRY):
        name = faker.country()
        while name in co_set:
            name = faker.country()
        co_set.add(name)
        capital = faker.city()
        while name in cap_set:
            capital = faker.country()
        cap_set.add(capital)
        square = 1 + random() * 20 * 1e6
        population = 1 + random() * 1.5 * 1e9
        line = "('{0}','{1}',{2},{3}),\n".format(
            name,
            capital,
            square,
            population)
        f.write(line)
    f.close()


def get_league():
    faker = Faker()
    name_res = faker.name()
    name_res = name_res.split(' ')
    name_res = str(name_res[0]) + ' league'
    return name_res


def generate_league():
    faker = Faker()
    f = open('league.csv', 'w')
    for i in range(MAX_N):
        name_res = faker.name()
        name_res = name_res.split(' ')
        name_res = str(name_res[0]) + ' league'
        country = randint(1, MAX_COUNTRY)
        number_clubs = randint(2, 100)
        year = randint(1850, 2022)
        line = "('{0}',{1},{2},{3}),\n".format(
            name_res,
            country,
            number_clubs,
            year)
        f.write(line)
    f.close()


def generate_agent():
    faker = Faker()
    f = open('agent.csv', 'w')
    for i in range(MAX_N):
        name = faker.name()
        name = name.split(' ')
        name_res = str(name[0])
        surname = str(name[1])
        country = randint(1, MAX_COUNTRY)
        birth_data = datetime.date(start=1930, end=2000)
        line = "('{0}','{1}',{2},'{3}'),\n".format(
            name_res,
            surname,
            country,
            birth_data)
        f.write(line)
    f.close()


def generate_club():
    faker = Faker()
    f = open('club.csv', 'w')
    for i in range(MAX_N):
        name_res = faker.name()
        name_res = name_res.split(' ')
        name_res = 'FC ' + str(name_res[1])
        country = randint(1, MAX_COUNTRY)
        league = randint(1, MAX_N)
        year = randint(1850, 2022)
        price = randint(1, 1000) * 1e6
        line = "('{0}',{1},{2},{3},{4}),\n".format(
            name_res,
            country,
            league,
            year,
            price)
        f.write(line)
    f.close()


def generate_footballer():
    faker = Faker()
    f = open('footballer.csv', 'w')
    for i in range(MAX_N):
        name = faker.name()
        name = name.split(' ')
        name_res = str(name[0])
        surname = str(name[1])
        country = randint(1, MAX_COUNTRY)
        position = choice(t_pos)
        club = randint(1, MAX_N)
        price = randint(1, 100) * 1e6
        birth_data = datetime.date(start=1980, end=2007)
        line = "('{0}','{1}',{2},'{3}',{4},{5},'{6}'),\n".format(
            name_res,
            surname,
            country,
            position,
            club,
            price,
            birth_data)
        f.write(line)
    f.close()


def generate_contract():
    f = open('contract.csv', 'w')
    for i in range(MAX_N):
        footballer = randint(1, MAX_N)
        agent = randint(1, MAX_N)
        date = datetime.date(start=2020, end=2022)
        duration = randint(1, 5)
        line = "({0},{1},'{2}',{3}),\n".format(
            footballer,
            agent,
            date,
            duration)
        f.write(line)
    f.close()

def generate_coach():
    faker = Faker()
    f = open('coach.csv', 'w')
    for i in range(MAX_N):
        name = faker.name()
        name = name.split(' ')
        name_res = str(name[0])
        surname = str(name[1])
        country = randint(1, MAX_COUNTRY)
        club = randint(1, MAX_N)
        birth_data = datetime.date(start=1930, end=2000)
        line = "{0},{1},{2},{3},{4}\n".format(
            name_res,
            surname,
            country,
            club,
            birth_data)
        f.write(line)
    f.close()

if __name__ == "__main__":
    generate_country() #done
    generate_league() #done
    generate_agent() #done
    generate_club() #done
    generate_footballer() #done
    generate_contract()  # done
    #generate_coach() #defend
