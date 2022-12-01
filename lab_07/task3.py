# Задание 3. LINQ to SQL. Создать классы сущностей, которые моделируют таблицы
# Вашей базы данных. Создать запросы четырех типов:
# 1. Однотабличный запрос на выборку.
# 2. Многотабличный запрос на выборку.
# 3. Три запроса на добавление, изменение и удаление данных в базе
# данных.
# 4. Получение доступа к данным, выполняя только хранимую
# процедуру.

from peewee import *
from colors import *

con = PostgresqlDatabase(
    database="postgres",
    user="postgres",
    password="postgres",
    host='localhost',  # 127.0.0.1 - адрес сервера базы данных
    port=5432  # номер порта
)


class BaseModel(Model):
    class Meta:
        database = con


class Clubs(BaseModel):
    id = IntegerField(column_name='clubid', primary_key=True)
    nameclub = CharField(column_name='nameclub')
    countryid = IntegerField(column_name='countryid')
    leagueid = IntegerField(column_name='leagueid')
    foundationyear = IntegerField(column_name='foundationyear')
    price = FloatField(column_name='price')

    class Meta:
        table_name = 'clubs2'


class Footballers(BaseModel):
    id = IntegerField(column_name='footballerid', primary_key=True)
    namefootballer = CharField(column_name='namefootballer')
    surname = CharField(column_name='surname')
    countryid = IntegerField(column_name='countryid')
    positionf = CharField(column_name='positionf')
    clubid = IntegerField(column_name='clubid')
    foundationyear = IntegerField(column_name='foundationyear')
    price = FloatField(column_name='price')
    birthdate = DateField(column_name='birthdate')

    class Meta:
        table_name = 'footballers_copy'


class Countries(BaseModel):
    id = IntegerField(column_name='countryid', primary_key=True)
    namecountry = CharField(column_name='namecountry')
    capital = CharField(column_name='capital')
    square = FloatField(column_name='square')
    population = FloatField(column_name='population')

    class Meta:
        table_name = 'countries'


class Leagues(BaseModel):
    id = IntegerField(column_name='leaugueid', primary_key=True)
    nameleague = CharField(column_name='nameleague')
    countryid = IntegerField(column_name='countryid')
    numberclubs = IntegerField(column_name='numberclubs')
    foundationyear = IntegerField(column_name='foundationyear')

    class Meta:
        table_name = 'leagues_copy'


def query_1():
    # 1. Однотабличный запрос на выборку.
    # Список клубов со стоимостью более 900 миллионов
    print(blue, "\n1. Однотабличный запрос на выборку:\n")

    # Получаем набор записей.
    query = Clubs.select().where(Clubs.price > 900000000).order_by(Clubs.id)

    clubs_selected = query.dicts().execute()

    print(blue, "Список клубов со стоимостью более 900 миллионов:\n")
    for el in clubs_selected:
        print(white, el)


def query_2():
    # 2. Многотабличный запрос на выборку.
    print(blue, "\n2. Многотабличный запрос на выборку:\n")

    # Список клубов из лиг, где менее 10 команд
    print("Список клубов из лиг, где менее 10 команд:")
    query = Clubs.select(Clubs.id, Clubs.nameclub, Leagues.nameleague).\
        join(Leagues, on=(Clubs.leagueid == Leagues.id)).order_by(Clubs.id).where(Leagues.numberclubs < 10)

    cl = query.dicts().execute()
    for el in cl:
        print(white, el)


# Вывод последних 5-ти записей из таблицы клубов
def print_last_clubs():
    print(white, "Последние 5 клубов:")
    query = Clubs.select().limit(5).order_by(Clubs.id.desc())
    for el in query.dicts().execute():
        print(white, el)
    print()


def add_club(id, name, countryid, leagueid, foundationyear, price):
    global con
    try:
        with con.atomic() as t:
            Clubs.create(id=id, nameclub=name, countryid=countryid, leagueid=leagueid,
                         foundationyear=foundationyear, price=price)

            print(green, "Новый клуб успешно добавлен!\n")
    except Exception as err:
        print(red, err)
        t.rollback()


def update_club(id, new_price):
    club = Clubs(id=id)
    club.price = new_price
    club.save()
    print(green, "Стоимость клуба успешно изменена!\n")


def delete_club(id):
    club = Clubs.get(id=id)
    club.delete_instance()
    print(green, "Клуб успешно удален!\n")


def query_3():
    # 3. Три запроса на добавление, изменение и удаление данных в базе данных.
    print(blue, "\n3. Три запроса на добавление, изменение и удаление данных в базе данных:\n")

    print_last_clubs()

    add_club(7777, "FC Barcelona", 23, 90, 1899, 799500000)
    print_last_clubs()

    update_club(7777, 830000000)
    print_last_clubs()

    delete_club(7777)
    print_last_clubs()


def query_4():
    # 4. Получение доступа к данным, выполняя только хранимую процедуру.
    global con
    # Можно выполнять простые запросы.
    cursor = con.cursor()

    print(blue, "4. Получение доступа к данным, выполняя только хранимую процедуру:\n")

    print_last_clubs()

    # Изменение id лиги у указанного клуба
    print(green, "Изменение id лиги у указанного клуба c id = 1000\n")
    cursor.execute("CALL change_clubs_league(%s, %s);", (1000, 1))

    con.commit()  # фиксация изменений в БД

    print_last_clubs()

    cursor.execute("CALL change_clubs_league(%s, %s);", (1000, 3))
    con.commit() # фиксация изменений в БД

    cursor.close()


def task_3():
    global con

    query_1()
    query_2()
    query_3()
    query_4()

    con.close()


task_3()
