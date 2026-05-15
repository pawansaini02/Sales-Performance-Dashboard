"""
VRT Sales — Sample Data Generator
Run this to create realistic CSV files you can use to demo the dashboard
without needing a real database.
Usage: python generate_sample_data.py
"""

import csv
import random
import datetime
import os

random.seed(42)

CLIENTS = [
    ("Apex Retail LLC","Retail","New York","NY"),
    ("BlueSky Ventures","Tech","California","CA"),
    ("Cornerstone Mfg","Manufacturing","Texas","TX"),
    ("Delta Foods Inc","F&B","Florida","FL"),
    ("Evergreen Spa","Health","Illinois","IL"),
    ("Franklin Auto","Automotive","New York","NY"),
    ("Greenwood Tech","Tech","California","CA"),
    ("Harbor Logistics","Logistics","Texas","TX"),
    ("Ironclad Finance","Finance","Florida","FL"),
    ("Jasper Consulting","Consulting","Illinois","IL"),
    ("Keystone Builders","Construction","New York","NY"),
    ("Lakefront Hotels","Hospitality","California","CA"),
    ("Maple Street Cafe","F&B","Texas","TX"),
    ("Northgate Pharma","Healthcare","Florida","FL"),
    ("Orion Digital","Tech","Illinois","IL"),
    ("Pioneer Solar","Energy","New York","NY"),
    ("Quantum Labs","Tech","California","CA"),
    ("Riverdale Law","Legal","Texas","TX"),
    ("Sunrise Insurance","Finance","Florida","FL"),
    ("TechNova Inc","Tech","Illinois","IL"),
]

PROGRAMS = [("EGA",8500),("EGOS",12000),("Entrepreneurial Edge",6500)]
REPS      = ["M. Shah","P. Rajan","S. Gupta","A. Patel"]
STAGES    = (["Closed Won"]*68) + (["Closed Lost"]*20) + (["In Progress"]*12)

def rand_date(start, end):
    delta = end - start
    return start + datetime.timedelta(days=random.randint(0, delta.days))

start = datetime.date(2024,1,1)
end   = datetime.date(2024,12,31)

deals = []
for i in range(1, 301):
    client  = random.choice(CLIENTS)
    program = random.choice(PROGRAMS)
    stage   = random.choice(STAGES)
    value   = program[1] + random.randint(-2000, 8000)
    deals.append({
        "deal_id":      i,
        "client_name":  client[0],
        "industry":     client[1],
        "region":       client[2],
        "state":        client[3],
        "program":      program[0],
        "deal_value":   max(value, 2000),
        "stage":        stage,
        "close_date":   rand_date(start, end),
        "rep":          random.choice(REPS),
    })

os.makedirs("data", exist_ok=True)
with open("data/deals.csv","w",newline="") as f:
    w = csv.DictWriter(f, fieldnames=deals[0].keys())
    w.writeheader()
    w.writerows(deals)

print(f"✅ Generated {len(deals)} deals → data/deals.csv")
print("   Load this CSV into Power BI, Google Sheets, or Supabase!")
