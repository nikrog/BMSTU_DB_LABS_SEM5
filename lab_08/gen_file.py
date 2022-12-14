from faker import Faker
from random import randint, choice
import datetime
import time
import json

class Club:
    clubid = int()
    nameclub = str()
    countryid = int()
    leagueid = int()
    foundationyear = int()
    price = float()

    def __init__(self, clubid, nameclub, countryid, leagueid, foundationyear, price):
        self.clubid = clubid
        self.nameclub = nameclub
        self.countryid = countryid
        self.leagueid = leagueid
        self.foundationyear = foundationyear
        self.price = price

    def get(self):
        return {'clubid':self.clubid, 'nameclub': self.nameclub, 'countryid': self.countryid,
                'leagueid': self.leagueid, 'foundationyear': self.foundationyear, 'price': self.price}

    def __str__(self):
        return f" {self.clubid:<3} {self.nameclub:<25} {self.countryid:<3}" \
               f" {self.leagueid:<3} {self.foundationyear:<4} {self.price:<15}"

def main():
    i = 1111
    faker = Faker()
    while True:
        lis = []
        for _ in range(1, 10):
            name_res = faker.name()
            name_res = name_res.split(' ')
            name_res = 'FC ' + str(name_res[1])
            country = randint(1, 200)
            league = randint(1, 1000)
            year = randint(1850, 2022)
            price = randint(1, 1000) * 1e6
            obj = Club(i, name_res
                        , country
                        , league
                        , year
                        , price)
            lis.append(obj.get())
            i += 1

        file_name = "./data/clubs_" + str(i) + "_" + \
                    str(datetime.datetime.now().strftime("%d-%m-%Y_%H:%M:%S")) + ".json"

        print(file_name)

        with open(file_name, "w") as f:
            print(json.dumps(lis), file=f)

        time.sleep(10)


if __name__ == "__main__":
    main()