CREATE DATABASE social_network_db;
USE social_network_db;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    like_count INT DEFAULT 0,
    comment_count INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    FULLTEXT(content)
);

CREATE TABLE comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    FOREIGN KEY (post_id)
        REFERENCES posts(post_id)
);

CREATE TABLE likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    FOREIGN KEY (post_id)
        REFERENCES posts(post_id),

    UNIQUE(user_id, post_id)
);

CREATE TABLE friends (
    friend_ship_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    friend_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    FOREIGN KEY (friend_id)
        REFERENCES users(user_id)
);

CREATE TABLE post_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    post_content TEXT,
    deleted_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users(username, password, email)
VALUES
('an', '123456', 'an@gmail.com'),
('binh', '123456', 'binh@gmail.com'),
('cuong', '123456', 'cuong@gmail.com');

INSERT INTO posts(user_id, content)
VALUES
(1, 'hello everyone'),
(2, 'learning mysql'),
(3, 'today is beautiful');

INSERT INTO comments(user_id, post_id, content)
VALUES
(1, 2, 'good post'),
(2, 1, 'nice'),
(3, 1, 'very useful');

INSERT INTO likes(user_id, post_id)
VALUES
(1, 1),
(2, 1),
(3, 2);

INSERT INTO friends(user_id, friend_id)
VALUES
(1, 2),
(2, 3);

CREATE VIEW view_user_info AS
SELECT user_id,username,email,created_at
FROM users;

DELIMITER //

CREATE PROCEDURE sp_add_user(IN p_username VARCHAR(100),IN p_password VARCHAR(255),IN p_email VARCHAR(150))
BEGIN

    DECLARE sl_user INT DEFAULT 0;
    DECLARE sl_email INT DEFAULT 0;

    SELECT COUNT(*)
    INTO sl_user
    FROM users
    WHERE username = p_username;

    SELECT COUNT(*)
    INTO sl_email
    FROM users
    WHERE email = p_email;
    
    IF sl_user > 0 THEN
        SELECT 'username already exists' AS message;
    ELSEIF sl_email > 0 THEN
        SELECT 'email already exists' AS message;
    ELSE

        INSERT INTO users(username,password,email)
        VALUES(p_username,p_password,p_email);
        SELECT 'register success' AS message;
    END IF;

END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER tg_after_like_insert
AFTER INSERT
ON likes
FOR EACH ROW
BEGIN

    UPDATE posts
    SET like_count = like_count + 1
    WHERE post_id = NEW.post_id;

END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER tg_after_like_delete
AFTER DELETE
ON likes
FOR EACH ROW
BEGIN

    UPDATE posts
    SET like_count =
        CASE
            WHEN like_count > 0
            THEN like_count - 1
            ELSE 0
        END
    WHERE post_id = OLD.post_id;

END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER tg_after_comment_insert
AFTER INSERT
ON comments
FOR EACH ROW
BEGIN
    UPDATE posts
    SET comment_count = comment_count + 1
    WHERE post_id = NEW.post_id;

END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER tg_after_comment_delete
AFTER DELETE
ON comments
FOR EACH ROW
BEGIN

    UPDATE posts
    SET comment_count =
        CASE
            WHEN comment_count > 0
            THEN comment_count - 1
            ELSE 0
        END
    WHERE post_id = OLD.post_id;

END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE sp_user_activity_report()
BEGIN

    SELECT
        u.user_id,
        u.username,
        COUNT(DISTINCT p.post_id) AS total_posts,
        COUNT(DISTINCT l.like_id) AS total_likes,
        COUNT(DISTINCT c.comment_id) AS total_comments
    FROM users u
    LEFT JOIN posts p
        ON u.user_id = p.user_id
    LEFT JOIN likes l
        ON u.user_id = l.user_id
    LEFT JOIN comments c
        ON u.user_id = c.user_id

    GROUP BY
        u.user_id,
        u.username;

END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE sp_delete_user(IN p_user_id INT)
BEGIN

    DECLARE loi_sql INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET loi_sql = 1;
        ROLLBACK;
        SELECT 'delete failed' AS message;

    END;

    START TRANSACTION;
    DELETE FROM likes
    WHERE user_id = p_user_id;

    DELETE FROM comments 
    WHERE user_id = p_user_id;

    DELETE FROM friends
    WHERE user_id = p_user_id OR friend_id = p_user_id;
    
    DELETE FROM likes
    WHERE post_id IN (SELECT post_id FROM posts WHERE user_id = p_user_id);

    DELETE FROM comments
    WHERE post_id IN (SELECT post_id FROM posts WHERE user_id = p_user_id);

    DELETE FROM posts
    WHERE user_id = p_user_id;

    DELETE FROM users
    WHERE user_id = p_user_id;

    IF loi_sql = 0 THEN COMMIT;
        SELECT 'delete success' AS message;
    END IF;

END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER tg_before_friend_insert
BEFORE INSERT
ON friends
FOR EACH ROW
BEGIN
    DECLARE sl_trung INT DEFAULT 0;
    DECLARE sl_nguoc INT DEFAULT 0;

    IF NEW.user_id = NEW.friend_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'cannot add yourself';
    END IF;
    SELECT COUNT(*)
    INTO sl_trung
    FROM friends
    WHERE user_id = NEW.user_id
    AND friend_id = NEW.friend_id;

    IF sl_trung > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'friend already exists';
    END IF;
    SELECT COUNT(*)
    INTO sl_nguoc
    FROM friends
    WHERE user_id = NEW.friend_id
    AND friend_id = NEW.user_id;
    IF sl_nguoc > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'reverse friend request exists';
    END IF;

END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER tg_after_post_delete
AFTER DELETE
ON posts
FOR EACH ROW
BEGIN

    INSERT INTO post_logs(post_id,post_content) VALUES (OLD.post_id,OLD.content);
END //

DELIMITER ;

SELECT * FROM view_user_info;

CALL sp_add_user('david','123456','david@gmail.com');
CALL sp_user_activity_report();
CALL sp_delete_user(3);

INSERT INTO friends(user_id, friend_id)
VALUES(1, 1);

DELETE FROM posts
WHERE post_id = 1;

SELECT * FROM post_logs;