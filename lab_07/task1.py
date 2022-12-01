from py_linq import *
from club import *
from country import *
from colors import *


# Клубы со стоимостью выше 500 миллионов, отсортированные по названию
def req_1(clubs):
    res = clubs.where(lambda x: x['price'] > 500000000).\
        order_by(lambda x: x['nameclub']).select(lambda x: [x['nameclub'], x['price']])
    return res


# Максимальная и минимальная стоимость и id клубов, c id лиги меньше 500 и годом создания позже 1970 года
def req_2(clubs):
    target_clubs = clubs. \
        where(lambda x: x['leagueid'] < 500 and x['foundationyear'] > 1970)

    price = Enumerable([[target_clubs.min(lambda x: x['price']), target_clubs.max(lambda x: x['price'])]])
    clubid = Enumerable(
        [[target_clubs.min(lambda x: x['clubid']), target_clubs.max(lambda x: x['clubid'])]])
    res = Enumerable(price).union(Enumerable(clubid), lambda x: x)
    return res


# Количество клубов, созданных ранее 1980 года
def req_3(clubs):
    res = clubs.count(lambda x: x['foundationyear'] < 1980)
    return res


# Соединяем клубы и страны
def req_4(clubs, countries):
    res = clubs.join(countries, lambda o_k: o_k['countryid'], lambda i_k: i_k['countryid'])
    return res

# Количество клубов, название которых начинается с конкретной буквы
def req_5(clubs):
    res = clubs.group_by(key_names=['nameclub'], key=lambda x: x['nameclub'][3]). \
        select(lambda y: {'first_letter': y.key.nameclub, 'quantity': y.count()}). \
        order_by(lambda x: x['first_letter'])
    return res

def task_1():
    print(blue, '\n1. Клубы со стоимостью выше 500 миллионов, отсортированные по названию:\n')
    clubs = Enumerable(create_clubs('club.csv'))
    countries = Enumerable(create_countries('country.csv'))
    for el in req_1(clubs):
        print(white, el)

    print(blue, '\n2.Максимальная и минимальная стоимость и id клубов, '
                'c id лиги меньше 500 и годом создания позже 1970 года:\n')
    for el in req_2(clubs):
        print(white, el)

    print(blue, f'\n3. Количество клубов, созданных ранее 1980 года: {str(req_3(clubs))}')

    print(blue, '\n4. Соединяем клубы со странами:\n')
    i = 0
    for el in req_4(clubs, countries):
        if i == 10:
            break
        print(white, el)
        i += 1
    print(blue, '\n5. Количество клубов, название которых начинается с конкретной буквы:\n')
    for el in req_5(clubs):
        print(white, el)
task_1()
