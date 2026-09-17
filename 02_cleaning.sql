USE laptop_project;

SELECT * FROM laptops_backup;

-- 1. Number of rows
SELECT COUNT(*) FROM laptops_backup;

-- 2. Check memory consumption
SELECT `DATA_LENGTH`/1024 AS 'data occupied in KBs'
FROM information_schema.TABLES
WHERE table_schema = 'laptop_project'
AND table_name = 'laptops_backup';

-- 3. Rename first column to index
ALTER TABLE laptops_backup
CHANGE COLUMN `Unnamed: 0` `index` INT;

SELECT * FROM laptops_backup;

-- 4. Drop null values (empty rows)
DELETE FROM laptops_backup
WHERE Company IS NULL AND TypeName IS NULL AND Cpu IS NULL;

-- Clean dirty '?' values
UPDATE laptops_backup SET Inches = NULL WHERE Inches = '?';
UPDATE laptops_backup SET Weight = NULL WHERE Weight = '?';
UPDATE laptops_backup SET Memory = NULL WHERE Memory = '?';

SELECT COUNT(*) FROM laptops_backup; -- 1273 rows

-- 5. Drop duplicates (keeping cheaper model or lower index)
DELETE T1
FROM laptops_backup AS T1
INNER JOIN laptops_backup AS T2
  ON T1.Company = T2.Company
  AND T1.TypeName = T2.TypeName
  AND T1.Cpu = T2.Cpu
  AND T1.Ram = T2.Ram
  AND T1.Gpu = T2.Gpu
WHERE T1.Price > T2.Price
   OR (T1.Price = T2.Price AND T1.`index` > T2.`index`);

SELECT COUNT(*) FROM laptops_backup; -- 1205 rows

-- 6. Clean RAM column
UPDATE laptops_backup SET Ram = REPLACE(Ram, 'GB', '');
ALTER TABLE laptops_backup MODIFY COLUMN Ram INT;

-- 7. Clean Weight column
UPDATE laptops_backup SET Weight = REPLACE(Weight, 'kg', '');
ALTER TABLE laptops_backup MODIFY COLUMN Weight DECIMAL(10,2);

-- 8. Clean Inches column
ALTER TABLE laptops_backup MODIFY COLUMN Inches DECIMAL(10,1);

-- 9. Clean Price column
UPDATE laptops_backup SET Price = ROUND(Price);
ALTER TABLE laptops_backup MODIFY COLUMN Price INT;

-- 10. Clean Operating System
SELECT DISTINCT OpSys FROM laptops_backup;

UPDATE laptops_backup
SET OpSys = CASE 
    WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'other'
END;

-- 11. Extract GPU brand
ALTER TABLE laptops_backup ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu;
UPDATE laptops_backup SET gpu_brand = SUBSTRING_INDEX(Gpu, ' ', 1);
ALTER TABLE laptops_backup DROP COLUMN Gpu;

-- 12. Extract CPU brand, speed, and name
ALTER TABLE laptops_backup
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_brand,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_speed;

UPDATE laptops_backup SET cpu_brand = SUBSTRING_INDEX(Cpu, ' ', 1);
UPDATE laptops_backup SET cpu_speed = CAST(REPLACE(SUBSTRING_INDEX(Cpu, ' ', -1), 'GHz', '') AS DECIMAL(10,1));
UPDATE laptops_backup SET cpu_name = SUBSTRING_INDEX(TRIM(REPLACE(Cpu, cpu_brand, '')), ' ', 2);
ALTER TABLE laptops_backup DROP COLUMN Cpu;

-- 13. Extract Resolution width, height, and touchscreen
ALTER TABLE laptops_backup
ADD COLUMN resolution_width INT AFTER ScreenResolution,
ADD COLUMN resolution_height INT AFTER resolution_width,
ADD COLUMN touchscreen INT AFTER resolution_height;

UPDATE laptops_backup
SET resolution_width = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution, ' ', -1), 'x', 1),
    resolution_height = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution, ' ', -1), 'x', -1),
    touchscreen = CASE WHEN ScreenResolution LIKE '%Touch%' THEN 1 ELSE 0 END;

ALTER TABLE laptops_backup DROP COLUMN ScreenResolution;

-- 14. Clean Memory column (storage type, primary storage, secondary storage)
ALTER TABLE laptops_backup
ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN primary_storage INT AFTER memory_type,
ADD COLUMN secondary_storage INT AFTER primary_storage;

UPDATE laptops_backup
SET memory_type = CASE
    WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    WHEN Memory LIKE '%SSD%' THEN 'SSD'
    WHEN Memory LIKE '%HDD%' THEN 'HDD'
    WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
    ELSE 'Other'
END;

UPDATE laptops_backup
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory, '+', 1), '[0-9]+'),
    secondary_storage = CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory, '+', -1), '[0-9]+') ELSE 0 END;

-- Convert TB to GB
UPDATE laptops_backup
SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage * 1024 ELSE primary_storage END,
    secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage * 1024 ELSE secondary_storage END;

ALTER TABLE laptops_backup DROP COLUMN Memory;

SELECT * FROM laptops_backup;
