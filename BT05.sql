USE rikkei_clinic_db;
-- PHẦN A. THIẾT KẾ KIẾN TRÚC

-- 1. Số lượng View cần tạo: 2
--
-- a. doctor_medical_view
--    Mục đích: Bác sĩ chỉ xem thông tin chẩn đoán.
--    Cột:
--      - record_id
--      - patient_name
--      - diagnosis
--
-- b. cashier_medical_view
--    Mục đích: Thu ngân chỉ xem thông tin tài chính.
--    Cột:
--      - record_id
--      - patient_name
--      - total_cost
--      - paid_amount
--      - payment_status (cột ảo)
--
-- 2. Logic cột payment_status
--    CASE
--        WHEN paid_amount < total_cost THEN 'Con no'
--        ELSE 'Hoan tat'
--    END
--
-- 3. Chặn cập nhật số âm
--    Sử dụng:
--      WHERE paid_amount >= 0
--      WITH CHECK OPTION
--
--    => Nếu UPDATE paid_amount < 0 qua View,
--       MySQL sẽ tự động từ chối.

-- PHẦN B. TRIỂN KHAI CODE

-- 1. View dành cho Bác sĩ
CREATE VIEW doctor_medical_view AS
SELECT
    record_id,
    patient_name,
    diagnosis
FROM medical_records;

-- 2. View dành cho Thu ngân
CREATE VIEW cashier_medical_view AS
SELECT
    record_id,
    patient_name,
    total_cost,
    paid_amount,
    CASE
        WHEN paid_amount < total_cost THEN 'Con no'
        ELSE 'Hoan tat'
    END AS payment_status
FROM medical_records
WHERE paid_amount >= 0
WITH CHECK OPTION;

-- KIỂM THỬ PHÂN QUYỀN


-- Bác sĩ chỉ thấy chẩn đoán, không thấy dữ liệu tài chính
SELECT *
FROM doctor_medical_view;

-- Thu ngân chỉ thấy dữ liệu tài chính, không thấy diagnosis
SELECT *
FROM cashier_medical_view;



-- KIỂM THỬ CẬP NHẬT HỢP LỆ

UPDATE cashier_medical_view
SET paid_amount = 1000000
WHERE record_id = 1;

-- KIỂM THỬ BẪY DỮ LIỆU


UPDATE cashier_medical_view
SET paid_amount = -500000
WHERE record_id = 1;

-- Kết quả mong đợi:
-- ERROR 1369 (HY000):
-- CHECK OPTION failed 'rikkei_clinic_db.cashier_medical_view'