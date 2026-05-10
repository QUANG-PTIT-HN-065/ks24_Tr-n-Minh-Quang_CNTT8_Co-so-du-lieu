/*
1. Giải pháp 1 - Dùng OR

SELECT *
FROM Orders
WHERE cancel_reason = 'KHACH_HUY'
   OR cancel_reason = 'QUAN_DONG_CUA'
   OR cancel_reason = 'KHONG_CO_TAI_XE'
   OR cancel_reason = 'BOM_HANG';
   
Ưu điểm
Dễ hiểu với người mới học SQL.

Nhược điểm
Code dài, lặp.
Khó bảo trì nếu có nhiều điều kiện.

2. Giải pháp 2 - Dùng IN

SELECT *
FROM Orders
WHERE cancel_reason IN (
    'KHACH_HUY',
    'QUAN_DONG_CUA',
    'KHONG_CO_TAI_XE',
    'BOM_HANG'
);

Ưu điểm
Code ngắn gọn.
Dễ mở rộng.
SQL Engine tối ưu tốt hơn khi lọc nhiều giá trị.

Nhược điểm
Người mới học có thể khó hiểu hơn OR.

3. Bảng so sánh
| Tiêu chí             | OR             | IN              |
| -------------------- | -------------- | --------------- |
| Code sạch            | Dài, lặp       | Ngắn gọn        |
| Mở rộng 20 điều kiện | Khó bảo trì    | Dễ thêm dữ liệu |
| Hiệu năng SQL Engine | Kém tối ưu hơn | Tối ưu hơn      |

4. Bẫy NULL
Sai cách:
WHERE cancel_reason IN ('KHACH_HUY', NULL)
Kết quả
Không lấy được các dòng NULL.
Lý do
Trong SQL:
NULL = NULL
không trả về TRUE mà trả về UNKNOWN.
Vì vậy:
IN (..., NULL)
không hoạt động với giá trị NULL.
Phải dùng:
IS NULL

*/

SELECT 
    *
FROM
    Orders
WHERE
    cancel_reason IN ('KHACH_HUY' , 'QUAN_DONG_CUA',
        'KHONG_CO_TAI_XE',
        'BOM_HANG')
        OR cancel_reason IS NULL;

