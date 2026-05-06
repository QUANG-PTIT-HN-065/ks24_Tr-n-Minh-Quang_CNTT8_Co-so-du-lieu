use Session03;
/*
1. Xử lý “bẫy dữ liệu”
Quantity âm
-> Không cho phép
-> Khi thêm hoặc update phải đảm bảo quantity > 0
Add trùng sản phẩm
-> Không insert dòng mới
-> Update tăng số lượng (cộng dồn)
*/

CREATE TABLE cart_items (
CartItemID INT PRIMARY KEY AUTO_INCREMENT,
UserID INT,
ProductID INT,
Quantity INT,
AddedDate DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

insert into cart_items (userid, productid, quantity)
values (1, 101, 1)
on duplicate key update quantity = quantity + values(quantity);

select productid, quantity, addeddate
from cart_items
where userid = 1;

update cart_items
set quantity = 5
where userid = 1
and productid = 101;

delete from cart_items
where userid = 1
and productid = 101;
