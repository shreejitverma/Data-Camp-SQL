-- In this chapter, you will
-- create variables and write
-- while loops to process data. You will also write complex queries by using derived tables and common table expressions.

-- Creating
-- and using variables
-- In T-SQL, to
-- create a variable you
-- use the
-- DECLARE statement. The variables must have an at sign
-- (@) as their first character. Like most things in T-SQL, variables are not case sensitive. To assign a value to a variable, you can either
-- use the
-- keyword
-- SET
-- or a
-- SELECT statement, then the
-- variable name followed by an equal sign and a value.

-- Declare the variable (a SQL Command, the var name, the datatype)
DECLARE @counter INT

-- Set the counter to 20
SET @counter = 20

-- Select the counter
SELECT @counter

-- Creating a
-- WHILE loop
-- In this exercise, you will
-- use the
-- variable you created in the previous exercise you write a
-- WHILE loop. Recall that
-- structure:

-- WHILE some_condition 

-- BEGIN
--     -- Perform some operation here
--     END

DECLARE @counter INT
SET @counter = 20

-- Create a loop
WHILE @counter < 30

-- Loop code starting point
BEGIN
    SELECT @counter = @counter + 1
-- Loop finish
END

-- Check the value of the variable
SELECT @counter

-- Queries
-- with derived tables
-- (I)
-- The focus of this lesson is derived tables. You can
-- use derived
-- tables when you want to
-- break
-- down a complex query into smaller steps. A derived table is a query which is used in the place of a table. Derived tables are a great solution
-- if you want to
-- create intermediate calculations that need to be used in a larger query.

-- In this exercise, you will calculate the maximum value of the blood glucose level for each record by age.

SELECT a.RecordId, a.Age, a.BloodGlucoseRandom,
    -- Select maximum glucose value (use colname from derived table)    
    b.MaxGlucose
FROM Kidney a
    -- Join to derived table
    JOIN (SELECT Age, MAX(BloodGlucoseRandom) AS MaxGlucose
    FROM Kidney
    GROUP BY Age) b
    -- Join on Age
    ON a.Age =b.Age

--     Queries
-- with derived tables
-- (II)
-- In this exercise, you will
-- create a derived table to
-- return all patient records
-- with the highest BloodPressure at their Age level.```

-- ```

SELECT *
FROM Kidney a
    -- Create derived table: select age, max blood pressure from kidney grouped by age
    JOIN (SELECT Age, MAX(BloodPressure) AS MaxBloodPressure
    FROM Kidney
    GROUP BY Age) b
    -- JOIN on BloodPressure equal to MaxBloodPressure
    ON a.BloodPressure = b.MaxBloodPressure
        -- Join on Age
        AND a.Age = b.Age

-- Creating CTEs
-- (I)
-- A Common table expression or CTE is used to
-- create a table that can later be used
-- with a query. To
-- create a CTE, you will always
-- use the
-- WITH keyword followed by the CTE name and the name of the columns the CTE contains. The CTE will also include the definition of the table enclosed within the AS
-- ().

-- In this exercise, you will
-- use a
-- CTE to
-- return all the ages
-- with the maximum BloodGlucoseRandom in the table.

-- Specify the keyowrds to create the CTE
WITH
    BloodGlucoseRandom (MaxGlucose)
    AS
    (
        SELECT MAX(BloodGlucoseRandom) AS MaxGlucose
        FROM Kidney
    )

SELECT a.Age, b.MaxGlucose
FROM Kidney a
    -- Join the CTE on blood glucose equal to max blood glucose
    JOIN BloodGlucoseRandom b
    ON a.BloodGlucoseRandom = b.MaxGlucose

--     Creating CTEs
-- (II)
-- In this exercise, you will
-- use a
-- CTE to
-- return all the information regarding the patient
-- (s)
-- with the maximum BloodPressure.

-- Create the CTE
-- WITH
--     BloodPressure(MaxBloodPressure)
--     AS
--     (
--         SELECT MAX(BloodPressure) AS MaxBloodPressure
--         FROM Kidney
--     )

-- SELECT *
-- FROM Kidney a
--     -- Join the CTE  
--     JOIN BloodPressure b
--     ON a.BloodPressure = b.MaxBloodPressure