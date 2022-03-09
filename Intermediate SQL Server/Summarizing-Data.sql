-- One
-- of the first steps in data analysis is examining data through aggregations. This chapter explores how to
-- create aggregations in SQL Server, a common first step in data exploration. You will also clean missing data and categorize data into bins
-- with CASE statements.
-- Creating aggregations
-- This
-- chapter uses data gathered by the National UFO Reporting Center. The data is contained in the Incidents table and in this lesson, you will be aggregating values in the DurationSeconds column.
-- Calculate the average, minimum and maximum
SELECT AVG(DurationSeconds) AS Average,
    MIN(DurationSeconds) AS Minimum,
    MAX(DurationSeconds) AS Maximum
FROM Incidents

-- Creating grouped aggregations
-- You can calculate statistics for each group using GROUP BY. For example, you can calculate the maximum value for each state using the following
-- query:

-- SELECT State, MAX(DurationSeconds)
-- FROM Incidents
-- GROUP BY State
-- To filter even further, for example, to find the values for states where the maximum value is greater than 10, you can
-- use the
-- HAVING clause.

-- Calculate the aggregations by Shape
SELECT Shape,
    AVG(DurationSeconds) AS Average,
    MIN(DurationSeconds) AS Minimum,
    MAX(DurationSeconds) AS Maximum
FROM Incidents
Group by Shape

-- Removing missing
-- values
-- There are a number of different techniques you can
-- use to fix missing data in T-SQL and in this exercise, you will focus on returning rows
-- with non-missing values. For example, to
-- return all rows
-- with non-missing SHAPE values, you can
-- use:

-- SELECT *
-- FROM Incidents
-- WHERE Shape IS NOT NULL

-- Return the specified columns
SELECT IncidentDateTime, IncidentState
FROM Incidents
-- Exclude all the missing values from IncidentState  
WHERE IncidentState IS NOT NULL

-- Imputing missing
-- values
-- (I)
-- In the previous exercise, you looked at the non-missing values in the IncidentState column. But what
-- if you want to replace the missing values
-- with another value instead of omitting them? You can do this using the ISNULL
-- () function. Here we replace all the missing values in the Shape column using the word 'Saucer':

-- SELECT Shape, ISNULL(Shape, 'Saucer') AS Shape2
-- FROM Incidents
-- You
-- can also
-- use ISNULL
-- () to replace values from a different column instead of a specified word.

-- Check the IncidentState column for missing values and replace them with the City column
SELECT IncidentState, ISNULL(IncidentState, City) AS Location
FROM Incidents
-- Filter to only return missing values from IncidentState
WHERE IncidentState IS NULL

-- Imputing missing
-- values
-- (II)
-- What
-- if you want to replace missing values in one column
-- with another and want to check the replacement column to make sure it doesn't have any missing values? To do that you need to use the COALESCE statement.

-- SELECT Shape, City, COALESCE(Shape, City, 'Unknown') as NewShape
-- FROM Incidents
-- +----------------+-----------+-------------+
-- | Shape          |  City     |  NewShape   |
-- +----------------+-----------+-------------+
-- | NULL           | Orb       | Orb         |
-- | Triangle       | Toledo    | Triangle    |
-- | NULL           | NULL      | Unknown     | 
-- +----------------+-----------+-------------+

-- Replace missing values 
SELECT Country, COALESCE(Country, IncidentState, City) AS Location
FROM Incidents
WHERE Country IS NULL

-- Using
-- CASE statements
-- In this exercise, you will
-- use a
-- CASE statement to
-- create a new column which specifies whether the Country is USA or International.

SELECT Country,
    CASE WHEN Country = 'us'  THEN 'USA'
       ELSE 'International'
       END AS SourceCountry
FROM Incidents


-- Creating several groups
-- with CASE
-- In this exercise, you will write a CASE statement to group the values in the DurationSeconds into 5 groups based on the following
-- ranges:

-- DurationSeconds	SecondGroup
-- <= 120	1
-- > 120 and <= 600	2
-- > 600 and <= 1200	3
-- > 1201 and <= 5000	4
-- For all other values	5

-- Complete the syntax for cutting the duration into different cases
SELECT DurationSeconds,
    -- Start with the 2 TSQL keywords, and after the condition a TSQL word and a value
    CASE   WHEN (DurationSeconds <= 120) THEN 1
-- The pattern repeats with the same keyword and after the condition the same word and next value          
       WHEN (DurationSeconds > 120 AND DurationSeconds <= 600) THEN 2
-- Use the same syntax here             
       WHEN (DurationSeconds > 601 AND DurationSeconds <= 1200) THEN 3
-- Use the same syntax here               
       WHEN (DurationSeconds > 1201 AND DurationSeconds <= 5000) THEN 4
-- Specify a value      
       ELSE 5
       END AS SecondGroup
FROM Incidents

