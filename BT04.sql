/*
1. Phân tích & Đề xuất 2 giải pháp

Cách 1: Sửa trực tiếp cột (MODIFY)
alter table users
modify phone varchar(15);

Cách 2: Tạo cột mới -> migrate -> xóa cột cũ
-- thêm cột mới
alter table users add column phone_new varchar(15);

-- copy dữ liệu
update users set phone_new = phone;

-- xóa cột cũ
alter table users drop column phone;

-- đổi tên cột mới
alter table users change phone_new phone varchar(15);

2. So sánh
Tiêu chí	                      Cách 1: MODIFY	 Cách 2: Tạo cột mới
Độ đơn giản	                      Rất đơn giản	P       hức tạp hơn
Downtime	                     Có thể khóa bảng	   Giảm downtime
An toàn dữ liệu                   Rủi ro nếu lỗi   	An toàn hơn (có backup tạm)
Với bảng lớn (2 triệu record)	   Nguy hiểm	          Tốt hơn

3. Lựa chọn

Chọn Cách 2 (tạo cột mới)

Lý do:
Tránh lock bảng lâu
Không làm sập hệ thống đang chạy
Có thể rollback nếu lỗi
*/

alter table users add column phone_new varchar(15);
update users set phone_new = phone;
alter table users drop column phone;
alter table users change phone_new phone varchar(15);
