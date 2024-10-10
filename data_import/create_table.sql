CREATE TABLE Customers (
    customer_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100),
    email VARCHAR(100),
    address VARCHAR(200)
);

-- Creating Cookies Table
CREATE TABLE Cookies (
    cookie_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100),
    description VARCHAR(255),
    price DECIMAL(10, 2)
);

-- Creating Orders Table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY IDENTITY(1,1),
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Creating Order_Details Table
CREATE TABLE Order_Details (
    order_detail_id INT PRIMARY KEY IDENTITY(1,1),
    order_id INT,
    cookie_id INT,
    quantity INT,
    total_price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (cookie_id) REFERENCES Cookies(cookie_id)
);