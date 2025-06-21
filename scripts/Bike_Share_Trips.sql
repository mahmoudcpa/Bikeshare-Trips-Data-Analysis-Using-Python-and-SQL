USE master;
GO

-- Drop and recreate the 'BikeShareTrips' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'BikeShareTrips')
BEGIN
	ALTER DATABASE BikeShareTrips
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE BikeShareTrips
END;
GO

-- Create the 'Energy' database
CREATE DATABASE BikeShareTrips;
GO


USE BikeShareTrips;

IF OBJECT_ID('bikeshare_trips', 'U') IS NOT NULL
	DROP TABLE bikeshare_trips;

CREATE TABLE bikeshare_trips (
	trip_id					INT,
	duration_sec				INT,
	start_date				NVARCHAR(50),
	start_station_name			NVARCHAR(50),
	start_station_id			INT,
	end_date				NVARCHAR(50),
	end_station_name			NVARCHAR(50),
	end_station_id				INT,
	bike_number				INT,
	zip_code				NVARCHAR(50),
	subscriber_type				NVARCHAR(50)
);

TRUNCATE TABLE bikeshare_trips;
BULK INSERT bikeshare_trips
FROM 'F:\Mn\MN_Learn\Data_Analysis\Bikeshare_Trips\bikeshare_trips.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);

SELECT name FROM sys.databases;

USE BikeShareTrips;
GO

SELECT USER_NAME();  -- Who are you logged in as?

SELECT
	CAST(REPLACE(start_date, 'UTC', '') AS DATETIME2) AS start_time
FROM dbo.bikeshare_trips
;

-- Add a new columns
ALTER TABLE dbo.bikeshare_trips
ADD trip_start_time DATETIME2;

-- Update the new columns with converted values
UPDATE dbo.bikeshare_trips
SET trip_start_time = CAST(REPLACE(start_date, 'UTC', '') AS DATETIME2);

ALTER TABLE dbo.bikeshare_trips
ADD trip_end_time DATETIME2;

UPDATE dbo.bikeshare_trips
SET trip_end_time = CAST(REPLACE(end_date, 'UTC', '') AS DATETIME2);

-- Drop old columns
ALTER TABLE dbo.bikeshare_trips
DROP COLUMN start_date;

ALTER TABLE dbo.bikeshare_trips
DROP COLUMN end_date;

/*
============================================================================
Convert & Replace Multiple Columns
============================================================================

-- Step 1: Add new columns for each datetime field
ALTER TABLE dbo.bikeshare_trips ADD trip_start_time DATETIME2;
ALTER TABLE dbo.bikeshare_trips ADD trip_end_time DATETIME2;

-- Step 2: Update each new column with cleaned datetime values
UPDATE dbo.bikeshare_trips
SET trip_start_time = CAST(REPLACE(start_date, 'UTC', '') AS DATETIME2);
SET trip_end_time = CAST(REPLACE(end_date, 'UTC', '') AS DATETIME2);

-- -- Step 3: Drop original columns 
ALTER TABLE dbo.bikeshare_trips DROP COLUMN start_date;
ALTER TABLE dbo.bikeshare_trips DROP COLUMN end_date;
*/


SELECT TOP 5
*
FROM dbo.bikeshare_trips;

-- Total & Average Trip Duration per Start Station
SELECT
	start_station_name,
	COUNT(*) AS total_trips,
	SUM(duration_sec) / 60 AS total_duration_minutes,
	AVG(duration_sec) / 60 AS avg_duration_minutes
FROM dbo.bikeshare_trips
WHERE duration_sec IS NOT NULL
GROUP BY start_station_name
ORDER BY total_duration_minutes DESC
;

-- Total & Average Trip Duration per Bike Number
SELECT 
	bike_number,
	COUNT(*) AS total_trips,
	SUM(duration_sec) / 60 AS total_duration_minutes,
	AVG(duration_sec) / 60 AS avg_trip_duration_minutes
FROM dbo.bikeshare_trips
GROUP BY bike_number
ORDER BY COUNT(*) DESC;


-- Total & Average Trip Duration per Zip Code
SELECT
	zip_code,
	COUNT(*) AS total_trips,
	SUM(duration_sec) / 60 AS total_duration_minutes,
	AVG(duration_sec) / 60 AS avg_duration_minutes
FROM dbo.bikeshare_trips
GROUP BY zip_code
ORDER BY AVG(duration_sec) / 60 DESC;


