
import csv
import time
import requests
from bs4 import BeautifulSoup

class MEP:
    def __init__(self, url):
        self.url = url
        self.info = self.get_info() 
    def get_info(self):
        url = self.url
        r = requests.get(url)
        soup = BeautifulSoup(r.text, "lxml")
        birth_date_raw = soup.find_all("time", {"class": "sln-birth-date"})
        if len(birth_date_raw) == 0:
            birth_date = "N/A"
        else:
            birth_date = birth_date_raw[0].attrs.get("datetime")
        birth_place_raw = soup.find_all("span", {"class": "sln-birth-place"})
        if len(birth_place_raw) == 0:
            birth_place = "N/A"
        else:
            birth_place = birth_place_raw[0].text
        name_raw = soup.find_all("span", {"class": "sln-member-name"})
        name = name_raw[0].text
        central_info = soup.find_all("div", {"class": "mb-2 text-center"})
        ## no better way to do this?
        childs = []
        for i in central_info[0].children:
            childs.append(i)
        if len(childs) < 13:
            ep_party = "N/A"
            local_party = "N/A"
        else:
            ep_party = childs[3].text
            local_party = childs[13].text.strip().split(" - ")[1]
        info_ep = {
            "name": name,
            "birth_date": birth_date,
            "birth_place": birth_place,
            "ep_party": ep_party,
            "local_party": local_party
        }
        return info_ep
    def __str__(self):
        return f"{self.name} ({self.party}) from {self.country} can be reached at {self.email}"

url = "https://www.europarl.europa.eu/meps/en/full-list/all"
r = requests.get(url)
soup = BeautifulSoup(r.text, "lxml")
all_mep = soup.find_all("a", {"class": "erpl_member-list-item-content"})

all_mep_url = []

for i in all_mep:
    all_mep_url.append(i.get("href"))

meps = []
for i in all_mep_url:
    time.sleep(.5)
    print(i)
    mep_inst = MEP(i)
    meps.append(mep_inst.info)
    print(len(meps))

fnames = ['name', 'birth_date', 'birth_place', 'ep_party', 'local_party']
with open('mep.csv', 'w') as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames = fnames)
    writer.writeheader()
    writer.writerows(meps)
