-- Create a fresh new database
CREATE DATABASE insurance_db;

-- Rename Table
RENAME TABLE `insurance data` TO insurance_data;

-- To verify data
SELECT * FROM insurance_data;

-- Create staging table
CREATE TABLE insurance_staging LIKE insurance_data;

-- Copy data
INSERT INTO insurance_staging
SELECT * FROM insurance_data;

-- Verify data
SELECT COUNT(*) FROM insurance_staging;
SELECT * FROM insurance_staging LIMIT 10;

-- ✅ Rename typo column
ALTER TABLE insurance_staging
RENAME COLUMN `houesehold_Income` TO `household_income`;

-- To verify data
SELECT * FROM insurance_data;

-- Optional: Delete unused columns
ALTER TABLE insurance_staging
DROP COLUMN birthdate;

-- Vrify table
SELECT * FROM insurance_staging LIMIT 10;

--- To check Null Values
SELECT *
FROM insurance_staging
WHERE id IS NULL
   OR age IS NULL
   OR marital_status IS NULL
   OR car_use IS NULL
   OR gender IS NULL
   OR kids_driving IS NULL
   OR parent IS NULL
   OR education IS NULL
   OR car_make IS NULL
   OR car_model IS NULL
   OR car_color IS NULL
   OR car_year IS NULL
   OR claim_freq IS NULL
   OR coverage_zone IS NULL
   OR claim_amt IS NULL
   OR household_income IS NULL;
   
   -- Remove Duplicates (Identify duplicates first)

WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY id,
                            age,
                            marital_status,
                            car_use,
                            gender,
                            kids_driving,
                            parent,
                            education,
                            car_make,
                            car_model,
                            car_color,
                            car_year,
                            claim_freq,
                            coverage_zone,
                            claim_amt,
                            household_income
               ORDER BY id
           ) AS row_num
    FROM insurance_staging
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY id;


-- Exploratory Data Analysis
-- Count total records
SELECT COUNT(*) FROM insurance_staging;

-- Basic stats for numeric columns
SELECT 
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    AVG(age) AS avg_age,
    MIN(claim_amt) AS min_claim,
    MAX(claim_amt) AS max_claim,
    AVG(claim_amt) AS avg_claim,
    MIN(household_income) AS min_income,
    MAX(household_income) AS max_income,
    AVG(household_income) AS avg_income
FROM insurance_staging;

-- Top 10 highest claims
SELECT id, claim_amt, age, car_make, car_model
FROM insurance_staging
ORDER BY claim_amt DESC
LIMIT 10;

-- Average claim per gender
SELECT gender, AVG(claim_amt) AS avg_claim
FROM insurance_staging
GROUP BY gender;

-- Creating a bucket list
SELECT
    id,
    age,
    household_income,
    car_year,
    claim_amt,

    -- Age Group
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18–25'
        WHEN age BETWEEN 26 AND 35 THEN '26–35'
        WHEN age BETWEEN 36 AND 45 THEN '36–45'
        WHEN age BETWEEN 46 AND 55 THEN '46–55'
        ELSE '56+'
    END AS age_group,

    -- Income Group
    CASE
        WHEN household_income < 60000 THEN 'Low'
        WHEN household_income BETWEEN 60000 AND 120000 THEN 'Middle'
        ELSE 'High'
    END AS income_group,

    -- Car Age
    2026 - car_year AS car_age,

    -- Car Age Group
    CASE
        WHEN 2026 - car_year BETWEEN 0 AND 3 THEN '0–3 yrs'
        WHEN 2026 - car_year BETWEEN 4 AND 7 THEN '4–7 yrs'
        WHEN 2026 - car_year BETWEEN 8 AND 12 THEN '8–12 yrs'
        ELSE '13+ yrs'
    END AS car_age_group

FROM insurance_staging
LIMIT 50; 

-- Create a view to use these buckets in multiple queries
CREATE OR REPLACE VIEW vw_insurance_buckets AS
SELECT *,
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18–25'
        WHEN age BETWEEN 26 AND 35 THEN '26–35'
        WHEN age BETWEEN 36 AND 45 THEN '36–45'
        WHEN age BETWEEN 46 AND 55 THEN '46–55'
        ELSE '56+'
    END AS age_group,
    CASE
        WHEN household_income < 60000 THEN 'Low'
        WHEN household_income BETWEEN 60000 AND 120000 THEN 'Middle'
        ELSE 'High'
    END AS income_group,
    2026 - car_year AS car_age,
    CASE
        WHEN 2026 - car_year BETWEEN 0 AND 3 THEN '0–3 yrs'
        WHEN 2026 - car_year BETWEEN 4 AND 7 THEN '4–7 yrs'
        WHEN 2026 - car_year BETWEEN 8 AND 12 THEN '8–12 yrs'
        ELSE '13+ yrs'
    END AS car_age_group
FROM insurance_staging;

SELECT age_group, AVG(claim_amt) FROM vw_insurance_buckets GROUP BY age_group;
SELECT income_group, AVG(claim_amt) FROM vw_insurance_buckets GROUP BY income_group;
SELECT car_age_group, AVG(claim_amt) FROM vw_insurance_buckets GROUP BY car_age_group;

.
