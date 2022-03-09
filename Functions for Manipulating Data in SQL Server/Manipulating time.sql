
-- -- Manipulating time
-- Date
-- and time functions are an important topic for databases. In this chapter, you will get familiar
-- with the most common functions for date and time manipulation. You will learn how to retrieve the current date, only parts from a date, to assemble a date from pieces and to check
-- if an expression is a valid date or not.


-- Get the know the system date and time functions
-- The purpose of this exercise is for you to work with the system date and time functions and see how you can use them in SQL Server. Whether you just want to discover what day it is or you are performing complex time analysis, these functions will prove to be very helpful in many situations.

-- In this exercise, you will familiarize yourself with the most commonly used system date and time functions. These are:

-- Higher Precision

-- SYSDATETIME()
-- SYSUTCDATETIME()
-- SYSDATETIMEOFFSET()
-- Lower Precision

-- GETDATE()
-- GETUTCDATE()
-- CURRENT_TIMESTAMP
SELECT
    SYSDATETIME() AS CurrentDate;

--     Selecting parts
-- of the system's date and time
-- In this exercise, you will retrieve only parts of the system's date and time, focusing on only the date or only the time. You will
-- use the
-- same date and time functions, but you will
-- use CAST
-- () and CONVERT
-- () to transform the results to a different data type.

SELECT
    CONVERT(VARCHAR(24), SYSDATETIME(), 107) AS HighPrecision,
    CONVERT(VARCHAR(24), SYSDATETIME(), 102) AS LowPrecision;

--     Extracting parts
-- from a date
-- In this exercise, you will practice extracting date parts from a date, using SQL Server built-in functions. These functions are easy to apply and you can also
-- use them
-- in the WHERE clause, to restrict the results returned by the query.

-- You will start by querying the voters table and
-- create new columns by extracting the year, month, and day from the first_vote_date

SELECT
    first_name,
    last_name,
    -- Extract the year of the first vote
    YEAR(first_vote_date)  AS first_vote_year,
    -- Extract the month of the first vote
    MONTH(first_vote_date) AS first_vote_month,
    -- Extract the day of the first vote
    DAY(first_vote_date)   AS first_vote_day
FROM voters;

-- 

-- Generating descriptive date
-- parts
-- DATENAME
-- () is an interesting and easy to
-- use function. When you
-- create reports, for example, you may want to show parts of a date in a more understandable manner
-- (i.e. January instead of 1). This is when the DATENAME
-- () function proves its value. This function will
-- return a
-- string value
-- with a description of the date part you are interested in.

-- In this exercise, you will become familiar
-- with DATENAME(), by using it to retrieve different date parts. You will work
-- with the first_vote_date column from the voters table.

SELECT
    first_name,
    last_name,
    first_vote_date,
    -- Select the name of the month of the first vote
    DATENAME(MONTH, first_vote_date) AS first_vote_month
FROM voters;

-- Presenting parts
-- of a date
-- DATENAME
-- () and DATEPART
-- () are two similar functions. The difference between them is that
-- while the former understandably shows some date parts, as strings of characters, the latter returns only integer values.

-- In this exercise, you will
-- use both
-- of these functions to
-- select the month
-- and weekday of the first_vote_date in different forms.

SELECT
    first_name,
    last_name,
    -- Extract the month number of the first vote
    DATEPART(MONTH,first_vote_date) AS first_vote_month1,
    -- Extract the month name of the first vote
    DATENAME(MONTH,first_vote_date) AS first_vote_month2,
    -- Extract the weekday number of the first vote
    DATEPART(WEEKDAY,first_vote_date) AS first_vote_weekday1,
    -- Extract the weekday name of the first vote
    DATENAME(WEEKDAY,first_vote_date) AS first_vote_weekday2
FROM voters;

-- Creating a date
-- from parts
-- While most functions you worked
-- with so far extract parts from a date, DATEFROMPARTS
-- () does exactly the
-- opposite:
-- it creates a date from three numbers, representing the year, month and the day.

-- The syntax
-- is:
-- DATEFROMPARTS
-- (year, month, day)

