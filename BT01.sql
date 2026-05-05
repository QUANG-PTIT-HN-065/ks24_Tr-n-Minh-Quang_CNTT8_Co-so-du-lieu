create database if not exists Session02;
use Session02;

/*
Bài 1

1. Phân tích

Lỗi 1: Sai lệch tiền bạc
Price DECIMAL(18, 2)
DECIMAL(18,2) là quá lớn, dư thừa
18 chữ số là mức dùng cho hệ thống tài chính lớn (ngân hàng)
Với sản phẩm thương mại điện tử bình thường → không cần lớn như vậy

Hậu quả: Tốn bộ nhớ không cần thiết, Khi tính toán nhiều bản ghi => có thể ảnh hưởng hiệu năng

Lỗi 2: Lãng phí bộ nhớ (nguyên nhân chính)

ProductName VARCHAR(255)
Description TEXT

Vấn đề: VARCHAR(255):
Nếu tên sản phẩm chỉ ~20–50 ký tự → 255 là dư thừa
Mỗi dòng đều phải cấp phát thêm metadata

TEXT:
Kiểu TEXT lưu ngoài vùng chính của bảng (overflow storage)
Tốn bộ nhớ + giảm hiệu năng truy vấn
Không cần thiết nếu mô tả ngắn

Hậu quả:
Tốn RAM + disk
Query chậm hơn
Server đầy nhanh bất thường
*/

create table products (
    id int auto_increment primary key,
    product_name varchar(100) not null,
    price decimal(10,2) not null,
    description varchar(500)
);