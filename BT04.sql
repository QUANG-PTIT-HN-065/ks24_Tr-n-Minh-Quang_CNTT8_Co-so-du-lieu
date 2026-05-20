USE RikkeiClinicDB;

/*
1. Phân tích

Cần 2 trigger:
BEFORE INSERT và BEFORE UPDATE trên bảng Appointments

Thời điểm kích hoạt: Sử dụng BEFORE để kiểm tra trước khi dữ liệu được ghi vào bảng. Nếu phát hiện trùng lịch thì dùng SIGNAL để chặn giao dịch.

2. Điều kiện kiểm tra trùng lịch

Một lịch bị xem là trùng khi:
+ Cùng doctor_id
+ Cùng appointment_date
+ status <> 'Cancelled'

Trigger INSERT:
WHERE doctor_id = NEW.doctor_id
  AND appointment_date = NEW.appointment_date
  AND status <> 'Cancelled'
  
Trigger UPDATE
WHERE doctor_id = NEW.doctor_id
  AND appointment_date = NEW.appointment_date
  AND status <> 'Cancelled'
  AND appointment_id <> OLD.appointment_id
*/
DELIMITER //

CREATE TRIGGER trg_check_doctor_schedule_insert
BEFORE INSERT ON Appointments
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Appointments
        WHERE doctor_id = NEW.doctor_id
          AND appointment_date = NEW.appointment_date
          AND status <> 'Cancelled'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Bác sĩ đã có lịch hẹn vào khung giờ này';
    END IF;
END //

CREATE TRIGGER trg_check_doctor_schedule_update
BEFORE UPDATE ON Appointments
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Appointments
        WHERE doctor_id = NEW.doctor_id
          AND appointment_date = NEW.appointment_date
          AND status <> 'Cancelled'
          AND appointment_id <> OLD.appointment_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Bác sĩ đã có lịch hẹn vào khung giờ này';
    END IF;
END //

DELIMITER ;

-- kiểm thử 
-- Lịch mới đưa vào khung giờ hoàn toàn trống →  Thành công.
INSERT INTO Appointments (appointment_id,patient_id,doctor_id,appointment_date,status) VALUES 
(107,1,101,'2026-06-11 08:00:00','Pending');

-- Lịch mới đưa vào khung giờ đang có ca 'Pending' →  Bị chặn & Báo lỗi.
INSERT INTO Appointments (appointment_id,patient_id,doctor_id,appointment_date,status) VALUES 
(108,2,101,'2026-06-10 08:30:00','Pending');

-- Lịch mới đưa vào khung giờ đang có ca 'Cancelled' →  Thành công.
INSERT INTO Appointments (appointment_id,patient_id,doctor_id,appointment_date,status) VALUES 
(109,2,101,'2026-05-02 10:00:00','Pending');

-- Cập nhật trạng thái một ca khám từ 'Pending' sang 'Completed' →  Thành công
UPDATE Appointments
SET status = 'Completed'
WHERE appointment_id = 104;