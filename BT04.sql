use Session06;
/*
1. Luồng tư duy
Cách 1: Lọc trễ (Bad Practice)
Database đọc toàn bộ đơn hàng, bao gồm cả COMPLETED, CANCELLED, FAILED.
Thực hiện GROUP BY hotel_id trên tất cả dữ liệu.
Sau đó mới dùng HAVING để giữ lại các khách sạn đạt điều kiện.

Nhược điểm:

Phải gom nhóm trên rất nhiều dữ liệu không cần thiết.
Tốn RAM để lưu các nhóm trung gian.
Tốn CPU để tính COUNT() và AVG().
Hiệu năng giảm mạnh khi dữ liệu lớn.

Cách 2: Lọc sớm (Clean Code)
Dùng WHERE status = 'COMPLETED' để loại bỏ ngay các đơn không thành công.
Chỉ những bản ghi cần thiết mới được đưa vào GROUP BY.
Dùng HAVING để kiểm tra:
Số đơn thành công >= 50.
Doanh thu trung bình > 3000000.

Ưu điểm:

Giảm số lượng dữ liệu phải xử lý.
Ít tốn RAM và CPU.
Truy vấn nhanh và tối ưu hơn.

2. So sánh hiệu năng
| Tiêu chí                   | Cách 1          | Cách 2             |
| -------------------------- | --------------- | ------------------ |
| Số bản ghi đem đi GROUP BY | Toàn bộ dữ liệu | Chỉ đơn thành công |
| CPU                        | Cao             | Thấp               |
| RAM                        | Cao             | Thấp               |
| Tốc độ                     | Chậm            | Nhanh              |
| Khuyến nghị                | Không nên dùng  | Nên dùng           |


*/

SELECT 
    hotel_id
FROM
    Bookings
WHERE
    status = 'COMPLETED'
GROUP BY hotel_id
HAVING COUNT(*) >= 50
    AND AVG(total_price) > 3000000;

