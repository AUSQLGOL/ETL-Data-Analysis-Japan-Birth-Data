--Creating DB
CREATE DATABASE japan_demographics;

--Creating Schemas
CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA analytics;

-----------------------------------------Create RAW Layer (TEXT)-----------------------------------------
CREATE TABLE raw.japan_birth_statistics (
    year TEXT,
    total_births TEXT,
    male_births TEXT,
    female_births TEXT,
    crude_birth_rate TEXT,
    sex_ratio_at_birth TEXT,
    total_fertility_rate TEXT
);

--Count Rows and Delete Headers
SELECT COUNT(*) FROM raw.japan_birth_statistics;

SELECT *
FROM raw.japan_birth_statistics
WHERE year = 'year';

DELETE FROM raw.japan_birth_statistics
WHERE year = 'year';

--Verify NULL Values
SELECT
    COUNT(*) AS total_rows,
    COUNT(year) AS non_null_year,
    COUNT(total_births) AS non_null_total_births,
    COUNT(total_fertility_rate) AS non_null_tfr
FROM raw.japan_birth_statistics;

--Detect Actual NULL Values
SELECT *
FROM raw.japan_birth_statistics
WHERE total_fertility_rate = ''
   OR total_fertility_rate IS NULL;

--Check for Duplicate Years
SELECT year, COUNT(*)
FROM raw.japan_birth_statistics
GROUP BY year
HAVING COUNT(*) > 1;

--Validate All Years are Numeric
SELECT *
FROM raw.japan_birth_statistics
WHERE year !~ '^[0-9]+$';


------------------------------------------Create STAGING Layer------------------------------------------
CREATE TABLE staging.japan_birth_statistics (
    year INT PRIMARY KEY,
    total_births BIGINT,
    male_births BIGINT,
    female_births BIGINT,
    crude_birth_rate NUMERIC(5,2),
    sex_ratio_at_birth NUMERIC(6,2),
    total_fertility_rate NUMERIC(4,2)
);

--Insert Transforming Data
INSERT INTO staging.japan_birth_statistics (
    year,
    total_births,
    male_births,
    female_births,
    crude_birth_rate,
    sex_ratio_at_birth,
    total_fertility_rate
)
SELECT
    year::INT,
    total_births::BIGINT,
    male_births::BIGINT,
    female_births::BIGINT,
    crude_birth_rate::NUMERIC,
    sex_ratio_at_birth::NUMERIC,
    NULLIF(total_fertility_rate, '')::NUMERIC
FROM raw.japan_birth_statistics;

--COUNT Validation
SELECT COUNT(*) FROM staging.japan_birth_statistics;


----------------------------------------Analysis Window Functions----------------------------------------
--Annual Change in Births
SELECT
    year,
    total_births,
    total_births 
        - LAG(total_births) OVER (ORDER BY year) AS yearly_change
FROM staging.japan_birth_statistics
ORDER BY year;

--Annual Percentage Change
SELECT
    year,
    total_births,
    ROUND(
        (
            (total_births - LAG(total_births) OVER (ORDER BY year))
            * 100.0
            / LAG(total_births) OVER (ORDER BY year)
        ), 2
    ) AS pct_change
FROM staging.japan_birth_statistics
ORDER BY year;

--Historical Peak
SELECT year, total_births
FROM staging.japan_birth_statistics
ORDER BY total_births DESC
LIMIT 1;

--Decade with Sharpest Decline
SELECT *
FROM (
    SELECT
        (year / 10) * 10 AS decade,
        ROUND(AVG(total_births),0) AS avg_births,
        ROUND(
            (
                (AVG(total_births) - LAG(AVG(total_births)) OVER (ORDER BY (year / 10) * 10))
                * 100.0
                / LAG(AVG(total_births)) OVER (ORDER BY (year / 10) * 10)
            ), 2
        ) AS pct_change
    FROM staging.japan_birth_statistics
    GROUP BY (year / 10) * 10
) t
WHERE pct_change IS NOT NULL
ORDER BY pct_change ASC
LIMIT 1;


-----------------------------------------Create Analytics Layer-----------------------------------------
--Final Table
CREATE TABLE analytics.fact_births AS
SELECT
    year,
    (year / 10) * 10 AS decade,
    total_births,
    
    --Annual Absolute Change
    total_births 
        - LAG(total_births) OVER (ORDER BY year) AS yearly_change,

    --Annual Percentage Change
    ROUND(
        (
            (total_births - LAG(total_births) OVER (ORDER BY year))
            * 100.0
            / LAG(total_births) OVER (ORDER BY year)
        ), 2
    ) AS pct_change,

    crude_birth_rate,
    total_fertility_rate
FROM staging.japan_birth_statistics
ORDER BY year;

--Verify Structural Missing Data
SELECT * 
FROM analytics.fact_births
LIMIT 20;

--Since what year DATA started reporting total_fertility_rate
SELECT MIN(year)
FROM analytics.fact_births
WHERE total_fertility_rate IS NOT NULL;
