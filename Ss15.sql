CREATE DATABASE IF NOT EXISTS rikkeifood_db;
USE rikkeifood_db;

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS foods;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL,
    wallet_balance DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (wallet_balance >= 0)
);

CREATE TABLE restaurants (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_name VARCHAR(150) NOT NULL,
    address VARCHAR(255) NOT NULL,
    rating DECIMAL(2,1) DEFAULT 5.0,
    is_active TINYINT(1) DEFAULT 1,
    CHECK (rating >= 0 AND rating <= 5)
);

CREATE TABLE foods (
    food_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    food_name VARCHAR(150) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 99,
    is_available TINYINT(1) DEFAULT 1,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id) ON DELETE CASCADE,
    CHECK (price > 0),
    CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    restaurant_id INT,
    total_amount DECIMAL(10,2) NOT NULL,
    order_status ENUM('PENDING','PREPARING','SHIPPING','COMPLETED','CANCELLED') DEFAULT 'PENDING',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id) ON DELETE SET NULL,
    CHECK (total_amount >= 0)
);

CREATE INDEX idx_food_name ON foods(food_name);
CREATE INDEX idx_order_user ON orders(user_id);

INSERT INTO users(full_name,email,phone,wallet_balance) VALUES
('Nguyen Van A','vana@gmail.com','0912345678',500000.00),
('Tran Thi B','thib@gmail.com','0923456789',120000.00),
('Le Van C','vanc@gmail.com','0934567890',0.00),
('Pham Minh D','minhd@gmail.com','0945678901',250000.00),
('Hoang Thi E','thie@gmail.com','0956789012',1050000.00),
('Vu Hoang F','hoangf@gmail.com','0967890123',50000.00),
('Do Thi G','thig@gmail.com','0978901234',320000.00),
('Bui Van H','vanh@gmail.com','0989012345',75000.00),
('Dang Thi I','thii@gmail.com','0990123456',0.00),
('Ngo Van K','vank@gmail.com','0901234567',1500000.00);

INSERT INTO restaurants(restaurant_name,address,rating,is_active) VALUES
('Bun Cha Obama','24 Le Van Huu, Hai Ba Trung, Ha Noi',4.8,1),
('Pho Thin Bo Ho','61 Dinh Tien Hoang, Hoan Kiem, Ha Noi',4.5,1),
('Com Tam Cali','123 Nguyen Hue, Quan 1, TP HCM',4.2,1),
('Pizza Hut Cau Giay','222 Xuan Thuy, Cau Giay, Ha Noi',4.0,1),
('Ga Ran KFC Kim Ma','102 Kim Ma, Ba Dinh, Ha Noi',4.1,1),
('Banh Mi Huynh Hoa','26 Le Thi Rieng, Quan 1, TP HCM',4.9,1),
('Tra Sua DingTea','88 Tran Dai Nghia, Hai Ba Trung, Ha Noi',3.9,1),
('Sushi Kei','Tang 3 Aeon Mall Long Bien, Ha Noi',4.4,1),
('Lau Phan','7 Dao Duy Anh, Dong Da, Ha Noi',4.3,1),
('Com Nieu Sai Gon','59 Ho Xuan Huong, Quan 3, TP HCM',4.6,1);

INSERT INTO foods(restaurant_id,food_name,price,stock_quantity,is_available) VALUES
(1,'Bun Cha Dac Biet',60000.00,50,1),
(1,'Nem Cua Be',20000.00,100,1),
(2,'Pho Bo Tai Lan',55000.00,30,1),
(3,'Com Tam Suon Bi Cha',65000.00,40,1),
(4,'Pizza Hai San Co Vua',189000.00,15,1),
(5,'Combo Ga Ran 2 Mieng',89000.00,60,1),
(6,'Banh Mi Thap Cam',58000.00,120,1),
(7,'Tra Sua Tran Chau O Long',45000.00,200,1),
(9,'Buffet Lau Bo 199k',199000.00,80,1),
(10,'Com Nieu Dap',75000.00,25,1);

INSERT INTO orders(user_id,restaurant_id,total_amount,order_status) VALUES
(1,1,140000.00,'COMPLETED'),
(1,4,189000.00,'SHIPPING'),
(2,2,55000.00,'COMPLETED'),
(4,3,65000.00,'PREPARING'),
(5,6,116000.00,'COMPLETED'),
(5,9,398000.00,'COMPLETED'),
(7,7,45000.00,'PENDING'),
(8,5,89000.00,'CANCELLED'),
(10,10,150000.00,'COMPLETED'),
(10,1,60000.00,'PENDING');

SELECT *
FROM foods
WHERE is_available = 1;

SELECT *
FROM restaurants
WHERE rating >= 4.5
ORDER BY rating DESC;

