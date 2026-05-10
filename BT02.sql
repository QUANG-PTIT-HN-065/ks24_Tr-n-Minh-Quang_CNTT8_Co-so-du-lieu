use Session05;

/*
Bài 2

1. Phân tích
LIMIT 5 chỉ giới hạn số lượng dòng, nhưng không quy định thứ tự dữ liệu.

=> SQL có thể lấy ngẫu nhiên 5 dòng bất kỳ tùy cách lưu dữ liệu hoặc execution plan.

Hậu quả
Refresh app sẽ ra danh sách khác nhau
Không đảm bảo là quán mới nhất
Sai yêu cầu nghiệp vụ của PO
*/

SELECT 
    restaurant_name, created_at
FROM
    Restaurants
ORDER BY created_at DESC
LIMIT 5;