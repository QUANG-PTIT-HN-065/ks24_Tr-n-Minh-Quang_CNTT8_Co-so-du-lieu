USE rikkei_clinic_db;
-- 1. Kiểm tra Execution Plan trước khi tạo INDEX
EXPLAIN
SELECT patient_id, full_name, age, room_number
FROM patients
WHERE full_name = 'Tran Thi B';

-- Kết quả dự kiến:
-- type = ALL
-- rows = quét toàn bộ bảng patients
-- => MySQL thực hiện Full Table Scan, hiệu năng thấp khi dữ liệu lớn.


-- 2. Tạo INDEX trên cột full_name
CREATE INDEX idx_patient_name
ON patients(full_name);


-- 3. Kiểm tra Execution Plan sau khi tạo INDEX
EXPLAIN
SELECT patient_id, full_name, age, room_number
FROM patients
WHERE full_name = 'Tran Thi B';

-- Kết quả dự kiến:
-- key = idx_patient_name
-- type = ref
-- rows = 1 (hoặc rất ít)
-- => MySQL sử dụng INDEX để truy xuất trực tiếp,
--    không còn quét toàn bộ bảng, tốc độ tìm kiếm tăng đáng kể.