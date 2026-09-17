USE laptop_project;

SELECT * FROM laptops_backup;

-- 1. Head, tail, and sample
SELECT * FROM laptops_backup ORDER BY `index` LIMIT 5;
SELECT * FROM laptops_backup ORDER BY `index` DESC LIMIT 5;
SELECT * FROM laptops_backup ORDER BY RAND() LIMIT 5;

-- 2. Basic summary statistics
SELECT 
    COUNT(Price) AS total_laptops,
    MIN(Price) AS min_price,
    MAX(Price) AS max_price,
    ROUND(AVG(Price)) AS avg_price,
    ROUND(STD(Price)) AS std_price
FROM laptops_backup;

-- 3. Check missing values
SELECT COUNT(*) FROM laptops_backup WHERE Price IS NULL;

-- 4. Price range distribution (histogram using repeat)
SELECT t.price_bucket, REPEAT('*', COUNT(*)/4) AS count_bar
FROM (
    SELECT Price,
    CASE 
        WHEN Price BETWEEN 0 AND 25000 THEN '0-25K'
        WHEN Price BETWEEN 25001 AND 50000 THEN '25K-50K'
        WHEN Price BETWEEN 50001 AND 75000 THEN '50K-75K'
        WHEN Price BETWEEN 75001 AND 100000 THEN '75K-100K'
        ELSE '>100K'
    END AS price_bucket
    FROM laptops_backup
) t
GROUP BY t.price_bucket;

-- 5. Laptops count by brand
SELECT Company, COUNT(*) AS count
FROM laptops_backup
GROUP BY Company
ORDER BY count DESC;

-- 6. CPU speed vs Price
SELECT cpu_speed, Price FROM laptops_backup;

-- 7. Brand vs Touchscreen (contingency table)
SELECT Company,
    SUM(CASE WHEN touchscreen = 1 THEN 1 ELSE 0 END) AS Touchscreen_yes,
    SUM(CASE WHEN touchscreen = 0 THEN 1 ELSE 0 END) AS Touchscreen_no
FROM laptops_backup
GROUP BY Company;

-- 8. Brand vs CPU brand
SELECT Company,
    SUM(CASE WHEN cpu_brand = 'Intel' THEN 1 ELSE 0 END) AS intel,
    SUM(CASE WHEN cpu_brand = 'AMD' THEN 1 ELSE 0 END) AS amd,
    SUM(CASE WHEN cpu_brand = 'Samsung' THEN 1 ELSE 0 END) AS samsung
FROM laptops_backup
GROUP BY Company;

-- 9. Price statistics by brand
SELECT Company,
    MIN(Price) AS min_price,
    MAX(Price) AS max_price,
    ROUND(AVG(Price)) AS avg_price,
    ROUND(STD(Price)) AS std_price
FROM laptops_backup
GROUP BY Company
ORDER BY avg_price DESC;

-- 10. Feature Engineering: Pixels Per Inch (PPI)
ALTER TABLE laptops_backup ADD COLUMN ppi INT;

UPDATE laptops_backup
SET ppi = ROUND(SQRT(resolution_width*resolution_width + resolution_height*resolution_height) / Inches)
WHERE Inches > 0;

SELECT Company, TypeName, ppi, Price
FROM laptops_backup
ORDER BY ppi DESC;

-- 11. Feature Engineering: Screen size bucketing (small, medium, large)
ALTER TABLE laptops_backup ADD COLUMN screen_size VARCHAR(255) AFTER Inches;

UPDATE laptops_backup
SET screen_size = CASE 
    WHEN Inches < 14.0 THEN 'small'
    WHEN Inches >= 14.0 AND Inches < 17.0 THEN 'medium'
    ELSE 'large'
END;

SELECT screen_size, ROUND(AVG(Price)) AS avg_price
FROM laptops_backup
GROUP BY screen_size;

-- 12. One-Hot Encoding for GPU brand
SELECT gpu_brand,
    CASE WHEN gpu_brand = 'Intel' THEN 1 ELSE 0 END AS intel,
    CASE WHEN gpu_brand = 'AMD' THEN 1 ELSE 0 END AS amd,
    CASE WHEN gpu_brand = 'Nvidia' THEN 1 ELSE 0 END AS nvidia,
    CASE WHEN gpu_brand = 'ARM' THEN 1 ELSE 0 END AS arm
FROM laptops_backup;
