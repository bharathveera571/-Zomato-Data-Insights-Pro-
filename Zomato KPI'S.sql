create database Zomato_analytics_project;
use Zomato_analytics_project;
select * from countrydata;
select * from currencydata;
select * from maindata;
select count(*) from maindata;

--------- calendertable--------------

-- Add a new column for Opening_Date
ALTER TABLE MainData
ADD COLUMN Opening_Date DATE;

-- Populate the Opening_Date column by combining existing columns
UPDATE MainData
SET Opening_Date = STR_TO_DATE(CONCAT(`Year Opening`, '-', `Month Opening`, '-', `Day Opening`), '%Y-%m-%d');

-- Add columns for the required date-derived fields
ALTER TABLE MainData
ADD COLUMN Year INT,
ADD COLUMN MonthNo INT,
ADD COLUMN MonthFullName VARCHAR(20),
ADD COLUMN Quarter VARCHAR(5),
ADD COLUMN YearMonth VARCHAR(10),
ADD COLUMN WeekdayNo INT,
ADD COLUMN WeekdayName VARCHAR(20),
ADD COLUMN FinancialMonth VARCHAR(5),
ADD COLUMN FinancialQuarter VARCHAR(5);

-- Populate the new columns with appropriate values
UPDATE MainData
SET Year = YEAR(Opening_Date),
    MonthNo = MONTH(Opening_Date),
    MonthFullName = MONTHNAME(Opening_Date),
    Quarter = CONCAT('Q', QUARTER(Opening_Date)),
    YearMonth = DATE_FORMAT(Opening_Date, '%Y-%b'),
    WeekdayNo = DAYOFWEEK(Opening_Date),
    WeekdayName = DAYNAME(Opening_Date),
    FinancialMonth = CASE
        WHEN MONTH(Opening_Date) >= 4 THEN CONCAT('FM', MONTH(Opening_Date) - 3)
        ELSE CONCAT('FM', MONTH(Opening_Date) + 9)
    END,
    FinancialQuarter = CASE
        WHEN MONTH(Opening_Date) IN (4, 5, 6) THEN 'FQ-1'
        WHEN MONTH(Opening_Date) IN (7, 8, 9) THEN 'FQ-2'
        WHEN MONTH(Opening_Date) IN (10, 11, 12) THEN 'FQ-3'
        ELSE 'FQ-4'
    END;
select * from maindata;

----------- Convert the Average cost for 2 column into USD dollars (currently the Average cost for 2 in local currencies ----------------

ALTER TABLE maindata ADD COLUMN average_cost_for_Two_Dollars FLOAT;

ALTER TABLE Maindata ADD COLUMN average_cost VARCHAR(255) 
AS (CONCAT('$', FORMAT(((Average_Cost_for_two + Price_range) / 2) * 0.012, 2))) STORED;
select * from maindata;
-----------  Find the Numbers of Restaurants based on City and Country ---------------
select * from countrydata;
SELECT 
    City, 
    Countryname, 
    COUNT(*) AS Number_of_Restaurants
FROM 
    MainData
JOIN 
    CountryData
ON 
    MainData.CountryCode = CountryData.CountryID
GROUP BY 
    City, Countryname
ORDER BY 
    Countryname, City;
    
----------- Numbers of Restaurants opening based on Year, Quarter , Month --------------------------------
select * from maindata;
SELECT Year, COUNT(*) AS Number_of_Restaurants
FROM MainData
GROUP BY Year
ORDER BY Year;

SELECT Year,Quarter, COUNT(*) AS Number_of_Restaurants
FROM MainData
GROUP BY Year,Quarter
ORDER BY Year,Quarter;

SELECT Year,MonthNo,COUNT(*) AS Number_of_Restaurants
FROM MainData
GROUP BY Year,MonthNo
ORDER BY Year,MonthNo;

------------------------ Count of Restaurants based on Average Ratings ----------------------------------------
SELECT Rating, COUNT(*) AS Number_of_Restaurants
FROM MainData
GROUP BY Rating
ORDER BY Rating;

------------- Create buckets based on Average Price of reasonable size and find out how many restaurants falls in each buckets  -------------------------------------------------
SELECT 
    CASE 
        WHEN Average_Cost_for_two BETWEEN 0 AND 500 THEN '0-500'
        WHEN Average_Cost_for_two BETWEEN 501 AND 1000 THEN '501-1000'
        WHEN Average_Cost_for_two BETWEEN 1001 AND 1500 THEN '1001-1500'
        WHEN Average_Cost_for_two BETWEEN 1501 AND 2000 THEN '1501-2000'
        ELSE '2001+'
    END AS Price_Bucket,
    COUNT(*) AS Number_of_Restaurants
FROM MainData
GROUP BY Price_Bucket
ORDER BY Price_Bucket;

-------------- Percentage of Restaurants based on "Has_Table_booking"------------------------------
SELECT Has_Table_booking,COUNT(*) AS Number_of_Restaurants,
(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM MainData)) AS Percentage
FROM MainData
GROUP BY Has_Table_booking;

---------------------- Percentage of Restaurants based on "Has_Online_delivery"-----------------------------------
SELECT Has_Online_delivery,COUNT(*) AS Number_of_Restaurants,
(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM MainData)) AS Percentage
FROM MainData
GROUP BY Has_Online_delivery;
-------------------- Develop Charts based on Cusines, City, Ratings -------------------------
------------- 1. Table for Number of Restaurants by Cuisine -----------------
SELECT Cuisines, COUNT(*) AS Number_of_Restaurants
FROM MainData
GROUP BY Cuisines
ORDER BY Number_of_Restaurants DESC;
------------ 2. Table for Number of Restaurants by City ---------------------------
SELECT City, COUNT(*) AS Number_of_Restaurants
FROM MainData
GROUP BY City
ORDER BY Number_of_Restaurants DESC;
--------------- 3.Average Cost for Two by City ------------------------------

SELECT City, AVG(Average_Cost_for_two) AS Average_Cost_for_Two
FROM MainData
GROUP BY City
ORDER BY Average_Cost_for_Two DESC;

---------------------------------- Thank You----------------------------------------