SELECT *
FROM users
WHERE wallet_balance > 200000;

SELECT *
FROM orders
WHERE order_status = 'PENDING'
ORDER BY order_date DESC
LIMIT 5;

SELECT COUNT(*) AS total_active_restaurants
FROM restaurants
WHERE is_active = 1;

SELECT r.restaurant_id,
       r.restaurant_name,
       SUM(o.total_amount) AS total_revenue
FROM restaurants r
JOIN orders o ON r.restaurant_id = o.restaurant_id
WHERE o.order_status = 'COMPLETED'
GROUP BY r.restaurant_id, r.restaurant_name;

SELECT u.user_id,
       u.full_name,
       SUM(o.total_amount) AS total_spent
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.full_name
ORDER BY total_spent DESC
LIMIT 3;

SELECT *
FROM foods
WHERE price > (
    SELECT AVG(price)
    FROM foods
);

SELECT r.restaurant_id,
       r.restaurant_name
FROM restaurants r
LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id
WHERE o.order_id IS NULL;

DELIMITER $$

CREATE PROCEDURE get_foods_by_restaurant(
    IN p_restaurant_id INT
)
BEGIN
    SELECT *
    FROM foods
    WHERE restaurant_id = p_restaurant_id;
END $$

DELIMITER ;

CALL get_foods_by_restaurant(1);

DELIMITER $$

CREATE PROCEDURE recharge_wallet(
    IN p_user_id INT,
    INOUT p_amount DECIMAL(10,2)
)
BEGIN
    DECLARE old_balance DECIMAL(10,2);

    SELECT wallet_balance
    INTO old_balance
    FROM users
    WHERE user_id = p_user_id;

    UPDATE users
    SET wallet_balance = wallet_balance + p_amount
    WHERE user_id = p_user_id;

    SET p_amount = old_balance + p_amount;
END $$

DELIMITER ;

SET @new_balance = 100000;
CALL recharge_wallet(1,@new_balance);
SELECT @new_balance;

DELIMITER $$

CREATE TRIGGER trg_update_food_status
BEFORE UPDATE ON foods
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity = 0 THEN
        SET NEW.is_available = 0;
    END IF;
END $$

DELIMITER ;

UPDATE foods
SET stock_quantity = 0
WHERE food_id = 1;

DELIMITER $$

CREATE TRIGGER trg_check_wallet_before_order
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE current_balance DECIMAL(10,2);

    SELECT wallet_balance
    INTO current_balance
    FROM users
    WHERE user_id = NEW.user_id;

    IF current_balance < NEW.total_amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient wallet balance';
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE complete_order_payment(
    IN p_order_id INT
)
BEGIN
    DECLARE order_total DECIMAL(10,2);
    DECLARE customer_id INT;

    START TRANSACTION;

    SELECT total_amount, user_id
    INTO order_total, customer_id
    FROM orders
    WHERE order_id = p_order_id;

    UPDATE users
    SET wallet_balance = wallet_balance - order_total
    WHERE user_id = customer_id;

    UPDATE orders
    SET order_status = 'COMPLETED'
    WHERE order_id = p_order_id;

    COMMIT;
END $$

DELIMITER ;

CALL complete_order_payment(10);

DELIMITER $$

CREATE PROCEDURE cancel_order_and_refund(
    IN p_order_id INT
)
BEGIN
    DECLARE order_total DECIMAL(10,2);
    DECLARE customer_id INT;

    START TRANSACTION;

    SELECT total_amount, user_id
    INTO order_total, customer_id
    FROM orders
    WHERE order_id = p_order_id;

    UPDATE users
    SET wallet_balance = wallet_balance + order_total
    WHERE user_id = customer_id;

    UPDATE orders
    SET order_status = 'CANCELLED'
    WHERE order_id = p_order_id;

    COMMIT;
END $$

DELIMITER ;

CALL cancel_order_and_refund(2);

DELIMITER $$

CREATE PROCEDURE place_order(
    IN p_user_id INT,
    IN p_restaurant_id INT,
    IN p_food_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE current_stock INT;
    DECLARE food_price DECIMAL(10,2);
    DECLARE total_price DECIMAL(10,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    SELECT stock_quantity, price
    INTO current_stock, food_price
    FROM foods
    WHERE food_id = p_food_id;

    IF current_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Food out of stock';
    END IF;

    SET total_price = food_price * p_quantity;

    UPDATE foods
    SET stock_quantity = stock_quantity - p_quantity
    WHERE food_id = p_food_id;

    INSERT INTO orders(user_id,restaurant_id,total_amount,order_status)
    VALUES(p_user_id,p_restaurant_id,total_price,'PENDING');

    COMMIT;
END $$

DELIMITER ;

CALL place_order(1,1,1,2);
