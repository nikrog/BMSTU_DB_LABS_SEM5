from colors import green, white, red
from data_base import FootballDB

MENU = "\n\t\t\t\t\t%sМЕНЮ\n" \
       "1. Выполнить скалярный запрос \n" \
       "2. Выполнить запрос с несколькими соединениями (JOIN) \n" \
       "3. Выполнить запрос с ОТВ(CTE) и оконными функциями \n" \
       "4. Выполнить запрос к метаданным \n" \
       "5. Вызвать скалярную функцию \n" \
       "6. Вызвать многооператорную или табличную функцию \n" \
       "7. Вызвать хранимую процедуру \n" \
       "8. Вызвать системную функцию\n" \
       "9. Создать таблицу в базе данных, соответствующую тематике БД \n" \
       "10. Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT \n" \
       "0. Выход \n\n" \
       "Команда >> %s" \
       % (green, white)


def input_cmd():
    try:
        cmd = int(input(MENU))
        print()
    except ValueError:
        cmd = -1

    if cmd < 0 or cmd > 10:
        print("%s\nНомер команды должен быть от 0 до 10! %s" % (red, white))
    return cmd


def print_table(table):
    if table is not None:
        for row in table:
            print(row)


def main():
    football_db = FootballDB()
    cmd = -1

    while cmd != 0:
        cmd = input_cmd()
        if cmd == 1:
            table = football_db.scalar_query()
        elif cmd == 2:
            table = football_db.joins_query()
        elif cmd == 3:
            table = football_db.cte_window_func_query()
        elif cmd == 4:
            table = football_db.metadata_query()
        elif cmd == 5:
            table = football_db.scalar_function_call()
        elif cmd == 6:
            table = football_db.tabular_function_call()
        elif cmd == 7:
            table = football_db.stored_procedure_call()
        elif cmd == 8:
            table = football_db.system_function_call()
        elif cmd == 9:
            table = football_db.create_new_table()
        elif cmd == 10:
            table = football_db.insert_into_new_table()
        else:
            continue
        print_table(table)
    print("Программа завершена!")


if __name__ == "__main__":
    main()