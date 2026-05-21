USE RikkeiClinicDB;

/*
1. Xác định dữ liệu đầu vào và đầu ra
Dữ liệu đầu vào

Hệ thống cần nhận:

p_patient_id -> Mã bệnh nhân
p_medicine_id -> Mã thuốc
p_quantity -> Số lượng cấp phát

=> Đây là các tham số IN.

Dữ liệu đầu ra

Hệ thống cần trả về:

"Đã cấp phát thành công"
"Lỗi: Số lượng tồn kho không đủ"

=> Nên sử dụng tham số OUT để trả thông báo trạng thái.

2. Giải pháp kiểm soát giao dịch

Bước 1
- Bắt đầu transaction bằng: START TRANSACTION;
Bước 2
-Kiểm tra số lượng tồn kho hiện tại.

Nếu: Tồn kho < số lượng yêu cầu

=> Báo lỗi: Số lượng tồn kho không đủ

và: ROLLBACK;

Bước 3

Nếu đủ thuốc:
+ Trừ kho thuốc
+ Tính tiền thuốc
+ Cộng vào công nợ bệnh nhân

Bước 4:
- Nếu toàn bộ thành công: COMMIT;

3. Triển khai 
*/

DELIMITER //

CREATE PROCEDURE DispenseMedicine(
    IN patientId INT,
    IN medicineId INT,
    IN soluong INT,
    OUT message VARCHAR(255)
)
BEGIN

    DECLARE slKho INT;
    DECLARE giaThuoc DECIMAL(18,2);
    DECLARE tongTien DECIMAL(18,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET message = 'Lỗi hệ thống';
    END;

    START TRANSACTION;

    SELECT stock, price
    INTO slKho, giaThuoc
    FROM Medicines
    WHERE medicine_id = medicineId;

    IF slKho < soluong THEN

        ROLLBACK;
        SET message = 'Lỗi: Số lượng tồn kho không đủ';

    ELSE

        UPDATE Medicines
        SET stock = stock - soluong
        WHERE medicine_id = medicineId;

        SET tongTien = giaThuoc * soluong;

        UPDATE Patient_Invoices
        SET total_due = total_due + tongTien
        WHERE patient_id = patientId;

        COMMIT;

        SET message = 'Đã cấp phát thành công';

    END IF;

END //

DELIMITER ;

-- TEST

-- TH1: Thành công
CALL DispenseMedicine(1, 1, 10, @msg);

SELECT @msg;

SELECT * 
FROM Medicines
WHERE medicine_id = 1;

SELECT * 
FROM Patient_Invoices
WHERE patient_id = 1;


-- TH2: Không đủ thuốc
CALL DispenseMedicine(1, 2, 10, @msg);

SELECT @msg;

SELECT * 
FROM Medicines
WHERE medicine_id = 2;

SELECT * 
FROM Patient_Invoices
WHERE patient_id = 1;