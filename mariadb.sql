CREATE DATABASE task_manager_db;
USE task_manager_db;
CREATE TABLE tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    description TEXT NOT NULL,
    deadline TIMESTAMP,
    priority ENUM('low', 'medium', 'high') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status ENUM('pending', 'completed') DEFAULT 'pending',
    finished_at TIMESTAMP);
    
/* testing data

INSERT INTO tasks (description, deadline, priority)
VALUES
    ('To call a friend', '2025-01-07', 'high'),
    ('To eat an apple', '2025-01-09', 'medium'),
    ('To sing a song', '2025-01-06', 'low');


SHOW TABLES;
SELECT * FROM tasks;
*/
