use Session03;
/*
1. Phân tích & Đề xuất 2 giải pháp

Giải pháp 1: Hard Delete (xóa thật)
delete from orders
where status = 'Canceled';

Giải pháp 2: Soft Delete (xóa mềm)
update orders
set isdeleted = 1
where status = 'Canceled';

2. So sánh
Tiêu chí	                Hard Delete        	Soft Delete
Giải phóng dung lượng	   Tốt (xóa hẳn)	    Không giảm
Tốc độ truy vấn	Nhanh hơn	Cần thêm            điều kiện
Lịch sử kế toán         	Mất dữ liệu	       Giữ lại đầy đủ

3. Lựa chọn
Chọn Soft Delete
Lý do:
Kế toán vẫn cần dữ liệu để kiểm toán
Không được phép mất lịch sử
*/

-- 1. Cấu trúc bảng đơn hàng hiện tại
CREATE TABLE ORDERS (
OrderID INT PRIMARY KEY AUTO_INCREMENT,
CustomerName VARCHAR(100),
OrderDate DATETIME,
TotalAmount DECIMAL(18, 2),
Statu VARCHAR(20)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- 2. Dữ liệu thực tế: Hỗn hợp đơn hàng thành công và đơn hàng bị hủy
INSERT INTO ORDERS (CustomerName, OrderDate, TotalAmount, Status) VALUES
('Nguyễn Văn A', '2023-01-10', 500000, 'Completed'),
( 'Khách hàng vãng lai', '2023-02-15', 1200000, 'Canceled'), 
('Trần Thị B', '2023-05-20', 300000, 'Canceled'),
('Lê Văn C', '2024-01-05', 850000, 'Completed');

alter table orders
add column isdeleted tinyint(1) default 0;

update orders
set isdeleted = 1
where status = 'Canceled';

select * 
from orders
where isdeleted = 0;

select * 
from orders
where status = 'Canceled';

