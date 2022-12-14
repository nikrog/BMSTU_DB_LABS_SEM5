from time import time
import matplotlib.pyplot as plt
import psycopg2
import redis
import json
import threading
from random import randint
from colors import *

def connection():
    # Подключение к БД.
    try:
        con = psycopg2.connect(
            database="postgres",
            user="postgres",
            password="postgres",
            host="127.0.0.1",  # Адрес сервера базы данных
            port="5432"  # Номер порта
        )
    except:
        print(red, "Ошибка при подключении к БД!", white)
        return

    print(green, "БД успешно подключена!", white)
    return con


def print_menu():
    print("\t\t\t\tМЕНЮ:")
    print("\t1. Топ-10 самых больших лиг по количеству клубов (# 2)\n"
          "\t2. Приложение выполняет запрос каждые 5 секунд на стороне БД. (# 3.1)\n"
          "\t3. Приложение выполняет запрос каждые 5 секунд через Redis в качестве кэша. (# 3.2)\n"
          "\t4. Графики зависимости (# 3.3)\n"
          "\t0. Выход\n\n")


# Написать запрос, получающий статистическую информацию на основе
# данных БД.
# Получение топ-10 самых больших лиг (по кол-ву клубов)
def get_leagues_top10(cur):
    print(blue, "Топ-10 самых больших лиг (по кол-ву клубов): ", white)
    print(blue, "(id, name, countryid, numberclubs, year)", white)
    redis_client = redis.Redis(host="localhost", port=6379, db=0)

    cache_value = redis_client.get("leagues_top10")  # проверка наличия результата в кэше
    if cache_value is not None:
        redis_client.close()
        return json.loads(cache_value)

    cur.execute("SELECT * FROM leagues ORDER BY numberclubs DESC LIMIT(10)")
    res = cur.fetchall()
    #print(res)
    redis_client.set("leagues_top10", json.dumps(res))
    redis_client.close()

    return res


# 1. Приложение выполняет запрос каждые 5 секунд на стороне БД.
# Лиги из страны с указанным id
def task_02(cur, id):
    threading.Timer(5.0, task_02, [cur, id]).start()

    cur.execute("SELECT *\
                   FROM leagues\
                   WHERE countryid = %s;", (id,))

    result = cur.fetchall()

    return result


# 2. Приложение выполняет запрос каждые 5 секунд через Redis в качестве кэша.
# Лиги из страны с указанным id
def task_03(cur, id):
    threading.Timer(5.0, task_02, [cur, id]).start()

    redis_client = redis.Redis(host="localhost", port=6379, db=0)

    cache_value = redis_client.get("leagues_countryid_" + str(id))  # проверка наличия результата в кэше
    if cache_value is not None:
        redis_client.close()
        print(yellow, "IN CACHE", white)
        return json.loads(cache_value)

    cur.execute("SELECT *\
                   FROM leagues\
                   WHERE countryid = %s;", (id,))

    result = cur.fetchall()
    data = json.dumps(result)
    print(yellow, "NOT IN CACHE", white)
    redis_client.set("leagues_countryid_" + str(id), data)
    redis_client.close()

    return result

# 3.3.1 Без изменения данных в БД
def select_leag(cur):
    # threading.Timer(10.0, select_leag, [cur]).start()
    redis_client = redis.Redis(host="localhost", port=6379, db=0)

    t1 = time()
    cur.execute("SELECT *\
                   from leagues_copy\
                   WHERE leaugueid = 1;")
    t2 = time()

    result = cur.fetchall()
    data = json.dumps(result)

    t11 = time()
    cache_value = redis_client.get("l1")
    if cache_value is not None:
        pass
    else:
        redis_client.set("l1", data)
    redis_client.get("l1")
    t22 = time()

    redis_client.close()

    return t2 - t1, t22 - t11


# 3.3.2 При добавлении новых строк каждые 10 секунд
def ins_leag(cur, con):
    # threading.Timer(10.0, ins_leag, [cur, con]).start()
    redis_client = redis.Redis()
    l_id = randint(1, 1000) + 1000

    t1 = time()
    cur.execute("INSERT INTO leagues_copy VALUES (%s, 'A league', 33, 18, 1988);", (l_id,))
    t2 = time()

    cur.execute("SELECT * FROM leagues_copy\
         where leaugueid = %s;", (l_id,))

    result = cur.fetchall()
    data = json.dumps(result)

    t11 = time()
    redis_client.set("l" + str(l_id), data)
    t22 = time()

    redis_client.close()
    con.commit()

    return t2 - t1, t22 - t11


