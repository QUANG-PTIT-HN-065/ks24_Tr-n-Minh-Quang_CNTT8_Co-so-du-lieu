CREATE DATABASE IF NOT EXISTS student_management;
USE student_management;

-- Xóa các bảng cũ nếu đã tồn tại để làm sạch dữ liệu trước khi chấm/làm bài
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS enrollment;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS department;
SET FOREIGN_KEY_CHECKS = 1;



-- Bảng department (Thông tin khoa)
CREATE TABLE department (
    dept_id VARCHAR(5) PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL
);

-- Bảng student (Thông tin sinh viên)
CREATE TABLE student (
    student_id VARCHAR(6) PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    gender VARCHAR(10),
    birth_date DATE,
    dept_id VARCHAR(5),
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- Bảng course (Thông tin môn học)
CREATE TABLE course (
    course_id VARCHAR(6) PRIMARY KEY,
    course_name VARCHAR(50) NOT NULL,
    credits INT
);

-- Bảng enrollment (Sinh viên đăng ký môn học)
CREATE TABLE enrollment (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(6),
    course_id VARCHAR(6),
    score DECIMAL(4,2),
    FOREIGN KEY (student_id) REFERENCES student(student_id),
    FOREIGN KEY (course_id) REFERENCES course(course_id),
    CONSTRAINT unique_student_course UNIQUE (student_id, course_id)
);



-- Chèn dữ liệu vào bảng department
INSERT INTO department (dept_id, dept_name) VALUES
('IT', 'Information Technology'),
('ME', 'Mechanical Engineering'),
('BA', 'Business Administration');

-- Chèn dữ liệu vào bảng student
INSERT INTO student (student_id, full_name, gender, birth_date, dept_id) VALUES
('SV0001', 'Nguyen Van An', 'Male', '2004-05-15', 'IT'),
('SV0002', 'Tran Thi Binh', 'Female', '2004-09-20', 'IT'),
('SV0003', 'Le Hoang Cao', 'Male', '2003-11-02', 'ME'),
('SV0004', 'Pham Minh Dang', 'Male', '2004-02-28', 'IT'),
('SV0005', 'Vu Hoang Yen', 'Female', '2004-07-12', 'BA');

-- Chèn dữ liệu vào bảng course
INSERT INTO course (course_id, course_name, credits) VALUES
('C00001', 'Database Systems', 3),
('C00002', 'Java Programming', 4),
('C00003', 'Marketing Basics', 2);

-- Chèn dữ liệu vào bảng enrollment
INSERT INTO enrollment (student_id, course_id, score) VALUES
('SV0001', 'C00001', 8.50),  -- Sinh viên khoa IT
('SV0002', 'C00001', 9.50),  -- Sinh viên khoa IT (Thiết lập đồng điểm cao nhất môn C00001)
('SV0003', 'C00001', 9.50),  -- Sinh viên khoa ME (Thiết lập đồng điểm cao nhất môn C00001)
('SV0004', 'C00001', 7.00),  -- Sinh viên khoa IT
('SV0001', 'C00002', 6.00),
('SV0002', 'C00002', 8.00),
('SV0005', 'C00003', 9.00);

CREATE OR REPLACE VIEW view_student_basic AS
SELECT 
    s.student_id,
    s.full_name,
    d.dept_name
FROM student s
JOIN department d ON s.dept_id = d.dept_id;

-- Truy vấn toàn bộ dữ liệu từ View
SELECT * FROM view_student_basic;

-- Câu 2: Tạo Non-Unique Index cho cột full_name

CREATE INDEX idx_full_name
ON student(full_name);



-- Câu 3: Stored Procedure get_students_it()
-- Hiển thị toàn bộ sinh viên thuộc khoa Information Technology
DELIMITER $$

CREATE PROCEDURE get_students_it()
BEGIN
    SELECT 
        s.student_id,
        s.full_name,
        s.gender,
        s.birth_date,
        d.dept_name
    FROM student s
    JOIN department d ON s.dept_id = d.dept_id
    WHERE d.dept_name = 'Information Technology';
END$$

DELIMITER ;

-- Gọi procedure để kiểm tra
CALL get_students_it();


-- Câu 4a: Tạo View view_student_count_by_dept
-- Hiển thị số lượng sinh viên của mỗi khoa

CREATE OR REPLACE VIEW view_student_count_by_dept AS
SELECT 
    d.dept_name,
    COUNT(s.student_id) AS total_students
FROM department d
LEFT JOIN student s ON d.dept_id = s.dept_id
GROUP BY d.dept_id, d.dept_name;

-- Câu 4b: Truy vấn khoa có nhiều sinh viên nhất
SELECT *
FROM view_student_count_by_dept
WHERE total_students = (
    SELECT MAX(total_students)
    FROM view_student_count_by_dept
);


-- Câu 5a: Stored Procedure get_top_score_student()
-- Tham số: var_course_id VARCHAR(6)
-- Hiển thị tất cả sinh viên có điểm cao nhất của môn học

DELIMITER $$

CREATE PROCEDURE get_top_score_student(
    IN var_course_id VARCHAR(6)
)
BEGIN
    SELECT 
        s.student_id,
        s.full_name,
        c.course_id,
        c.course_name,
        e.score
    FROM enrollment e
    JOIN student s ON e.student_id = s.student_id
    JOIN course c ON e.course_id = c.course_id
    WHERE e.course_id = var_course_id
      AND e.score = (
          SELECT MAX(score)
          FROM enrollment
          WHERE course_id = var_course_id
      );
END$$

DELIMITER ;

-- Câu 5b: Gọi procedure cho môn Database Systems (C00001)

CALL get_top_score_student('C00001');