USE RikkeiClinicDB;

-- 1. Phân tích & Giải pháp
-- đề xuất cấu trúc bảng 
CREATE TABLE Price_Changes_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    medicine_id INT NOT NULL,
    old_price DECIMAL(18,2) NOT NULL,
    new_price DECIMAL(18,2) NOT NULL,
    change_type VARCHAR(20) NOT NULL,
    difference DECIMAL(18,2) NOT NULL,
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (medicine_id) REFERENCES Medicines(medicine_id)
);
/*
Trigger sử dụng
Trigger 1: BEFORE UPDATE - Thời điểm chạy trước khi dữ liệu được cập nhật vào bảng Medicines.

Mục đích:
- Kiểm tra NEW.price.
- Nếu NEW.price <= 0 thì chặn cập nhật.

Trigger 2: AFTER UPDATE - Thời điểm chạy sau khi cập nhật thành công.

Mục đích:
- So sánh OLD.price và NEW.price.
- Nếu giá thay đổi thì ghi log.
- Nếu chỉ cập nhật tên thuốc hoặc tồn kho thì không ghi log.

- Luồng logic 
NEW.price > OLD.price => Ghi log TĂNG GIÁ, chênh lệch
NEW.price < OLD.price => Ghi log GIẢM GIÁ, chênh lệch
NEW.price = OLD.price => không ghi log
NEW.price <= 0 => Chặn cập nhật và báo lỗi
*/
DELIMITER //

CREATE TRIGGER trg_check_medicine_price
BEFORE UPDATE ON Medicines
FOR EACH ROW
BEGIN
    IF NEW.price <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Giá thuốc mới không hợp lệ';
    END IF;
END //

CREATE TRIGGER trg_log_medicine_price
AFTER UPDATE ON Medicines
FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO Price_Changes_Log (
            medicine_id,
            old_price,
            new_price,
            change_type,
            difference
        )
        VALUES (
            NEW.medicine_id,
            OLD.price,
            NEW.price,
            IF(NEW.price > OLD.price, 'TĂNG GIÁ', 'GIẢM GIÁ'),
            ABS(NEW.price - OLD.price)
        );
    END IF;
END //

DELIMITER ;

-- kiểm thử 
-- Tăng giá 
UPDATE Medicines
SET price = 18000
WHERE medicine_id = 1;

-- Giảm giá 
UPDATE Medicines
SET price = 4000
WHERE medicine_id = 2;

-- Cập nhật tồn kho, không sinh log
UPDATE Medicines
SET stock = stock + 20
WHERE medicine_id = 1;

-- Giá âm
UPDATE Medicines
SET price = -5000
WHERE medicine_id = 1;
