import psycopg2

import colors


class FootballDB:
    def __init__(self):
        try:
            self.__connection = psycopg2.connect(
                host='localhost',
                user='postgres',
                password='postgres',
                database='postgres'
            )
            self.__connection.autocommit = True
            self.__cursor = self.__connection.cursor()
            print("PostgreSQL connection opened successfully!\n")

        except Exception as err:
            print("Error: PostgreSQL connection\n", err)
            return

    def __del__(self):
        if self.__connection:
            self.__cursor.close()
            self.__connection.close()
            print("PostgreSQL connection closed successfully!\n")

    def __sql_executer(self, sql_query):
        try:
            self.__cursor.execute(sql_query)
        except Exception as err:
            print("Error: sql query failed\n", err)
            return
        return sql_query

    def scalar_query(self):
        print("%sПолучить среднюю стоимость клубов, созданных ранее 2000 года.%s\n"
              % (colors.blue, colors.white))

        sql_query = \
            """
            -- 1. Выполнить скалярный запрос.
            SELECT AVG(price)
            FROM clubs
            WHERE foundationyear < 2000
            """

        if self.__sql_executer(sql_query) is not None:
            row = self.__cursor.fetchone()
            return row

    def joins_query(self):
        print("%sНайти футболистов (имя, фамилия, страна - название, название клуба, стоимость футболиста)\n"
              "из клубов, со стоимостью выше 995 миллионов.%s\n"
              % (colors.blue, colors.white))

        sql_query = \
            """
            -- 2. Выполнить запрос с несколькими соединениями (JOIN).
            SELECT namefootballer, surname, namecountry, nameclub, fc.price
            FROM (footballers f 
            JOIN countries c on f.countryid = c.countryid) AS fc 
            JOIN clubs cl on fc.clubid = cl.clubid
            WHERE cl.price > 995000000;
            """

        if self.__sql_executer(sql_query) is not None:
            row = self.__cursor.fetchone()
            table = list()
            while row is not None:
                table.append(row)
                row = self.__cursor.fetchone()
            return table

    def cte_window_func_query(self):
        print("%sОТВ (обобщенное табличное выражение) id клуба, имя клуба, цена клуба,\n"
              "стоимость самого дорогого футболиста из данного клуба (для клубов с id < 20)%s\n"
              % (colors.blue, colors.white))

        sql_query = \
            """
            -- 3. Выполнить запрос с ОТВ(CTE) и оконными функциями.
            WITH CTE (clubid, nameclub, price, max_footb_price)
            AS (
                SELECT c.clubid, nameclub, c.price, MAX(f.price) OVER(PARTITION BY c.clubid) AS max_footb_price
                FROM clubs c JOIN footballers f on c.clubid = f.clubid
                WHERE c.clubid < 20
                ORDER BY c.clubid
            )
            -- удаление дубликатов с помощью оконной функции
            SELECT clubid, nameclub, price, max_footb_price
            FROM (SELECT clubid, nameclub, price, max_footb_price, row_number() OVER(PARTITION BY clubid) as rn
            FROM CTE) AS d
            WHERE d.rn = 1
            ORDER BY clubid;
            """

        if self.__sql_executer(sql_query) is not None:
            row = self.__cursor.fetchone()
            table = list()
            while row is not None:
                table.append(row)
                row = self.__cursor.fetchone()
            return table

    def metadata_query(self):
        print("%sПолучить индексы указанной таблицы.%s\n"
              % (colors.blue, colors.white))
        tablename = input("Введите имя таблицы >> ")
        sql_query = \
            f"""
            -- 4. Выполнить запрос к метаданным.
            SELECT * FROM pg_indexes
            WHERE tablename = '{tablename}'
            """
        if self.__sql_executer(sql_query) is not None:
            row = self.__cursor.fetchone()
            if row is not None:
                return [row]
            else:
                row = "%sДанной таблицы не существует!%s" % (colors.red, colors.white)
                return [row]

    def scalar_function_call(self):
        print("%sВозвращает максимальную стоимость футболиста из указанной страны\n"
              "c countryid=country_id%s\n"
              % (colors.blue, colors.white))
        try:
            c_id = int(input("Введите id страны >> "))
        except ValueError:
            print("%sНекорректный id страны!%s" % (colors.red, colors.white))
            return
        sql_query = \
            f"""
            -- 5. Вызвать скалярную функцию.
            SELECT get_max_footballer_price({c_id}) AS max_price;
            """
        if self.__sql_executer(sql_query) is not None:
            row = self.__cursor.fetchone()
            if str(row) != '(None,)':
                return row
            else:
                row = "%sДанной страны не существует или нет футболистов из этой страны!%s" % (colors.red, colors.white)
                return [row]

    def tabular_function_call(self):
        print("%sСравнение клубов по стоимости с id в отрезке [bid, eid]%s\n"
              % (colors.blue, colors.white))
        try:
            bid = int(input("Введите bid >> "))
            eid = int(input("Введите eid >> "))
        except ValueError:
            print("%sНекорректный id клуба, bid и eid = {1,..., 1000}!%s" % (colors.red, colors.white))
            return
        if bid > eid or eid > 1000 or bid < 1:
            print("%sНекорректный id клуба, bid и eid = {1,..., 1000}!%s" % (colors.red, colors.white))
            return
        sql_query = \
            f"""
            -- 6. Вызвать многооператорную табличную функцию.
            SELECT *
            FROM get_price_clubs_inf({bid}, {eid});
            """
        print('\n(clubid, nameclub, price_diff, price_min, price_max)')
        if self.__sql_executer(sql_query) is not None:
            row = self.__cursor.fetchone()
            table = list()
            while row is not None:
                table.append(row)
                row = self.__cursor.fetchone()
            return table

    def stored_procedure_call(self):
        print("%sПоменять клуб футболиста с id = f_id на клуб с id = new_cl_id%s\n"
              % (colors.blue, colors.white))
        try:
            fid = int(input("Введите f_id >> "))
            clid = int(input("Введите new_cl_id >> "))
        except ValueError:
            print("%sНекорректный id, f_id и new_cl_id = {1,..., 1000}!%s" % (colors.red, colors.white))
            return
        sql_query = \
            f"""
            -- 7. Вызвать хранимую процедуру.
            CALL change_club({fid}, {clid});
            SELECT footballerid, namefootballer, surname, clubid, price
            FROM footballers_copy
            WHERE footballerid = {fid};
            """
        print('\n(footballerid, namefootballer, surname, clubid, price)')
        if self.__sql_executer(sql_query) is not None:
            row = self.__cursor.fetchone()
            table = list()
            while row is not None:
                table.append(row)
                row = self.__cursor.fetchone()
            return table

    def system_function_call(self):
        print("%sВызвать системную функцию для вывода имени текущей базы данных.%s\n"
              % (colors.blue, colors.white))

        sql_query = \
            """
            -- 8. Вызвать системную функцию.
            SELECT current_database(), current_user;
            """

        if self.__sql_executer(sql_query) is not None:
            row = self.__cursor.fetchone()
            res = f"Имя текущей базы данных: {row[0]}\nИмя текущего пользователя: {row[1]}"
            return [res]

    def create_new_table(self):
        print("%sСоздаем таблицу тренеров клубов (Coaches).%s\n"
              % (colors.blue, colors.white))

        sql_query = \
            """
            -- 9. Создать таблицу в базе данных, соответствующую тематике БД.
            DROP TABLE IF EXISTS Coaches;
            CREATE TABLE IF NOT EXISTS Coaches(
                CoachId INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                NameCoach VARCHAR(100) NOT NULL,
                Surname VARCHAR(100) NOT NULL,
                ClubId INT NOT NULL check (ClubId BETWEEN 1 and 1000)
            );
            """
        if self.__sql_executer(sql_query) is not None:
            self.__connection.commit()  # фиксируем изменения (создание новой таблицы)
            print("Table Coaches successfully added!")

    def insert_into_new_table(self):
        print("%sВыполнить вставку данных в созданную таблицу тренеров.%s\n"
              % (colors.blue, colors.white))
        try:
            cname = input("Введите имя тренера >> ")
            csurname = input("Введите фамилию тренера >> ")
            clid = int(input("Введите id клуба >> "))
        except ValueError:
            print("%sНекорректный ввод!%s" % (colors.red, colors.white))
            return
        self.__cursor.execute("INSERT INTO Coaches(namecoach, surname, clubid) VALUES (%s, %s, %s);"
                              "SELECT * FROM coaches;", (cname, csurname, clid))

        row = self.__cursor.fetchone()
        table = list()
        while row is not None:
            table.append(row)
            row = self.__cursor.fetchone()
        return table