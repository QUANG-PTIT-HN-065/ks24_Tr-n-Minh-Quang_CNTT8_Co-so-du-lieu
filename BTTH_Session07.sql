create database Session07;
use Session07;

-- Khóa học
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    duration VARCHAR(50),
    statuss ENUM('Hoạt động', 'Không hoạt động') DEFAULT 'Hoạt động'
);
-- Môn học
CREATE TABLE subjects (
    subject_id CHAR(4) PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL,
    credits INT NOT NULL,
    statuss ENUM('Hoạt động', 'Không hoạt động') DEFAULT 'Hoạt động',
    course_id INT NULL,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
-- Sinh viên
CREATE TABLE students (
    student_id CHAR(5) PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    birth_year INT,
    gender ENUM('Nam', 'Nữ', 'Khác'),
    phone VARCHAR(15),
    address VARCHAR(255),
    statuss ENUM('Đang học', 'Bảo lưu', 'Đình chỉ', 'Tốt nghiệp')
);

-- CCCD
CREATE TABLE citizen_cards (
    card_id INT AUTO_INCREMENT PRIMARY KEY,
    citizen_number VARCHAR(12) UNIQUE NOT NULL,
    issue_date DATE,
    issue_place VARCHAR(100),
    student_id CHAR(5) UNIQUE,
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);

-- Đăng ký học
CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_id CHAR(4),
    student_id CHAR(5),
    score DECIMAL(4,2),
    register_date DATE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);

-- Courses
INSERT INTO courses(course_name, duration, statuss) VALUES
('Công nghệ thông tin K18', '4 năm', 'Hoạt động'),
('Khoa học dữ liệu', '4 năm', 'Hoạt động'),
('Thiết kế đồ họa', '3 năm', 'Không hoạt động'),
('Quản trị kinh doanh', '4 năm', 'Hoạt động'),
('Ngôn ngữ Anh', '4 năm', 'Hoạt động');

-- Subjects
INSERT INTO subjects(subject_id, subject_name, credits, statuss, course_id) VALUES
('MH01', 'Giải tích', 4, 'Hoạt động', 1),
('MH02', 'Lập trình C', 3, 'Hoạt động', 1),
('MH03', 'Cơ sở dữ liệu', 3, 'Không hoạt động', 1),
('MH04', 'Xác suất thống kê', 3, 'Hoạt động', 2),
('MH05', 'Photoshop', 2, 'Không hoạt động', NULL);

-- Students
INSERT INTO students(student_id, student_name, birth_year, gender, phone, address, statuss) VALUES
('SV001', 'Nguyễn Văn An', 2003, 'Nam', '0901111111', 'Hà Nội', 'Đang học'),
('SV002', 'Trần Thị Bình', 2002, 'Nữ', '0902222222', 'Hải Phòng', 'Đang học'),
('SV003', 'Lê Văn Cường', 2001, 'Nam', '0903333333', 'Đà Nẵng', 'Bảo lưu'),
('SV004', 'Phạm Thị Dung', 2003, 'Nữ', '0904444444', 'Huế', 'Đang học'),
('SV005', 'Hoàng Minh Đức', 2000, 'Nam', '0905555555', 'TP.HCM', 'Tốt nghiệp');

-- Citizen Cards
INSERT INTO citizen_cards(citizen_number, issue_date, issue_place, student_id) VALUES
('001203000001', '2021-01-10', 'Hà Nội', 'SV001'),
('001203000002', '2021-02-15', 'Hải Phòng', 'SV002'),
('001203000003', '2020-03-20', 'Đà Nẵng', 'SV003'),
('001203000004', '2021-04-05', 'Huế', 'SV004'),
('001203000005', '2019-05-18', 'TP.HCM', 'SV005');

-- Enrollments
INSERT INTO enrollments(subject_id, student_id, score, register_date) VALUES
('MH01', 'SV001', 8.5, '2025-01-10'),
('MH02', 'SV001', 7.0, '2025-01-12'),
('MH01', 'SV002', 9.0, '2025-01-11'),
('MH04', 'SV003', 6.5, '2025-01-15'),
('MH02', 'SV004', 8.0, '2025-01-20');

