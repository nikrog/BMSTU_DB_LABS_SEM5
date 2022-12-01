import json
import psycopg2
from club import *
from colors import *


def connection():
    try:
        con = psycopg2.connect(
            database='postgres',
            user='postgres',
            password='postgres',
            host='localhost', #127.0.0.1 - Адрес сервера базы данных.
            port='5432'  # номер порта
        )
    except:
        print("Ошибка при подключении к БД")
        return
    print("БД успешно подключена!")
    return con


def print_json(a, color):
    print(color, f"{'clubid':<2} {'nameclub':<14} {'countryid':<5} {'leagueid':<3} {'foundationyear':<4} {'price':<15}")
    print(*a, sep='\n')

def read_json(cur, n=20):
    cur.execute("select * from clubs_json_lb7")
    rows = cur.fetchmany(n)
    arr = list()
    for el in rows:
        t = el[0]
        #print(t)
        arr.append(Club(t['clubid'], t['nameclub'], t['countryid'], t['leagueid'], t['foundationyear'], t['price']))
    print_json(arr, green)
    return arr


# изменить лигу у клубов из заданной лиги
def update_json(clubs, old, new):
    for el in clubs:
        if el.leagueid == old:
            el.leagueid = new
    print_json(clubs, green)


def add_club(clubs, newclub):
    clubs.append(newclub)
    print_json(clubs, green)


def task_2():
    con = connection()
    cur = con.cursor()

    # 1. Чтение из JSON документа.
    print(blue, "\n1.Чтение из JSON документа:\n")
    clubs_arr = read_json(cur)

    # 2. Обновление JSON документа
    print(blue, "\n2. Обновление JSON документа:\n")
    try:
        old = int(input("Введите id старой лиги: "))
        new = int(input("Введите id новой лиги: "))
    except ValueError:
        print(red, "Некорректный ввод!\n")
        return
    update_json(clubs_arr, old, new)

    # 3. Запись (добавление) в JSON
    print(blue, "\n3. Запись (добавление) в JSON:\n")
    try:
        name = input("Введите название клуба: ")
        c_id = int(input("Введите id страны клуба: "))
        l_id = int(input("Введите id лиги клуба: "))
        year = int(input("Введите год создания клуба: "))
        price = float(input("Введите стоимость клуба: "))
    except ValueError:
        print(red, "Некорректный ввод!\n")
        return
    add_club(clubs_arr, Club(7777, name, c_id, l_id, year, price))

    # Завершение соединения с БД
    cur.close()
    con.close()

task_2()

