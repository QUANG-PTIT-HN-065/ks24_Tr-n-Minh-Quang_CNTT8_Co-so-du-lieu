USE rikkei_clinic_db;
-- PHẦN A. PHÂN TÍCH & ĐỀ XUẤT GIẢI PHÁP

-- 1. Giải pháp 1: Tạo 2 Single Index
-- CREATE INDEX idx_drug_name ON pharmacy_inventory(drug_name);
-- CREATE INDEX idx_expiry_date ON pharmacy_inventory(expiry_date);

-- 2. Giải pháp 2: Tạo 1 Composite Index
-- CREATE INDEX idx_drug_expiry
-- ON pharmacy_inventory(drug_name, expiry_date);

-- 3. So sánh hai giải pháp
--
-- +----------------------+----------------------+----------------------+
-- | Tiêu chí             | 2 Single Index       | Composite Index      |
-- +----------------------+----------------------+----------------------+
-- | SELECT kết hợp       | Khá tốt (Index Merge)| Tốt nhất             |
-- | SELECT theo drug_name| Tốt                  | Tốt                  |
-- | SELECT theo expiry   | Tốt                  | Không tối ưu bằng    |
-- | INSERT/UPDATE        | Chậm hơn (2 index)   | Nhanh hơn (1 index)  |
-- | Dung lượng lưu trữ   | Lớn hơn              | Nhỏ hơn              |
-- +----------------------+----------------------+----------------------+
--
-- 4. Kết luận:
-- Chọn Composite Index (drug_name, expiry_date)
-- vì truy vấn nghiệp vụ luôn lọc theo drug_name trước,
-- sau đó lọc tiếp theo expiry_date.


-- PHẦN B. TRIỂN KHAI CODE

-- Tạo Composite Index
CREATE INDEX idx_drug_expiry
ON pharmacy_inventory(drug_name, expiry_date);


-- NGHIỆM THU KỊCH BẢN 1

EXPLAIN
SELECT *
FROM pharmacy_inventory
WHERE drug_name = 'Paracetamol'
  AND expiry_date <= '2026-12-31';

-- Kết quả mong đợi:
-- key = idx_drug_expiry
-- type = range
-- rows = rất ít
-- => MySQL sử dụng Composite Index, không còn Full Table Scan.



-- NGHIỆM THU KỊCH BẢN 2

-- Cách viết LIKE tận dụng được Index
EXPLAIN
SELECT *
FROM pharmacy_inventory
WHERE drug_name LIKE 'Paracetamol%';

-- Kết quả mong đợi:
-- key = idx_drug_expiry
-- type = range
-- => Index vẫn được sử dụng.


-- Giải thích:
-- LIKE '%Paracetamol%' có ký tự wildcard (%) ở đầu chuỗi.
-- MySQL không xác định được điểm bắt đầu trong B-Tree Index,
-- nên buộc phải quét toàn bộ bảng (type = ALL).

