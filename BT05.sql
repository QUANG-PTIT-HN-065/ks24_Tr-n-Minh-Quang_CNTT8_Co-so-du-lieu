USE RikkeiClinicDB;
/*
PHẦN A: THIẾT KẾ KIẾN TRÚC
Thiết kế giao tiếp giữa 2 Procedure
Procedure phụ: FindEmptyBed

Nhiệm vụ:
- tìm giường trống theo khoa
- trả mã giường về cho procedure maste

Cách truyền dữ liệu
Input:
- IN p_dept_id
Output:
- OUT p_bed_id

chọn OUT Vì:
- Procedure phụ cần trả dữ liệu ngược về
- Master Procedure cần "hứng" mã giường để tiếp tục xử lý
*/

DELIMITER //

CREATE PROCEDURE FindEmptyBed(
    IN p_dept_id INT,
    OUT p_bed_id INT
)
BEGIN

    SELECT bed_id
    INTO p_bed_id
    FROM Beds
    WHERE dept_id = p_dept_id
    AND patient_id IS NULL
    LIMIT 1;

END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE EmergencyAdmission(
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_time DATETIME,
    IN p_dept_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN

    DECLARE v_bed_id INT;
    DECLARE v_check INT;
    DECLARE v_new_appointment INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Lỗi hệ thống';
    END;

    START TRANSACTION;
    SELECT COUNT(*)
    INTO v_check
    FROM Beds
    WHERE patient_id = p_patient_id;

    IF v_check > 0 THEN

        ROLLBACK;
        SET p_message = 'Từ chối: Bệnh nhân đang lưu trú';

    ELSE
        SELECT COUNT(*)
        INTO v_check
        FROM Departments
        WHERE dept_id = p_dept_id;

        IF v_check = 0 THEN

            ROLLBACK;
            SET p_message = 'Từ chối: Khoa không tồn tại';

        ELSE
            CALL FindEmptyBed(p_dept_id, v_bed_id);
            IF v_bed_id IS NULL THEN

                ROLLBACK;
                SET p_message = 'Từ chối: Khoa hiện đã hết giường';

            ELSE
                SELECT IFNULL(MAX(appointment_id),0) + 1
                INTO v_new_appointment
                FROM Appointments;

                INSERT INTO Appointments(
                    appointment_id,
                    patient_id,
                    doctor_id,
                    appointment_date,
                    status
                )
                VALUES(
                    v_new_appointment,
                    p_patient_id,
                    p_doctor_id,
                    p_time,
                    'Pending'
                );

                UPDATE Beds
                SET patient_id = p_patient_id
                WHERE bed_id = v_bed_id;

                COMMIT;

                SET p_message = 'Nhập viện thành công';

            END IF;

        END IF;

    END IF;

END //

DELIMITER ;

-- KIỂM THỬ
-- TH1 - Nhập viện thành công
CALL EmergencyAdmission(3,101,'2026-06-20 08:00:00',2,@msg);
SELECT @msg;

-- TH2 - Hết giường
CALL EmergencyAdmission(3,101,'2026-06-20 08:00:00',3,@msg);
SELECT @msg;

-- TH3 - Bệnh nhân đang nội trú
CALL EmergencyAdmission(1,101,'2026-06-20 08:00:00',2,@msg);
SELECT @msg;

-- TH4 - Khoa không tồn tại
CALL EmergencyAdmission(3,101,'2026-06-20 08:00:00',99,@msg);SELECT @msg;