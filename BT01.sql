create database if not exists Session03;
use Session05;

/*
Bài 1

1. Phân tích
AND ưu tiên cao hơn OR
Nên hệ thống hiểu thành:

WHERE district = 'Quận 1'
OR (district = 'Quận 3' AND rating > 4.0)

Hậu quả:
Tất cả quán ở Quận 1 đều được lấy ra
Kể cả quán rating thấp (2.0, 3.0)
Điều kiện rating > 4.0 chỉ áp dụng cho Quận 3
*/

SELECT 
    restaurant_name, address, rating
FROM
    Restaurants
WHERE
    (district = 'Quận 1'
        OR district = 'Quận 3')
        AND rating > 4.0