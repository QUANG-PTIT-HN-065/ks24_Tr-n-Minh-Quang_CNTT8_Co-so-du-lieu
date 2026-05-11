use Session06;

/*
1. Thiết kế I/O & Luồng
Dữ liệu được gom nhóm theo user_id.
COUNT(*) đếm tổng số đơn đặt của từng khách hàng.
CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END:
Nếu đơn bị hủy -> trả về 1.
Nếu không bị hủy -> trả về 0.
SUM(...) cộng các giá trị 1 và 0:
Mỗi đơn hủy đóng góp 1.
Các đơn khác đóng góp 0.
Kết quả chính là tổng số đơn bị hủy.
HAVING dùng để lọc sau khi đã tính toán:
Tổng số đơn >= 10.
Số đơn hủy > 5.

*/

SELECT 
    user_id,
    COUNT(*) AS total_bookings,
    SUM(CASE
        WHEN status = 'CANCELLED' THEN 1
        ELSE 0
    END) AS cancelled_bookings
FROM
    Bookings
GROUP BY user_id
HAVING COUNT(*) >= 10
    AND SUM(CASE
    WHEN status = 'CANCELLED' THEN 1
    ELSE 0
END) > 5;