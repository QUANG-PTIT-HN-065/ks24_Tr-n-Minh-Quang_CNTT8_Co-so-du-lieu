use Session03;

/*
Bài 2

1. Phân tích

Lỗi 1: Sai dấu nháy đơn (Syntax Error)

VALUES ('Giao Hàng Nhanh, '0901234567');
Thiếu dấu ' đóng sau Giao Hàng Nhanh
Làm sai cú pháp -> hệ thống báo lỗi

Lỗi 2: Không chỉ định cột khi INSERT

INSERT INTO SHIPPERS
VALUES ('Viettel Post');
Bảng có 3 cột: ShipperID, ShipperName, Phone
Nhưng chỉ truyền 1 giá trị -> lệch dữ liệu
Kết quả: Phone bị NULL hoặc lỗi
*/

CREATE TABLE SHIPPERS (
ShipperID INT PRIMARY KEY AUTO_INCREMENT,
ShipperName VARCHAR(255),
Phone VARCHAR(20)
);

INSERT INTO SHIPPERS (ShipperName, Phone)
VALUES ('Giao Hàng Nhanh', '0901234567');
INSERT INTO SHIPPERS (ShipperName, Phone)
VALUES ('Viettel Post', '0987654321');
