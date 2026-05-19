CREATE DATABASE hotel_management;
USE hotel_management;

-- 1. Guests
CREATE TABLE Guests (
    guest_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    loyalty_points INT NOT NULL DEFAULT 0 CHECK (loyalty_points >= 0)
);

-- 2. Guest Profiles
CREATE TABLE Guest_Profiles (
    profile_id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT NOT NULL UNIQUE,
    address VARCHAR(255),
    date_of_birth DATE,
    national_id VARCHAR(20) NOT NULL UNIQUE,
    FOREIGN KEY (guest_id) REFERENCES Guests(guest_id)
);

-- 3. Rooms
CREATE TABLE Rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_name VARCHAR(100) NOT NULL,
    room_type ENUM('Standard', 'Deluxe', 'Suite') NOT NULL,
    price_per_night DECIMAL(12,2) NOT NULL CHECK (price_per_night > 0),
    room_status ENUM('Available', 'Occupied', 'Maintenance') NOT NULL
);

-- 4. Bookings
CREATE TABLE Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in_date DATETIME NOT NULL,
    check_out_date DATETIME NOT NULL,
    total_charge DECIMAL(15,2) NOT NULL,
    booking_status ENUM('Pending', 'Completed', 'Cancelled') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guest_id) REFERENCES Guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);

-- 5. Room Log
CREATE TABLE Room_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    action_type ENUM('Check-in', 'Check-out', 'Maintenance', 'Cancelled') NOT NULL,
    reason TEXT,
    logged_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);

-- Guests
INSERT INTO Guests (full_name, email, phone, loyalty_points) VALUES
('Nguyen Van A', 'vana@gmail.com', '0901111111', 100),
('Tran Thi B', 'thib@yahoo.com', '0902222222', 50),
('Le Van C', 'vanc@gmail.com', '0903333333', 250),
('Pham Thi D', 'thid@gmail.com', '0904444444', 20),
('Hoang Van E', 'vane@outlook.com', '0905555555', 400);

-- Guest Profiles
INSERT INTO Guest_Profiles (guest_id, address, date_of_birth, national_id) VALUES
(1, 'Ha Noi', '1995-05-10', '001111111111'),
(2, 'Hai Phong', '1993-07-20', '002222222222'),
(3, 'Da Nang', '1990-01-15', '003333333333'),
(4, 'Can Tho', '1998-11-25', '004444444444'),
(5, 'Ho Chi Minh', '1988-03-30', '005555555555');

-- Rooms
INSERT INTO Rooms (room_name, room_type, price_per_night, room_status) VALUES
('Room 101', 'Standard', 800000, 'Available'),
('Room 102', 'Deluxe', 1500000, 'Occupied'),
('Room 201', 'Suite', 3000000, 'Available'),
('Room 202', 'Deluxe', 1800000, 'Maintenance'),
('Room 301', 'Suite', 3500000, 'Occupied');

-- Bookings
INSERT INTO Bookings
(guest_id, room_id, check_in_date, check_out_date, total_charge, booking_status, created_at)
VALUES
(1, 2, '2023-11-01 14:00:00', '2023-11-03 12:00:00', 3000000, 'Completed', '2023-11-01'),
(2, 1, '2023-11-05 14:00:00', '2023-11-06 12:00:00', 800000, 'Cancelled', '2023-11-05'),
(3, 3, '2023-11-10 14:00:00', '2023-11-15 12:00:00', 15000000, 'Completed', '2023-11-10'),
(4, 4, '2023-11-12 14:00:00', '2023-11-13 12:00:00', 1800000, 'Pending', '2023-11-12'),
(5, 5, '2023-11-15 14:00:00', '2023-11-20 12:00:00', 25000000, 'Completed', '2023-11-15'),
(3, 5, '2023-12-01 14:00:00', '2023-12-04 12:00:00', 12000000, 'Completed', '2023-12-01');

-- Room Log
INSERT INTO Room_Log (room_id, action_type, reason, logged_at) VALUES
(2, 'Check-in', 'Guest checked in', '2023-11-01 14:00:00'),
(2, 'Check-out', 'Guest checked out', '2023-11-03 12:00:00'),
(4, 'Maintenance', 'Air conditioner broken', '2023-11-08 09:00:00'),
(1, 'Cancelled', 'Booking cancelled by customer', '2023-11-05 10:00:00'),
(5, 'Check-in', 'VIP guest arrival', '2023-11-15 14:00:00');


UPDATE Guests
SET loyalty_points = loyalty_points + 200
WHERE email LIKE '%@gmail.com';

DELETE FROM Room_Log
WHERE logged_at < '2023-11-10';


SELECT room_name, price_per_night, room_status
FROM Rooms
WHERE price_per_night > 1000000
   OR room_status = 'Maintenance'
   OR room_type = 'Suite';

SELECT full_name, email
FROM Guests
WHERE email LIKE '%@gmail.com'
  AND loyalty_points BETWEEN 50 AND 300;

SELECT *
FROM Bookings
ORDER BY total_charge DESC
LIMIT 3 OFFSET 1;

SELECT
    g.full_name,
    gp.national_id,
    b.booking_id,
    b.check_in_date,
    b.total_charge
