USE RikkeiClinicDB;

/*
PHẦN A: PHÂN TÍCH & ĐỀ XUẤT
1. Định nghĩa Input / Output
Input
Procedure cần nhận:

patientId -> mã bệnh nhân
soTien -> số tiền thanh toán

=> dùng tham số IN

Output

Procedure cần trả:
Thông báo trạng thái thành công / thất bại

=> dùng tham số OUT

2. Đề xuất 2 chiến lược xử lý
Chiến lược 1: Chạy cập nhật trực tiếp + bắt lỗi hệ thống

Cách làm:
+ Chạy luôn lệnh UPDATE ví
+ Chạy UPDATE công nợ
+ Nếu lỗi hệ thống xảy ra thì dùng:
+ ROLLBACK

- Ưu điểm
+ Code ngắn
+ Dễ viết

- Nhược điểm
+ Không kiểm tra dữ liệu trước
+ Có thể bị:
	+ âm ví
	+ thanh toán số âm
	+ dữ liệu sai logic
    
Chiến lược 2: Kiểm tra dữ liệu trước rồi mới cho giao dịch chạy
Cách làm:
+ Kiểm tra:
	+ số tiền > 0
    + ví có đủ tiền không
+ Nếu sai:
	+ rollback
	+ trả thông báo lỗi
+ Nếu hợp lệ:
	+ mới update dữ liệu
    + commit
    
- Ưu điểm
	+ An toàn dữ liệu
	+ Không âm ví
	+ Chặn lỗi nghiệp vụ từ đầu
	+ Đúng quy tắc hệ thống thực tế
- Nhược điểm
	+ Code dài hơn
	+ Nhiều bước hơn
    
    
3. Bảng so sánh 
| Tiêu chí                 | Chiến lược 1 | Chiến lược 2 |
| ------------------------ | ------------ | ------------ |
| Code ngắn                | Có           | Không        |
| Kiểm tra số dư           | Không        | Có           |
| Chặn thanh toán âm       | Không        | Có           |
| Độ an toàn dữ liệu       | Trung bình   | Cao          |
| Phù hợp hệ thống thực tế | Không        | Có           |

4. Lựa chọn giải pháp

Chọn Chiến lược 2 Vì:
- kiểm soát dữ liệu tốt hơn
- tránh âm ví
- tránh thanh toán sai
- đảm bảo tính toàn vẹn dữ liệu

PHẦN B: THIẾT KẾ & TRIỂN KHAI
1. Thiết kế luồng xử lý
- Bước 1:
	+ Bắt đầu transaction: START TRANSACTION;
- Bước 2: 
    + Lấy số dư ví hiện tại
- Bước 3:
	+ Kiểm tra: số tiền có > 0 không => ví có đủ tiền không
	+ Nếu sai: ROLLBACK và trả thông báo lỗi.
- Bước 4:
	+ Nếu hợp lệ: trừ tiền ví ,giảm công nợ
- Bước 5
    + Hoàn tất giao dịch COMMIT
*/

DELIMITER //

CREATE PROCEDURE PayFee(
    IN patientId INT,
    IN soTien DECIMAL(18,2),
    OUT message VARCHAR(255)
)
BEGIN

    DECLARE soDu DECIMAL(18,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET message = 'Lỗi hệ thống';
    END;

    START TRANSACTION;

    SELECT balance
    INTO soDu
    FROM Wallets
    WHERE patient_id = patientId;

    IF soTien <= 0 THEN

        ROLLBACK;
        SET message = 'Số tiền không hợp lệ';

    ELSEIF soDu < soTien THEN

        ROLLBACK;
        SET message = 'Ví không đủ tiền';

    ELSE

        UPDATE Wallets
        SET balance = balance - soTien
        WHERE patient_id = patientId;

        UPDATE Patient_Invoices
        SET total_due = total_due - soTien
        WHERE patient_id = patientId;

        COMMIT;

        SET message = 'Thanh toán thành công';

    END IF;

END //

DELIMITER ;

-- Kiểm thử
-- TH1: Thanh toán hợp lệ
CALL PayFee(1, 100000, @msg);
SELECT @msg;

-- TH2: Ví không đủ tiền

CALL PayFee(2, 200000, @msg);
SELECT @msg;

-- TH3: Truyền số âm
CALL PayFee(1, -50000, @msg);
SELECT @msg;