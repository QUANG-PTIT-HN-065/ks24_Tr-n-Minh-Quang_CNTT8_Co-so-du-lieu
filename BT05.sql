USE RikkeiClinicDB;
/*
Thiết kế giao tiếp giữa 2 Procedure
Procedure Master

Input
| Tham số          | Loại |
| ---------------- | ---- |
| p_patient_id     | IN   |
| p_target_dept_id | IN   |

Output
| Tham số      | Loại |
| ------------ | ---- |
| p_new_bed_id | OUT  |
| p_message    | OUT  |

Procedure phụ FindEmptyBed
Input
| Tham số   | Loại |
| --------- | ---- |
| p_dept_id | IN   |

Output
| Tham số  | Loại |
| -------- | ---- |
| p_bed_id | OUT  |

Cách trao đổi dữ liệu
Procedure Master sẽ dùng biến OUT để “hứng” mã giường trống trả về từ Procedure phụ.

Phần B: Triển khai Code & Kiểm thử
*/
-- 1. Procedure phụ tìm giường trống
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

-- 2. Procedure Master điều phối chuyển giường
DELIMITER //

CREATE PROCEDURE TransferPatientBed(
    IN p_patient_id INT,
    IN p_target_dept_id INT,
    OUT p_new_bed_id INT,
    OUT p_message VARCHAR(200)
)
BEGIN

    DECLARE v_current_bed_id INT;
    DECLARE v_empty_bed_id INT;
    DECLARE v_dept_name VARCHAR(100);
    DECLARE v_completed_count INT;

    -- Kiểm tra khoa tồn tại
    SELECT dept_name
    INTO v_dept_name
    FROM Departments
    WHERE dept_id = p_target_dept_id;

    IF v_dept_name IS NULL THEN

        SET p_new_bed_id = NULL;
        SET p_message = 'Từ chối: Khoa không tồn tại';

    ELSE

        -- Kiểm tra bệnh nhân đã xuất viện chưa
        SELECT COUNT(*)
        INTO v_completed_count
        FROM Appointments
        WHERE patient_id = p_patient_id
          AND status = 'Completed';

        IF v_completed_count > 0 THEN

            SET p_new_bed_id = NULL;
            SET p_message = 'Từ chối: Bệnh nhân đã xuất viện';

        ELSE

            -- Gọi procedure phụ tìm giường trống
            CALL FindEmptyBed(
                p_target_dept_id,
                v_empty_bed_id
            );

            -- Hết giường
            IF v_empty_bed_id IS NULL THEN

                SET p_new_bed_id = NULL;

                SET p_message =
                    CONCAT(
                        'Từ chối: Khoa ',
                        v_dept_name,
                        ' đã hết giường'
                    );

            ELSE

                START TRANSACTION;

                -- Lấy giường hiện tại
                SELECT bed_id
                INTO v_current_bed_id
                FROM Beds
                WHERE patient_id = p_patient_id
                LIMIT 1;

                -- Giải phóng giường cũ
                UPDATE Beds
                SET patient_id = NULL
                WHERE bed_id = v_current_bed_id;

                -- Gán giường mới
                UPDATE Beds
                SET patient_id = p_patient_id
                WHERE bed_id = v_empty_bed_id;

                COMMIT;

                SET p_new_bed_id = v_empty_bed_id;

                SET p_message =
                    'Chuyển giường thành công';

            END IF;

        END IF;

    END IF;

END //

DELIMITER ;

-- 3. Kiểm thử
-- Chuyển khoa thành công 
CALL TransferPatientBed(
    1,
    2,
    @new_bed_id,
    @message
);

SELECT @new_bed_id, @message;

-- Bẫy hết giường trống
-- Khoa ICU (dept_id = 3) hiện không còn giường trống.
CALL TransferPatientBed(
    1,
    3,
    @new_bed_id,
    @message
);

SELECT @new_bed_id, @message;

-- Bẫy bệnh nhân đã xuất viện
-- Bệnh nhân 2 có lịch khám Completed.
CALL TransferPatientBed(
    2,
    1,
    @new_bed_id,
    @message
);

SELECT @new_bed_id, @message;

-- Dept_ID không tồn tại
CALL TransferPatientBed(
    1,
    999,
    @new_bed_id,
    @message
);

SELECT @new_bed_id, @message;