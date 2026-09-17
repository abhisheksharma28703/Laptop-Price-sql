# Laptop Price Data Cleaning & EDA using SQL

A simple end-to-end SQL project to clean a messy laptop dataset, perform exploratory data analysis, and engineer new features for analysis.

## Files in this Project

- `laptopData.csv` : Raw dataset with 1,303 laptop records.
- `01_setup.sql` : Creates database and backup table (`laptops_backup`).
- `02_cleaning.sql` : Cleans null values, removes duplicates, strips units (`GB`, `kg`), and extracts new columns.
- `03_eda.sql` : Summary statistics, price distribution histogram, brand comparisons, and feature engineering.

---

## What is Done in this Project

### 1. Data Cleaning (`02_cleaning.sql`)
- **Null values**: Removed 30 empty rows from the dataset (1303 -> 1273).
- **Duplicates**: Removed 68 duplicate rows using Self-Join (1273 -> 1205).
- **RAM & Weight**: Removed `'GB'` from RAM and `'kg'` from Weight and converted them to numeric data types.
- **Operating System**: Grouped messy OS names into clean categories (`macos`, `windows`, `linux`, `N/A`, `other`).
- **CPU & GPU**: Extracted brand, clock speed in GHz, and model names.
- **Screen Resolution**: Extracted screen width, height, and a touchscreen flag (1/0).
- **Memory**: Extracted drive type (`SSD`, `HDD`, `Hybrid`) and converted storage to GB.

### 2. Exploratory Data Analysis (`03_eda.sql`)
- **Summary statistics**: Calculated Min, Max, Average, and Standard Deviation of prices.
- **Histogram**: Created a horizontal bar chart directly in SQL using `REPEAT('*', count/4)`.
- **Brand analysis**: Compared laptop counts and average prices across different brands.
- **Touchscreen & CPU comparison**: Built cross-tabulation tables for brand vs touchscreen and brand vs CPU.
- **Feature Engineering**:
  - Calculated **PPI (Pixels Per Inch)** using `SQRT(width^2 + height^2) / Inches`.
  - Created **Screen Size Buckets** (`small`, `medium`, `large`).
  - Simulated **One-Hot Encoding** for GPU brands using `CASE WHEN`.

---

## How to Run

1. Open **MySQL Workbench**.
2. Create database and import `laptopData.csv` into a table named `laptops`:
   ```sql
   CREATE DATABASE laptop_project;
   USE laptop_project;
   ```
3. Run the files in order:
   - Run `01_setup.sql`
   - Run `02_cleaning.sql`
   - Run `03_eda.sql`

---


