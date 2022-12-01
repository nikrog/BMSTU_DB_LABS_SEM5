class Country:
    countryid = int()
    namecountry = str()
    capital = str()
    square = float()
    population = float()

    def __init__(self, countryid, namecountry, capital, square, population):
        self.countryid = countryid
        self.namecountry = namecountry
        self.capital = capital
        self.square = square
        self.population = population

    def get(self):
        return {'countryid': self.countryid, 'namecountry': self.namecountry, 'capital': self.capital,
                'square': self.square, 'population': self.population}

    def __str__(self):
        return f"{self.countryid:<3} {self.namecountry:<25} {self.capital:<25}" \
               f" {self.square:<15} {self.population:<15}"


def create_countries(file_name):
    f = open(file_name, 'r')
    countries = list()
    i = 1
    for s in f:
        a = s.split(';')
        a[2], a[3] = float(a[2]), float(a[3])
        countries.append(Country(i, *a).get())
        i += 1
    return countries
