USE rikkei_clinic_db;

-- PHẦN A. PHÂN TÍCH & THIẾT KẾ

-- 1. Input (Dữ liệu đầu vào)
-- Bảng departments:
--   + department_id
--   + department_name
--
-- Bảng patients:
--   + patient_id
--   + department_id
--
-- Bảng invoices:
--   + patient_id
--   + amount

-- 2. Giải pháp triển khai
-- - Sử dụng LEFT JOIN để liên kết:
--     departments -> patients -> invoices
-- - Sử dụng COUNT(DISTINCT p.patient_id) để đếm số bệnh nhân theo khoa.
-- - Sử dụng SUM(i.amount) để tính tổng doanh thu.
-- - Sử dụng COALESCE(..., 0) để xử lý trường hợp khoa chưa có dữ liệu.
-- - Sử dụng GROUP BY theo department_id và department_name.
-- - View có chứa hàm tổng hợp nên mặc định chỉ đọc (không thể UPDATE).


-- PHẦN B. TRIỂN KHAI CODE


-- Tạo View tổng hợp báo cáo tài chính theo khoa
CREATE VIEW department_revenue_view AS
SELECT
    d.department_id,
    d.department_name,
    COUNT(DISTINCT p.patient_id) AS total_patients,
    COALESCE(SUM(i.amount), 0) AS total_revenue
FROM departments d
LEFT JOIN patients p
    ON d.department_id = p.department_id
LEFT JOIN invoices i
    ON p.patient_id = i.patient_id
GROUP BY
    d.department_id,
    d.department_name;



-- KIỂM THỬ LUỒNG CHUẨN

-- Truy vấn báo cáo tài chính
SELECT *
FROM department_revenue_view;

-- Kết quả mong đợi:
-- department_id | department_name | total_patients | total_revenue
-- 1             | Khoa Noi        | 2              | 800000.00
-- 2             | Khoa Ngoai      | 1              | 1000000.00


/* =========================================================
KIỂM THỬ BẪY DỮ LIỆU
========================================================= */

-- Cố tình sửa tổng doanh thu qua View
UPDATE department_revenue_view
SET total_revenue = 999999999
WHERE department_id = 1;

-- Kết quả mong đợi:
-- ERROR 1288 (HY000):
-- The target table department_revenue_view of the UPDATE
-- is not updatable
