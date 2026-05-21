USE RikkeiClinicDB;

/*
Phần A: Phân tích:
Việc bệnh nhân bị “mất tích” khỏi hệ thống nội trú đã vi phạm tính Atomicity trong nguyên lý ACID.
Vì quá trình chuyển giường phải được thực hiện như một giao dịch thống nhất: hoặc hoàn thành cả 2 bước, hoặc phải hoàn tác toàn bộ nếu xảy ra lỗi.

Phần B: Sửa chữa mã nguồn
*/
DROP PROCEDURE IF EXISTS TransferBed;

DELIMITER //

CREATE PROCEDURE TransferBed(
    IN p_patient_id INT,
    IN p_new_bed_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        
        SELECT 'Chuyển giường thất bại - dữ liệu đã được hoàn tác'
        AS message;
    END;

    START TRANSACTION;

    UPDATE Beds
    SET patient_id = NULL
    WHERE patient_id = p_patient_id;

    UPDATE Beds
    SET patient_id = p_patient_id
    WHERE bed_id = p_new_bed_id;

    COMMIT;

END //

DELIMITER ;