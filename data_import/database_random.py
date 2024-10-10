import random
from faker import Faker
import csv

# Initialize Faker
fake = Faker()

# Number of records
num_customers = 1000
num_orders = 1000
num_cookies = 5

# Cookie options
cookies = [
    {"name": "Chocolate Chip", "price": 1.50},
    {"name": "Oatmeal Raisin", "price": 1.25},
    {"name": "Peanut Butter", "price": 1.75},
    {"name": "Sugar Cookie", "price": 1.00},
    {"name": "Double Chocolate", "price": 2.00},
]

# Generate customers
customers = []
for i in range(1, num_customers + 1):
    name = fake.name()
    email = fake.email()
    address = fake.address().replace("\n", ", ")
    customers.append({
        "customer_id": i,
        "name": name,
        "email": email,
        "address": address
    })

# Generate orders
orders = []
for i in range(1, num_orders + 1):
    customer_id = random.randint(1, num_customers)
    order_date = fake.date_between(start_date="-1y", end_date="today")
    orders.append({
        "order_id": i,
        "customer_id": customer_id,
        "order_date": order_date
    })

# Generate order details
order_details = []
for order in orders:
    # Each order will have 1 to 3 items
    num_items = random.randint(1, 3)
    for _ in range(num_items):
        cookie = random.choice(cookies)
        quantity = random.randint(1, 20)
        total_price = round(quantity * cookie['price'], 2)
        order_details.append({
            "order_id": order["order_id"],
            "cookie_name": cookie["name"],
            "quantity": quantity,
            "total_price": total_price
        })

