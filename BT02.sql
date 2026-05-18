USE RikkeiClinicDB;

/* Phần A: Phân tích
1. Câu lệnh tái hiện lỗi
CALL AddInventory(10, -500);
2. Giải thích lỗi

Procedure hiện tại cộng trực tiếp giá trị p_quantity vào tồn kho mà không kiểm tra dữ liệu đầu vào.
Khi truyền số âm, phép cộng sẽ trở thành phép trừ, làm giảm số lượng tồn kho. */

-- Phần B: Sửa chữa mã nguồn
-- 1. Xóa thủ tục cũ
DROP PROCEDURE IF EXISTS AddInventory;

-- 2. Tạo lại thủ tục đúng logic
DELIMITER //

CREATE PROCEDURE AddInventory(
    IN p_item_id INT,
    IN p_quantity INT
)
BEGIN

    IF p_quantity > 0 THEN

        UPDATE Inventory
        SET stock_quantity = stock_quantity + p_quantity
        WHERE item_id = p_item_id;

    END IF;

END //

DELIMITER ;