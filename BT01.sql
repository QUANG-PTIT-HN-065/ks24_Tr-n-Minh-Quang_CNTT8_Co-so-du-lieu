create database if not exists Session06;
use Session06;

/*
Bài 1

1. Phân tích lỗi
WHERE được thực thi trước GROUP BY.
Hàm tổng hợp SUM(total_price) chỉ có giá trị sau khi đã GROUP BY.
Vì vậy, không thể dùng SUM(total_price) trong WHERE.
Điều kiện lọc trên kết quả tổng hợp phải đặt trong HAVING.
*/

SELECT 
    city, SUM(total_price) AS revenue
FROM
    Bookings
WHERE
    status = 'COMPLETED'
GROUP BY city
HAVING SUM(total_price) > 0;