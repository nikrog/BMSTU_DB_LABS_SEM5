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
        return {'clubid': self.clubid, 'nameclub': self.nameclub, 'countryid': self.countryid,
                'leagueid': self.leagueid, 'foundationyear': self.foundationyear, 'price': self.price}

    def __str__(self):
        return f"{self.clubid:<3} {self.nameclub:<25} {self.countryid:<3}" \
               f" {self.leagueid:<3} {self.foundationyear:<4} {self.price:<15}"


def create_clubs(file_name):
    f = open(file_name, 'r')
    clubs = list()
    i = 1
    for s in f:
        a = s.split(';')
        a[1], a[2], a[3], a[4] = int(a[1]), int(a[2]), \
                                       int(a[3]), float(a[4])
        clubs.append(Club(i, *a).get())
        i += 1
    return clubs
