use Session03;

/*
Bài 1

1.Phân tích (I/O)
Input:
Bảng: CUSTOMERS
Cột cần dùng để lọc:
City
LastPurchaseDate
Status
Email

Output:
Chỉ cần:
FullName
Email

không dùng SELECT * vì :
Bảng có hàng chục cột + hàng triệu bản ghi
SELECT * -> lấy toàn bộ dữ liệu không cần thiết
Gây:
Tốn RAM
Chậm query
Nghẽn hệ thống
=> Chỉ select đúng cột cần dùng

Giải pháp:
Logic lọc dữ liệu (WHERE)

Cần các điều kiện:

City = 'Hà Nội'
LastPurchaseDate < '2025-10-01'
(vì 01/04/2026 - 6 tháng => 01/10/2025)
Email IS NOT NULL
Status = 'Active'

*/

CREATE TABLE CUSTOMERS (
CustomerID INT PRIMARY KEY AUTO_INCREMENT,
FullName VARCHAR(100),
Email VARCHAR(100),
City VARCHAR(50),
LastPurchaseDate DATE, 
Statu VARCHAR(20),
Gender VARCHAR(10),
DateOfBirth DATE,
Points INT,
Address VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO CUSTOMERS (FullName, Email, City, LastPurchaseDate, Status) VALUES
('Nguyễn Văn A', 'anv@gmail.com', 'Hà Nội', '2025-05-20', 'Active'),
('Trân Thị B', 'btt@gmail.com', 'Hà Nội', '2026-02-10', 'Active'),
('Lê Văn C', NULL, 'Hà Nội', '2025-01-15', 'Active'),
('Phạm Minh D', 'dpm@gmail.com', 'Hà Nội', '2024-12-01', 'Locked'),
('Hoàng An E', 'eha@gmail.com', 'TP HCM', '2025-03-01', 'Active');

select fullname, email
from customers
where city = 'Hà Nội'
and lastpurchasedate < '2025-10-01'
and email is not null
and status = 'Active';