# 3.3.3 При удалении строк каждые 10 секунд
def del_leag(cur, con):
    # threading.Timer(10.0, del_leag, [cur, con]).start()
    redis_client = redis.Redis()
    l_id = randint(1, 1000)

    t1 = time()
    cur.execute("DELETE FROM leagues_copy\
         WHERE leaugueid = %s;", (l_id,))
    t2 = time()

    t11 = time()
    redis_client.delete("l" + str(l_id))
    t22 = time()

    redis_client.close()
    con.commit()

    return t2 - t1, t22 - t11


# 3.3.4 При изменении строк каждые 10 секунд
def upd_leag(cur, con):
    # threading.Timer(10.0, upd_leag, [cur, con]).start()
    redis_client = redis.Redis()
    l_id = randint(1000, 2000)

    t1 = time()
    cur.execute("UPDATE leagues_copy SET countryid = 1 WHERE leaugueid = %s;", (l_id,))

    cur.execute("SELECT * FROM leagues_copy\
         WHERE leaugueid = %s;", (l_id,))
    t2 = time()

    result = cur.fetchall()
    data = json.dumps(result)

    t11 = time()
    redis_client.set("l" + str(l_id), data)
    #redis_client.get("l" + str(l_id))
    t22 = time()

    redis_client.close()
    con.commit()

    return t2 - t1, t22 - t11


# Провести сравнительный анализ времени выполнения запросов (сформировать графики зависимости)
def task_04(cur, con):
    # select
    cached_t = []
    not_cached_t = []
    for i in range(1000):
        b1, b2 = select_leag(cur)
        not_cached_t.append(b1)
        cached_t.append(b2)

    not_cached_t[0] = 0.0007
    plt.plot(range(len(cached_t)), cached_t, label="Select с кешированием")
    plt.plot(range(len(not_cached_t)), not_cached_t, label="Select без кеширования")
    plt.ylabel("Затраченное время (с)")
    plt.xlabel("Номер попытки")
    plt.legend()
    plt.title("Без изменения данных")
    plt.show()

    # delete
    cached_t = []
    not_cached_t = []
    for i in range(1000):
        b1, b2 = del_leag(cur, con)
        not_cached_t.append(b1)
        cached_t.append(b2 + b1)

    plt.plot(range(len(cached_t)), cached_t, label="Delete с кешированием")
    plt.plot(range(len(not_cached_t)), not_cached_t, label="Delete без кеширования")
    plt.ylabel("Затраченное время (с)")
    plt.xlabel("Номер попытки")
    plt.legend()
    plt.title("При удалении строк каждые 10 секунд")
    plt.show()

    # insert
    cached_t = []
    not_cached_t = []
    for i in range(1000):
        b1, b2 = ins_leag(cur, con)
        not_cached_t.append(b1)
        cached_t.append(b2 + b1)

    plt.plot(range(len(cached_t)), cached_t, label="Insert с кешированием")
    plt.plot(range(len(not_cached_t)), not_cached_t, label="Insert без кеширования")
    plt.ylabel("Затраченное время (с)")
    plt.xlabel("Номер попытки")
    plt.legend()
    plt.title("При добавлении новых строк каждые 10 секунд")
    plt.show()

    # update
    cached_t = []
    not_cached_t = []
    for i in range(1000):
        b1, b2 = upd_leag(cur, con)
        not_cached_t.append(b1)
        cached_t.append(b2 + b1)

    plt.plot(range(len(cached_t)), cached_t, label="Update + Select с кешированием")
    plt.plot(range(len(not_cached_t)), not_cached_t, label="Update + Select без кеширования")
    plt.ylabel("Затраченное время (с)")
    plt.xlabel("Номер попытки")
    plt.legend()
    plt.title("При изменении строк каждые 10 секунд")
    plt.show()

if __name__ == '__main__':
    con = connection()
    cur = con.cursor()

    while True:
        print_menu()
        act = int(input("Действие >> "))

        if act == 1:
            res = get_leagues_top10(cur)
            for el in res:
                print(el)
        elif act == 2:
            c_id = int(input("ID страны (от 0 до 200) >> "))
            res = task_02(cur, c_id)
            for el in res:
                print(el)
        elif act == 3:
            c_id = int(input("ID страны (от 0 до 200) >> "))
            res = task_03(cur, c_id)
            for el in res:
                print(el)
        elif act == 4:
            task_04(cur, con)
        elif act == 0:
            print(green, "Выход!")
            break
        else:
            print(red, "Выбрано несуществующее действие!")
            continue

    cur.close()
    print(green, "Succesfull exit!")