FROM Bookings b
JOIN Guests g ON b.guest_id = g.guest_id
JOIN Guest_Profiles gp ON g.guest_id = gp.guest_id;

SELECT
    g.guest_id,
    g.full_name,
    SUM(b.total_charge) AS total_spent
FROM Guests g
JOIN Bookings b ON g.guest_id = b.guest_id
WHERE b.booking_status = 'Completed'
GROUP BY g.guest_id, g.full_name
HAVING SUM(b.total_charge) > 20000000;

SELECT r.*
FROM Rooms r
WHERE r.room_id IN (
    SELECT DISTINCT room_id
    FROM Bookings
    WHERE booking_status = 'Completed'
)
AND r.price_per_night = (
    SELECT MAX(r2.price_per_night)
    FROM Rooms r2
    WHERE r2.room_id IN (
        SELECT DISTINCT room_id
        FROM Bookings
        WHERE booking_status = 'Completed'
    )
);


CREATE INDEX idx_booking_status_date
ON Bookings (booking_status, created_at);


CREATE VIEW vw_guest_booking_stats AS
SELECT
    g.guest_id,
    g.full_name AS guest_name,
    COUNT(b.booking_id) AS total_bookings,
    COALESCE(SUM(
        CASE
            WHEN b.booking_status <> 'Cancelled'
            THEN b.total_charge
            ELSE 0
        END
    ), 0) AS total_paid
FROM Guests g
LEFT JOIN Bookings b
    ON g.guest_id = b.guest_id
GROUP BY g.guest_id, g.full_name;

DELIMITER $$

-- Get all rooms
CREATE PROCEDURE sp_get_all_rooms()
BEGIN
    SELECT * FROM Rooms;
END $$

-- Get room by id
CREATE PROCEDURE sp_get_room_by_id(IN p_room_id INT)
BEGIN
    SELECT * FROM Rooms
    WHERE room_id = p_room_id;
END $$

-- Insert room
CREATE PROCEDURE sp_insert_room(
    IN p_room_name VARCHAR(100),
    IN p_room_type VARCHAR(20),
    IN p_price DECIMAL(12,2),
    IN p_status VARCHAR(20)
)
BEGIN
    INSERT INTO Rooms(room_name, room_type, price_per_night, room_status)
    VALUES (p_room_name, p_room_type, p_price, p_status);
END $$

-- Update room
CREATE PROCEDURE sp_update_room(
    IN p_room_id INT,
    IN p_room_name VARCHAR(100),
    IN p_room_type VARCHAR(20),
    IN p_price DECIMAL(12,2),
    IN p_status VARCHAR(20)
)
BEGIN
    UPDATE Rooms
    SET room_name = p_room_name,
        room_type = p_room_type,
        price_per_night = p_price,
        room_status = p_status
    WHERE room_id = p_room_id;
END $$

-- Delete room
CREATE PROCEDURE sp_delete_room(IN p_room_id INT)
BEGIN
    DECLARE booking_count INT;

    SELECT COUNT(*)
    INTO booking_count
    FROM Bookings
    WHERE room_id = p_room_id;

    IF booking_count = 0 THEN
        DELETE FROM Rooms
        WHERE room_id = p_room_id;
        SELECT 'Room deleted successfully' AS message;
    ELSE
        SELECT 'Cannot delete room because it has related bookings' AS message;
    END IF;
END $$

-- Get room status
CREATE PROCEDURE sp_get_room_status(IN p_room_id INT)
BEGIN
    DECLARE v_status VARCHAR(20);

    SELECT room_status
    INTO v_status
    FROM Rooms
    WHERE room_id = p_room_id;

    CASE
        WHEN v_status = 'Available' THEN
            SELECT 'Phòng trống' AS message;
        WHEN v_status = 'Occupied' THEN
            SELECT 'Đang có khách' AS message;
        WHEN v_status = 'Maintenance' THEN
            SELECT 'Bảo trì' AS message;
        ELSE
            SELECT 'Không tìm thấy phòng' AS message;
    END CASE;
END $$

-- Cancel booking
CREATE PROCEDURE sp_cancel_booking(IN p_booking_id INT)
BEGIN
    DECLARE v_room_id INT;

    START TRANSACTION;

    SELECT room_id
    INTO v_room_id
    FROM Bookings
    WHERE booking_id = p_booking_id;

    UPDATE Bookings
    SET booking_status = 'Cancelled'
    WHERE booking_id = p_booking_id;

    UPDATE Rooms
    SET room_status = 'Available'
    WHERE room_id = v_room_id;

    INSERT INTO Room_Log(room_id, action_type, reason, logged_at)
    VALUES (
        v_room_id,
        'Cancelled',
        'Booking cancelled',
        NOW()
    );

    COMMIT;

    SELECT 'Booking cancelled successfully' AS message;
END $$

DELIMITER ;

-- 9. TEST PROCEDURES


CALL sp_get_all_rooms();
CALL sp_get_room_by_id(1);
CALL sp_insert_room('Room 999', 'Standard', 900000, 'Available');
CALL sp_update_room(1, 'Room 101 VIP', 'Deluxe', 2000000, 'Available');
CALL sp_delete_room(1);
CALL sp_get_room_status(2);
CALL sp_cancel_booking(4);

