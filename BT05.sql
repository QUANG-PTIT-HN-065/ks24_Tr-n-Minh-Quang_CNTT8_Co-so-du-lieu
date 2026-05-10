
/*
1. Giải pháp kiến trúc

Dùng từ khóa:
CASE WHEN

CASE WHEN giúp:
Rẽ nhánh logic trong SQL
Tạo cột ảo ngay khi SELECT
Hoạt động giống if...else

2. Xử lý dữ liệu NULL

Một số khách hàng mới có:
total_orders = NULL

Nếu không xử lý:
So sánh NULL > 100 sẽ trả về UNKNOWN.
Có thể bị rơi vào nhánh sai.

Giải pháp:
Dùng: COALESCE(total_orders, 0)

Ý nghĩa:
Nếu total_orders là NULL -> đổi thành 0.
Đảm bảo logic luôn an toàn.
*/

SELECT 
    full_name AS Ten_Khach_Hang,
    CASE
        WHEN COALESCE(total_orders, 0) > 500 THEN 'Kim Cương'
        WHEN COALESCE(total_orders, 0) BETWEEN 100 AND 500 THEN 'Vàng'
        ELSE 'Bạc'
    END AS Xep_Hang
FROM
    Users