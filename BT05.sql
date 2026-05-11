use Session06;
/*
1. Bẫy logic của NOT IN

Nếu subquery trả về danh sách có chứa NULL, ví dụ:

(1, 2, NULL)

Thì điều kiện:

room_id NOT IN (1, 2, NULL)

Tương đương:

room_id <> 1 AND room_id <> 2 AND room_id <> NULL

So sánh với NULL luôn cho kết quả UNKNOWN, nên toàn bộ biểu thức trở thành UNKNOWN, và WHERE sẽ loại bỏ tất cả các dòng.

Kết quả: truy vấn trả về 0 bản ghi.

2. Giải pháp an toàn

Dùng LEFT JOIN:

Ghép tất cả phòng từ bảng Rooms.
Nếu phòng chưa từng được đặt, bảng Bookings sẽ không có bản ghi tương ứng.
Khi đó các cột của Bookings sẽ có giá trị NULL.
Lọc những dòng có b.room_id IS NULL.
*/

SELECT 
    r.room_id, r.room_name
FROM
    Rooms r
        LEFT JOIN
    Bookings b ON r.room_id = b.room_id
WHERE
    b.room_id IS NULL;