-- cập nhật môn học có mã là MH01 thành tên ‘Toán cao cấp’ và có số tín chỉ là 3 
UPDATE subjects 
SET 
    subject_name = 'Toán cao cấp',
    credits = 3
WHERE
    subject_id = 'MH01';

/* xoá môn học có status không hoạt động*/
DELETE FROM subjects 
WHERE
    statuss = 'Không hoạt động';

-- Lấy mã sinh viên, tên sinh viên, số điện thoại, địa chỉ
SELECT 
    student_id, student_name, phone, address
FROM
    students;

-- Lấy các môn học chưa thuộc khóa học
SELECT 
    subject_id, subject_name, credits
FROM
    subjects
WHERE
    course_id IS NULL;

-- Lấy các mã khóa học đã có môn học
SELECT DISTINCT
    course_id
FROM
    subjects
WHERE
    course_id IS NOT NULL;


-- Thông tin đăng ký:
-- mã sinh viên, tên sinh viên, ngày đăng ký,
-- tên môn học, điểm môn học, số CCCD
-- sắp xếp theo năm sinh giảm dần
SELECT 
    s.student_id,
    s.student_name,
    e.register_date,
    sub.subject_name,
    e.score,
    cc.citizen_number
FROM
    enrollments e
        JOIN
    students s ON e.student_id = s.student_id
        JOIN
    subjects sub ON e.subject_id = sub.subject_id
        LEFT JOIN
    citizen_cards cc ON s.student_id = cc.student_id
ORDER BY s.birth_year DESC;


-- Tính tổng số lần đăng ký của từng môn học
SELECT 
    sub.subject_id,
    sub.subject_name,
    COUNT(e.enrollment_id) AS total_registrations
FROM
    subjects sub
        LEFT JOIN
    enrollments e ON sub.subject_id = e.subject_id
GROUP BY sub.subject_id , sub.subject_name;

--  Thống kê số môn học của từng khóa học
SELECT c.course_id,
       c.course_name,
       COUNT(s.subject_id) AS total_subjects
FROM courses c
LEFT JOIN subjects s
       ON c.course_id = s.course_id
GROUP BY c.course_id, c.course_name;

-- Tính điểm trung bình của từng sinh viên
SELECT s.student_id,
       s.student_name,
       AVG(e.score) AS avg_score
FROM students s
LEFT JOIN enrollments e
       ON s.student_id = e.student_id
GROUP BY s.student_id, s.student_name;

-- Các môn học có điểm trung bình > 5
SELECT 
    sub.subject_id, sub.subject_name, c.course_name
FROM
    subjects sub
        LEFT JOIN
    courses c ON sub.course_id = c.course_id
        JOIN
    enrollments e ON sub.subject_id = e.subject_id
GROUP BY sub.subject_id , sub.subject_name , c.course_name
HAVING AVG(e.score) > 5;


-- Các đăng ký có điểm cao nhất
SELECT 
    s.student_id, s.student_name, sub.subject_name, e.score
FROM
    enrollments e
        JOIN
    students s ON e.student_id = s.student_id
        JOIN
    subjects sub ON e.subject_id = sub.subject_id
WHERE
    e.score = (SELECT 
            MAX(score)
        FROM
            enrollments);


-- Sinh viên đã đăng ký môn học có điểm trung bình lớn nhất
SELECT 
    s.student_id,
    s.student_name,
    YEAR(CURDATE()) - s.birth_year AS age,
    sub.subject_name,
    c.course_name
FROM
    students s
        JOIN
    enrollments e ON s.student_id = e.student_id
        JOIN
    subjects sub ON e.subject_id = sub.subject_id
        LEFT JOIN
    courses c ON sub.course_id = c.course_id
WHERE
    e.subject_id = (SELECT 
            e2.subject_id
        FROM
            enrollments e2
        GROUP BY e2.subject_id
        ORDER BY AVG(e2.score) DESC
        LIMIT 1);