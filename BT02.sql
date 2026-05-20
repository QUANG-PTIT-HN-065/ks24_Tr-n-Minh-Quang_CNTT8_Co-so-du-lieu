USE RikkeiClinicDB;

DELIMITER //

CREATE TRIGGER PreventStatusRevert
BEFORE UPDATE ON Appointments
FOR EACH ROW
BEGIN
    -- Nếu lịch khám đã ở trạng thái Completed thì không cho phép cập nhật nữa
    IF NEW.status = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Không được phép thao tác trên lịch khám này!';
    END IF;
END //
DELIMITER ;
/*
Phần A: Phân tích lỗi
1. Câu lệnh UPDATE để tái hiện lỗi

*/
UPDATE Appointments
SET status = 'Completed'
WHERE appointment_id = 104;
/*
2. Giải thích lỗi logic

Phải sử dụng OLD.status vì đây là trạng thái của lịch khám trước khi thực hiện UPDATE.
Mục tiêu của hệ thống là kiểm tra xem lịch khám đã được hoàn thành (Completed) từ trước hay chưa.
Nếu đã Completed thì không cho phép chỉnh sửa nữa.
dùng NEW.status. Điều này khiến hệ thống hiểu sai rằng chỉ cần cập nhật thành 'Completed' là bị chặn, 
 kể cả trường hợp hợp lệ như chuyển từ 'Pending' sang 'Completed'
*/

DROP TRIGGER IF EXISTS PreventStatusRevert;

DELIMITER //
CREATE TRIGGER PreventStatusRevert
BEFORE UPDATE ON Appointments
FOR EACH ROW
BEGIN
    IF OLD.status = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Loi: Khong duoc phep thao tac tren lich kham da Completed';

    END IF;

END //

DELIMITER ;