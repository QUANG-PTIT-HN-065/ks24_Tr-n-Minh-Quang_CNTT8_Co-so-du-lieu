use Session03;

/*
Bài 2

1. Phân tích

a. Email cho phép NULL

Không có NOT NULL
Không có kiểm tra định dạng

Hậu quả: Nhiều khách hàng không có email => hệ thống gửi mail bị crash

b. Không kiểm soát dữ liệu Age

Không có ràng buộc CHECK

Hậu quả: Có dữ liệu như -5 tuổi → vô lý → lỗi logic hệ thống

c. Thiếu ràng buộc UNIQUE cho Email

Có thể bị trùng email

Hậu quả: Gửi email trùng lặp, Dữ liệu không sạch

d. FullName không có NOT NULL

Có thể bị null => dữ liệu không đầy đủ
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