create database if not exists Session03;
use Session03;

/*
Bài 1

1. Phân tích

Lỗi nằm ở câu lệnh:

UPDATE PRODUCTS
SET OriginalPrice = OriginalPrice * 0.9;

Thiếu WHERE

Hậu quả:

UPDATE không có điều kiện -> áp dụng cho toàn bộ bảng
Tất cả sản phẩm đều bị giảm giá (không phân biệt ngành hàng)

=> Đây là lỗi kinh điển: UPDATE không WHERE = sửa toàn bộ dữ liệu



*/

CREATE TABLE PRODUCTS (
ProductID INT PRIMARY KEY,
ProductName VARCHAR(100),
Category VARCHAR(50),
OriginalPrice DECIMAL (18,2)
);

INSERT INTO PRODUCTS (ProductID, ProductName, Category, OriginalPrice)
VALUES
(1, 'iPhone 15', 'Electronics', 20000000),
(2, 'Samsung Refrigerator', 'Electronics', 15000000),
(3, 'Water Spinach', 'Food', 10000),
(4, 'Filtered Fresh Milk 4', 'Food', 28000);


UPDATE PRODUCTS
SET OriginalPrice = OriginalPrice * 0.9
WHERE Category = 'Electronics';