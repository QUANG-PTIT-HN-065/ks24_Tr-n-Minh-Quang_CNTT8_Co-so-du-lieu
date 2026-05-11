use Session06;

/*
Bài 2

1. Phân tích kiến trúc

Khi sử dụng GROUP BY hotel_id, hệ quản trị cơ sở dữ liệu sẽ gom tất cả các phòng thuộc cùng một khách sạn thành một nhóm duy nhất.
Trong mỗi nhóm:
hotel_id chỉ có một giá trị xác định.
MIN(price_per_night) tính được giá nhỏ nhất của toàn bộ các phòng trong nhóm.
room_name có thể có nhiều giá trị khác nhau vì một khách sạn thường có nhiều loại phòng.

sau khi gom nhóm, cơ sở dữ liệu chỉ được phép trả về:

Các cột dùng để nhóm (hotel_id), hoặc
Các giá trị đã được tổng hợp (MIN(price_per_night)).

room_name không thuộc hai trường hợp trên. Vì trong một nhóm tồn tại nhiều tên phòng khác nhau, hệ thống không thể xác định chính xác phải chọn tên phòng nào để hiển thị.
Do đó, trong chế độ ONLY_FULL_GROUP_BY, MySQL sẽ từ chối truy vấn để tránh trả về kết quả mơ hồ và không chính xác.
*/

SELECT 
    hotel_id, MIN(price_per_night) AS min_price
FROM
    Rooms
GROUP BY hotel_id;