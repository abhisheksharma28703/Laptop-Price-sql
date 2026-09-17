-- Database Setup & Staging Backup

CREATE DATABASE IF NOT EXISTS laptop_project;
USE laptop_project;

SELECT * FROM laptops;

-- Create backup table
DROP TABLE IF EXISTS laptops_backup;
CREATE TABLE laptops_backup LIKE laptops;
INSERT INTO laptops_backup SELECT * FROM laptops;

SELECT * FROM laptops_backup;
