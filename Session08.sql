create database Session08;
use Session08;


/* 1. Bệnh nhân */
CREATE TABLE patients (
    patient_id VARCHAR(10) PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    patient_dob DATE NOT NULL,
    patient_phone VARCHAR(15) NOT NULL UNIQUE,
    patient_address VARCHAR(200) NOT NULL
);

/* 2. Bác sĩ */
CREATE TABLE doctors (
    doctor_id VARCHAR(10) PRIMARY KEY,
    doctor_name VARCHAR(100) NOT NULL,
    doctor_specialty VARCHAR(100) NOT NULL,
    doctor_experience INT NOT NULL CHECK (doctor_experience >= 0),
    doctor_status BIT DEFAULT 1
);

/* 3. Phiếu khám */
CREATE TABLE appointments (
    app_id VARCHAR(10) PRIMARY KEY,
    patient_id VARCHAR(10) NOT NULL,
    doctor_id VARCHAR(10) NOT NULL,
    app_date DATE NOT NULL,
    app_cost DECIMAL(15,2) NOT NULL CHECK (app_cost >= 0),
    app_status ENUM('Pending', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Pending',

    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

/* 4. Đơn thuốc (mỗi phiếu khám chỉ có 1 đơn thuốc) */
CREATE TABLE prescriptions (
    pres_id INT AUTO_INCREMENT PRIMARY KEY,
    app_id VARCHAR(10) NOT NULL UNIQUE,
    pres_medicine_details TEXT,
    pres_total_meds_cost DECIMAL(15,2) NOT NULL CHECK (pres_total_meds_cost >= 0),

    FOREIGN KEY (app_id) REFERENCES appointments(app_id)
);

INSERT INTO patients VALUES
('BN001', 'Nguyễn Thị Hà', '2000-05-15', '0901111222', 'Hà Nội'),
('BN002', 'Trần Thu Bình', '1998-08-20', '0912222333', 'Hải Phòng'),
('BN003', 'Lê Văn Chiến', '1999-07-26', '0983333444', 'Hà Nội'),
('BN004', 'Nguyễn Xuân Bách', '1998-03-31', '0964444555', 'Đà Nẵng'),
('BN005', 'Trần Minh Cường', '1995-02-19', '0975555666', 'Hà Nội');

/* Doctors */
INSERT INTO doctors VALUES
('BS001', 'Nguyễn Lân Việt', 'Tim mạch', 18, 1),
('BS002', 'Trần Ngọc Lương', 'Ngoại khoa', 15, 1),
('BS003', 'Nguyễn Chấn Hùng', 'Ung Bướu', 16, 0),
('BS004', 'Nguyễn Văn Liệu', 'Thần Kinh', 13, 1),
('BS005', 'Nguyễn Viết Tiến', 'Phụ khoa', 12, 1);

/* Appointments */
INSERT INTO appointments VALUES
('PK001', 'BN001', 'BS001', '2026-05-13', 500000, 'Completed'),
('PK002', 'BN002', 'BS002', '2026-04-16', 300000, 'Completed'),
('PK003', 'BN001', 'BS003', '2026-03-29', 700000, 'Completed'),
('PK004', 'BN003', 'BS001', '2026-05-13', 400000, 'Pending'),
('PK005', 'BN004', 'BS004', '2026-04-12', 200000, 'Cancelled'),
('PK006', 'BN002', 'BS002', '2026-05-08', 300000, 'Completed');

/* Prescriptions */
INSERT INTO prescriptions (app_id, pres_medicine_details, pres_total_meds_cost)
VALUES
('PK001', 'Aspirin, Beta-blocker', 1500000),
('PK002', 'Vitamin C, Paracetamol', 130000),
('PK003', 'Neurobion, Ginkgo Biloba', 3500000);

/*  Tăng 50,000 cho bác sĩ chuyên khoa Tim mạch */
UPDATE appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
SET a.app_cost = a.app_cost + 50000
WHERE d.doctor_specialty = 'Tim mạch';

DELETE FROM appointments
WHERE doctor_id = 'BS001';

DELETE FROM doctors
WHERE doctor_name = 'Nguyễn Lân Việt';

/* Phiếu khám Completed mới nhất */
SELECT
    app_id,
    doctor_id,
    app_date,
    app_cost
FROM appointments
WHERE app_status = 'Completed'
ORDER BY app_date DESC;

/* Bệnh nhân ở Hà Nội, số điện thoại bắt đầu 090 */
SELECT
    patient_id,
    patient_phone,
    patient_name
FROM patients
WHERE patient_address = 'Hà Nội'
  AND patient_phone LIKE '090%';

/* Hiển thị 3 người tiếp theo sau khi đã gọi 2 người đầu */
SELECT
    patient_id,
    patient_name,
    patient_dob
FROM patients
ORDER BY patient_id
LIMIT 3 OFFSET 2;

/* Hóa đơn thanh toán viện phí */
SELECT
    p.patient_id,
    p.patient_name,
    d.doctor_name,
    a.app_cost + COALESCE(pr.pres_total_meds_cost, 0) AS total_amount
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
LEFT JOIN prescriptions pr ON a.app_id = pr.app_id;

/*  KPI bác sĩ có từ 2 lượt khám trở lên */
SELECT
    d.doctor_id,
    d.doctor_name,
    COUNT(a.app_id) AS total_visits,
    SUM(a.app_cost + COALESCE(pr.pres_total_meds_cost, 0)) AS total_revenue
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
LEFT JOIN prescriptions pr ON a.app_id = pr.app_id
GROUP BY d.doctor_id, d.doctor_name
HAVING COUNT(a.app_id) >= 2;

/*  Phiếu Completed nhưng không có đơn thuốc */
SELECT
    a.app_id,
    a.patient_id,
    a.app_date
FROM appointments a
LEFT JOIN prescriptions pr ON a.app_id = pr.app_id
WHERE a.app_status = 'Completed'
  AND pr.app_id IS NULL;

/* Bác sĩ có kinh nghiệm > trung bình */
SELECT
    doctor_id,
    doctor_name,
    doctor_experience
FROM doctors
WHERE doctor_experience >
(
    SELECT AVG(doctor_experience)
    FROM doctors
);

/*  Bệnh nhân có phiếu khám nhưng chưa khám */
SELECT DISTINCT
    p.patient_id,
    p.patient_name,
    p.patient_phone
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
WHERE a.app_status = 'Pending';

/* Phiếu khám có chi phí cao nhất */
SELECT
    p.patient_name,
    d.doctor_name,
    a.app_date,
    a.app_cost
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE a.app_cost =
(
    SELECT MAX(app_cost)
    FROM appointments
);

/* Bệnh nhân VIP (từng chi trả tổng tiền cao nhất) */
SELECT
    p.patient_id,
    p.patient_name,
    p.patient_phone,
    p.patient_address
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
LEFT JOIN prescriptions pr ON a.app_id = pr.app_id
WHERE a.app_cost + COALESCE(pr.pres_total_meds_cost, 0) =
(
    SELECT MAX(total_amount)
    FROM
    (
        SELECT
            a.app_cost + COALESCE(pr.pres_total_meds_cost, 0) AS total_amount
        FROM appointments a
        LEFT JOIN prescriptions pr ON a.app_id = pr.app_id
    ) AS temp
);