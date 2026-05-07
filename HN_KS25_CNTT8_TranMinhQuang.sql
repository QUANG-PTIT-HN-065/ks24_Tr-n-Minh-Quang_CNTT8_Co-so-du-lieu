create database if not exists ShopManager;
use ShopManager;

create table if not exists Categories (
	category_id int primary key auto_increment,
    category_name varchar(100) not null unique
);

create table if not exists Products (
	product_id int primary key auto_increment,
    product_name varchar(100) not null unique,
    price decimal(10,2) check(price > 0),
    stock int check(stock > 0),
    category_id int
    -- foreign key(category_id) references product_id(category_id)
);

drop table Products;

insert into Categories(category_name) value
('Điện tử'),
('Thời trang');

insert into Products(product_name, price,stock) value 
('iPhone 15', 25000000 , 10),
('Samsung S23', 20000000, 5),
('Áo sơ mi nam', 500000, 50),
('Giày thể thao', 1200000, 20);

update Products
set  price = 26000000
where product_name = 'iPhone 15';

delete from Products
where product_id = 4;

delete from Products
where price < 1000000;

select * from Categories;
select * from Products;
select product_id, product_name ,price from Products;
select 
