use Session02;

/*
Bài 1

1.Phân tích (I/O)

Bảng ORDERS cần:
order_id -> INT -> PRIMARY KEY, AUTO_INCREMENT
order_date -> DATE/DATETIME -> DEFAULT CURRENT_DATE
total_amount -> DECIMAL(10,2) -> NOT NULL, CHECK ≥ 0
customer_id -> INT -> NOT NULL, FOREIGN KEY

Ràng buộc:

PRIMARY KEY (order_id)
NOT NULL (order_date, total_amount, customer_id)
DEFAULT (order_date = ngày hiện tại)
CHECK (total_amount ≥ 0)
FOREIGN KEY (customer_id phải tồn tại trong CUSTOMERS)

*/

create table customers (
    customer_id int auto_increment primary key,
    fullname varchar(100) not null,
    email varchar(100) not null unique
);

create table orders (
    order_id int auto_increment primary key,
    order_date date default (current_date),
    total_amount decimal(10,2) not null check (total_amount >= 0),
    customer_id int not null,
    foreign key (customer_id) references customers(customer_id)
);