-- You can also
-- use expressions
-- that
-- return numeric
-- values as parameters for this function, like
-- this:
-- DATEFROMPARTS
-- (YEAR
-- (date_expression), MONTH
-- (date_expression), 2)

-- In this exercise, you will
-- select information
-- from the voters
-- table, including the year and the month of the first_vote_date. Then, you will
-- create a new date column representing the first day in the month of the first vote.

SELECT
    first_name,
    last_name,
    -- Select the year of the first vote
    YEAR(first_vote_date) AS first_vote_year,
    -- Select the month of the first vote
    MONTH(first_vote_date) AS first_vote_month,
    -- Create a date as the start of the month of the first vote
    DATEFROMPARTS(YEAR(first_vote_date), MONTH(first_vote_date), 1) AS first_vote_starting_month
FROM voters;

-- Modifying the value
-- of a date
-- Adding different date parts to a date expression proves to be useful in many scenarios. You can calculate, for
-- example:

-- The delivery date of an order, by adding 3 days to the order date
-- The dates when a bonus is received, knowing that they are received every 3 months, starting
-- with a certain date.
-- In SQL Server, you can
-- use DATEADD
-- () for adding date parts to a date. In this exercise, you will get familiar
-- with this function.

SELECT
    first_name,
    birthdate,
    -- Add 18 years to the birthdate
    DATEADD(YEAR, 18, birthdate) AS eighteenth_birthday
FROM voters;

-- Calculating the difference between dates
-- DATEDIFF() is one of the most commonly-known functions for manipulating dates. It is used for retrieving the number of time units between two dates. This function is useful for calculating, for example:

-- How many years have passed since a specific event.
-- The age of a person at a point in time.
-- How many minutes it takes to process an order in a restaurant.
-- In almost all business scenarios you can find an example for which using this function proves to be useful.

-- In this exercise, you will use DATEDIFF() to perform calculations with the dates stored in the voters table.
SELECT
    first_name,
    birthdate,
    first_vote_date,
    -- Select the diff between the 18th birthday and first vote
    DATEDIFF(YEAR, DATEADD(YEAR, 18, birthdate), first_vote_date) AS adult_years_until_vote
FROM voters;


-- Changing the date format
-- Remember that SQL Server can interpret character strings that look like dates in a different way than you would expect. Depending on your settings, the string "29-04-2019" could be interpreted as the 29th of April, or an error can be thrown that the conversion to a date was not possible. In the first situation, SQL Server expects a day-month-year format, while in the second, it probably expects a month-day-year and the 29th month does not exist.

-- In this exercise, you will instruct SQL Server what kind of date format you want to use.

DECLARE @date1 NVARCHAR(20) = '2018-30-12';

-- Set the date format and check if the variable is a date
SET DATEFORMAT ydm;
SELECT ISDATE(@date1) AS result;

-- Changing the
-- default language
-- The language
-- set
-- in SQL Server can influence the way character strings are interpreted as dates. Changing the language automatically updates the date format. In this exercise, you will analyze the impact of the
-- SET LANGUAGE command
-- on some practical examples. You will
-- select between the
-- English, Croatian, and Dutch language, taking into account that they
-- use the
-- following
-- formats:

-- Language	Date format
-- English	mdy
-- Croatian	ymd
-- Dutch	dmy

DECLARE @date1 NVARCHAR(20) = '30.03.2019';

-- Set the correct language
SET LANGUAGE Dutch;
SELECT
    @date1 AS initial_date,
    -- Check that the date is valid
    ISDATE(@date1) AS is_valid,
    -- Select the name of the month
    DATENAME(MONTH,@date1) AS month_name;

--     Correctly applying different
-- date functions
-- It's time to combine your knowledge on date functions!

-- In this exercise, you are going to extract information about each voter and the first time they voted. In the voters table, the date of the first vote is stored in the first_vote_date column.

-- You will use several date functions, like: DATENAME(), DATEDIFF(), YEAR(), GETDATE().

SELECT
    first_name,
    last_name,
    birthdate,
    first_vote_date,
    -- Find out on which day of the week each participant voted 
    DATENAME(WEEKDAY,first_vote_date) AS first_vote_weekday
FROM voters;