USE RikkeiClinicDB;
/*
1. Xác định dữ liệu đầu vào và đầu ra 

Dữ liệu đầu vào
| Tham số        | Ý nghĩa               | Kiểu dữ liệu  |
| -------------- | --------------------- | ------------- |
| p_total_cost   | Tổng chi phí điều trị | DECIMAL(18,2) |
| p_patient_type | Diện bệnh nhân        | VARCHAR(20)   |

Dữ liệu đầu ra
| Tham số        | Ý nghĩa                    | Kiểu dữ liệu  |
| -------------- | -------------------------- | ------------- |
| p_final_amount | Số tiền cuối cùng phải thu | DECIMAL(18,2) |
| p_message      | Thông báo trạng thái       | VARCHAR(100)  |

Loại tham số phù hợp
IN -> dùng để nhận dữ liệu đầu vào
OUT -> dùng để trả kết quả tính toán ra ngoài

2. Giải pháp và các bước thực hiện
Giải pháp

Tạo Stored Procedure để:

Nhận tổng chi phí và diện bệnh nhân
Kiểm tra dữ liệu hợp lệ
Tự động tính số tiền phải thu
Trả về thông báo trạng thái
Các bước thực hiện
Bước 1

Kiểm tra tổng chi phí có hợp lệ không:

Nếu < 0
trả về 0
trả về thông báo lỗi
Bước 2

Nếu dữ liệu hợp lệ:

BHYT -> thu 20%
VIP -> giảm 10%
THUONG -> thu 100%
Bước 3

Trả về: số tiền cuối cùng .thông báo "Đã tính toán xong"
*/

-- 3. Triển khai mã nguồn
DELIMITER //

CREATE PROCEDURE CalculateDischargeCost(
    IN p_total_cost DECIMAL(18,2),
    IN p_patient_type VARCHAR(20),
    OUT p_final_amount DECIMAL(18,2),
    OUT p_message VARCHAR(100)
)
BEGIN

    -- Kiểm tra dữ liệu không hợp lệ
    IF p_total_cost < 0 THEN

        SET p_final_amount = 0;
        SET p_message = 'Lỗi: Chi phí không hợp lệ';

    ELSE

        -- BHYT hỗ trợ 80%
        IF p_patient_type = 'BHYT' THEN

            SET p_final_amount = p_total_cost * 0.2;

        -- VIP giảm 10%
        ELSEIF p_patient_type = 'VIP' THEN

            SET p_final_amount = p_total_cost * 0.9;

        -- THUONG đóng 100%
        ELSE

            SET p_final_amount = p_total_cost;

        END IF;

        SET p_message = 'Đã tính toán xong';

    END IF;

END //

DELIMITER ;

-- 4. Kiểm thử
-- Trường hợp BHYT
CALL CalculateDischargeCost(
    1000000,
    'BHYT',
    @final_amount,
    @message
);

SELECT @final_amount, @message;

-- Trường hợp VIP
CALL CalculateDischargeCost(
    1000000,
    'VIP',
    @final_amount,
    @message
);

SELECT @final_amount, @message;

-- Trường hợp THUONG
CALL CalculateDischargeCost(
    1000000,
    'THUONG',
    @final_amount,
    @message
);

SELECT @final_amount, @message;

-- Trường hợp dữ liệu lỗi (chi phí âm)
CALL CalculateDischargeCost(
    -500000,
    'VIP',
    @final_amount,
    @message
);

SELECT @final_amount, @message;

