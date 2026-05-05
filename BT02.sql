use Session02;

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

create table customers (
    customer_id int primary key auto_increment,
    fullname varchar(100) ,
    email varchar(100) ,
    age int 
);

alter table customers
modify email varchar(100) not null;

alter table customers
add unique (email);

alter table customers
modify fullname varchar(100) not null;

alter table customers
add check (age >= 0);