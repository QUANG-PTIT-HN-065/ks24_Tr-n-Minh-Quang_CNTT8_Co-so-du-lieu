use Session05;

/*
1. Input & Output
Input dùng để lọc
status
trust_score
distance_km
Output

Danh sách tài xế hợp lệ:

driver_id
full_name
trust_score
distance_km
2. Logic xử lý
WHERE

Lọc tài xế:

status = 'AVAILABLE'
trust_score >= min_trust_score

Các điều kiện nối bằng AND -> phải đúng hết.

ORDER BY
ORDER BY distance_km ASC,
         trust_score DESC

Ý nghĩa:

Gần quán hơn lên trước
Nếu cùng khoảng cách -> ai trust_score cao hơn đứng trước
3. Bẫy dữ liệu

Nếu Admin nhập:

min_trust_score = -10

-> Điều kiện trust_score >= -10 sẽ cho gần như mọi tài xế qua.

Chốt chặn an toàn

Dùng:

GREATEST(80, 80)

-> Không cho điểm tối thiểu nhỏ hơn 80.

*/
CREATE TABLE Drivers (
    driver_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL,
    trust_score INT NOT NULL,
    distance_km DECIMAL(5,2) NOT NULL
); 

INSERT INTO Drivers(full_name, status, trust_score, distance_km)
VALUES
('Nguyen Van A', 'AVAILABLE', 90, 1.5),
('Tran Van B', 'AVAILABLE', 95, 1.5),
('Le Van C', 'AVAILABLE', 88, 1.2),
('Pham Van D', 'BLOCKED', 99, 0.8);

SELECT 
    driver_id,
    full_name,
    trust_score,
    distance_km
FROM Drivers
WHERE status = 'AVAILABLE'
AND trust_score >= GREATEST(80, 80)
ORDER BY distance_km ASC,
         trust_score DESC;