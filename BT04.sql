USE RikkeiClinicDB;
/*
Phần A: Phân tích & Đề xuất đa giải pháp
1. Định nghĩa Input / Output
Input
| Tham số      | Vai trò       | Kiểu |
| ------------ | ------------- | ---- |
| p_patient_id | Mã bệnh nhân  | IN   |
| p_phone      | Số điện thoại | IN   |

Output
| Tham số     | Vai trò              | Kiểu |
| ----------- | -------------------- | ---- |
| p_total_due | Tổng công nợ         | OUT  |
| p_message   | Thông báo trạng thái | OUT  |

2. Đề xuất 2 giải pháp xử lý logic
Giải pháp 1: Dùng IF...ELSE
Ý tưởng:
- Nếu có patient_id -> tìm theo ID
- Nếu không có ID nhưng có phone -> tìm theo phone
- Nếu cả 2 đều NULL -> báo lỗi

Ưu điểm:
+ Dễ đọc
+ Dễ debug
+ Phân luồng rõ ràng

Nhược điểm:
+ Code dài hơn
+ Nhiều nhánh xử lý

Giải pháp 2: Dùng WHERE linh hoạt
Ý tưởng:

Viết một câu SELECT duy nhất:

WHERE patient_id = p_patient_id OR phone = p_phone

kết hợp kiểm tra NULL.

Ưu điểm:
- Code ngắn
- Ít IF ELSE
Nhược điểm:
- Khó kiểm soát logic hơn
- Dễ trả sai dữ liệu nếu điều kiện OR không chặt chẽ

3. So sánh & Lựa chọn

| Tiêu chí         | IF...ELSE | WHERE linh hoạt |
| ---------------- | --------- | --------------- |
| Dễ đọc           | Tốt       | Trung bình      |
| Dễ bảo trì       | Tốt       | Trung bình      |
| Kiểm soát logic  | Tốt       | Khó hơn         |
| Độ rõ ràng       | Cao       | Trung bình      |
| Phù hợp bài toán | Tốt       | Khá             |

\Lựa chọn

Chọn giải pháp IF...ELSE vì:

logic rõ ràng
dễ kiểm soát lỗi
phù hợp yêu cầu nghiệp vụ thực tế

Phần B: Thiết kế & Triển khai
1. Thiết kế luồng xử lý
- Nhận patient_id và phone
- Kiểm tra:
	+ nếu cả 2 NULL -> báo lỗi
- Nếu có ID:
	+ tìm theo ID
- Ngược lại:
	+ tìm theo phone
- Nếu không tìm thấy:
	+ trả nợ = 0
	+ trả thông báo không tìm thấy
-Nếu tìm thấy:
	+ trả tổng nợ
	+ trả thông báo thành công
*/
-- 2. Triển khai Code
DELIMITER //

CREATE PROCEDURE GetPatientDebt(
    IN p_patient_id INT,
    IN p_phone VARCHAR(15),
    OUT p_total_due DECIMAL(18,2),
    OUT p_message VARCHAR(100)
)
BEGIN

    -- Trường hợp cả 2 đều NULL
    IF p_patient_id IS NULL AND p_phone IS NULL THEN

        SET p_total_due = 0;
        SET p_message = 'Lỗi: Vui lòng nhập ID hoặc số điện thoại';

    ELSE

        -- Tìm theo ID
        IF p_patient_id IS NOT NULL THEN

            SELECT pi.total_due
            INTO p_total_due
            FROM Patient_Invoices pi
            JOIN Patients p
                ON pi.patient_id = p.patient_id
            WHERE p.patient_id = p_patient_id;

        -- Tìm theo Phone
        ELSE

            SELECT pi.total_due
            INTO p_total_due
            FROM Patient_Invoices pi
            JOIN Patients p
                ON pi.patient_id = p.patient_id
            WHERE p.phone = p_phone;

        END IF;

        -- Không tìm thấy
        IF p_total_due IS NULL THEN

            SET p_total_due = 0;
            SET p_message = 'Không tìm thấy bệnh nhân';

        ELSE

            SET p_message = 'Tra cứu thành công';

        END IF;

    END IF;

END //

DELIMITER ;

-- 3. Nghiệm
-- thu Chỉ truyền ID
CALL GetPatientDebt(
    1,
    NULL,
    @total_due,
    @message
);

SELECT @total_due, @message;

-- Chỉ truyền Phone
CALL GetPatientDebt(
    NULL,
    '0912222333',
    @total_due,
    @message
);

SELECT @total_due, @message;

-- Truyền NULL cả 2
CALL GetPatientDebt(
    NULL,
    NULL,
    @total_due,
    @message
);

SELECT @total_due, @message;

-- Dữ liệu không tồn tại
CALL GetPatientDebt(
    999,
    NULL,
    @total_due,
    @message
);

SELECT @total_due, @message;