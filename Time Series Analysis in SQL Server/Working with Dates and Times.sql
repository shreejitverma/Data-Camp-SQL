
-- -- Working
-- -- with Dates and Times
-- -- This chapter covers date and time functionality in SQL Server, including building dates from component parts, formatting dates for reporting, and working
-- -- with calendar tables.

-- Break
-- out a date into year, month, and day
-- SQL Server has a number of functions dedicated to working
-- with date types. We will first analyze three functions which
-- return integers representing the year, month, and day of month, respectively.

-- These functions can allow us to group dates together, letting us calculate running totals by year or month-over-month
-- comparisons of expenditures. We could also analyze sales by calendar day of the month to determine
-- if there is a strong monthly cycle.

DECLARE
	@SomeTime DATETIME2(7) = SYSUTCDATETIME();

-- Retrieve the year, month, and day
SELECT
    YEAR(@SomeTime) AS TheYear,
    MONTH(@SomeTime) AS TheMonth,
    DAY(@SomeTime) AS TheDay;

-- Break
-- a date and time into component parts
-- Although YEAR
-- (), MONTH
-- (), and DAY
-- () are helpful functions and are easy to remember, we often want to
-- break
-- out dates into different component parts such as the day of week, week of year, and second after the minute. This is where functions like DATEPART
-- () and DATENAME
-- () come into play.

-- Here we will
-- use the
-- night the Berlin Wall fell, November 9th, 1989.

DECLARE
	@BerlinWallFalls DATETIME2(7) = '1989-11-09 23:49:36.2294852';

-- Fill in each date part
SELECT
    DATEPART(YEAR, @BerlinWallFalls) AS TheYear,
    DATEPART(MONTH, @BerlinWallFalls) AS TheMonth,
    DATEPART(DAY, @BerlinWallFalls) AS TheDay,
    DATEPART(DayofYear, @BerlinWallFalls) AS TheDayOfYear,
    -- Day of week is WEEKDAY
    DATEPART(WEEKDAY, @BerlinWallFalls) AS TheDayOfWeek,
    DATEPART(WEEK, @BerlinWallFalls) AS TheWeek,
    DATEPART(SECOND, @BerlinWallFalls) AS TheSecond,
    DATEPART(NANOSECOND, @BerlinWallFalls) AS TheNanosecond;

-- Date math
-- and leap years
-- Some of you may have experience using R and here we note that leap year date math can be tricky
-- with R and the lubridate package. lubridate has two types of
-- functions:
-- duration and period.

-- lubridate::ymd
-- (20120229) - lubridate::dyears
-- (4) --> 2008-03-01, which is wrong.

-- lubridate::ymd
-- (20120229) - lubridate::dyears
-- (1) --> 2011-03-01, which is correct.

-- lubridate::ymd
-- (20120229) - lubridate::years
-- (4) --> 2008-02-29, which is correct.

-- lubridate::ymd
-- (20120229) - lubridate::years
-- (1) --> NA, which is unexpected behavior.

-- We can
-- use the
-- DATEADD
-- () and DATEDIFF
-- () functions to see how SQL Server deals
-- with leap years to see
-- if it has any of the same eccentricities.

DECLARE
	@LeapDay DATETIME2(7) = '2012-02-29 18:00:00';

-- Fill in the date parts and intervals as needed
SELECT
    DATEADD(DAY, -1, @LeapDay) AS PriorDay,
    DATEADD(DAY, 1, @LeapDay) AS NextDay,
    -- For leap years, we need to move 4 years, not just 1
    DATEADD(YEAR, -4, @LeapDay) AS PriorLeapYear,
    DATEADD(YEAR, 4, @LeapDay) AS NextLeapYear,
    DATEADD(YEAR, -1, @LeapDay) AS PriorYear;

--     Rounding dates
-- SQL
-- Server does not have an intuitive way to round down to the month, hour, or minute. You can, however, combine the DATEADD
-- () and DATEDIFF
-- () functions to perform this rounding.

-- To round the date 1914-08-16 down to the year, we would call DATEADD
-- (YEAR, DATEDIFF
-- (YEAR, 0, '1914-08-16'), 0). To round that date down to the month, we would call DATEADD
-- (MONTH, DATEDIFF
-- (MONTH, 0, '1914-08-16'), 0). This works for several other date parts as well.

-- DECLARE
-- 	@SomeTime DATETIME2(7) = '2018-06-14 16:29:36.2248991';

-- -- Fill in the appropriate functions and date parts
-- SELECT
--     DATEADD(DAY, DATEDIFF(DAY, 0, @SomeTime), 0) AS RoundedToDay,
--     DATEADD(HOUR, DATEDIFF(HOUR, 0, @SomeTime), 0) AS RoundedToHour,
--     DATEADD(MINUTE, DATEDIFF(MINUTE, 0, @SomeTime), 0) AS RoundedToMinute;

-- Formatting dates
-- with CAST
-- () and CONVERT
-- ()
-- We can
-- use the
-- CAST
-- () function to translate data between various data types, including between date/time types and string types. The CONVERT
-- () function takes three
-- parameters:
-- a data type, an input value, and an optional format code.

-- In this exercise, we will see how we can
-- use the
-- CAST
-- () and CONVERT
-- () functions to translate dates to strings for formatting by looking at the
-- (late) night the Chicago Cubs won the World Series in the US in 2016. In the process, we will see one difference between the DATETIME and the DATETIME2 data types for CAST
-- () and the added flexibility of CONVERT
-- ().
DECLARE
	@CubsWinWorldSeries DATETIME2(3) = '2016-11-03 00:30:29.245',
	@OlderDateType DATETIME = '2016-11-03 00:30:29.245';

SELECT
    -- Fill in the missing function calls
    CAST(@CubsWinWorldSeries AS DATE) AS CubsWinDateForm,
    CAST(@CubsWinWorldSeries AS NVARCHAR(30)) AS CubsWinStringForm,
    CAST(@OlderDateType AS DATE) AS OlderDateForm,
    CAST(@OlderDateType AS NVARCHAR(30)) AS OlderStringForm;

--     Formatting dates
-- with FORMAT
-- ()
-- The FORMAT
-- () function allows for additional flexibility in building dates. It takes in three
-- parameters:
-- the input value, the input format, and an optional culture
-- (such as en-US for US English or zh-cn for Simplified Chinese).

-- In the following exercises, we will investigate three separate methods for formatting dates using the FORMAT
-- () function against the day that Python 3 became generally
-- available:
-- December 3rd, 2008.

DECLARE
	@Python3ReleaseDate DATETIME2(3) = '2008-12-03 19:45:00.033';

SELECT
    -- Fill in the function call and format parameter
    FORMAT(@Python3ReleaseDate, 'd', 'en-US') AS US_d,
    FORMAT(@Python3ReleaseDate, 'd', 'de-DE') AS DE_d,
    -- Fill in the locale for Japan
    FORMAT(@Python3ReleaseDate, 'd', 'jp-JP') AS JP_d,
    FORMAT(@Python3ReleaseDate, 'd', 'zh-cn') AS CN_d;

--     Try out a calendar table
-- Calendar tables are also known in the warehousing world as date dimensions. A calendar table is a helpful utility table which you can use to perform date range calculations quickly and efficiently. This is especially true when dealing with fiscal years, which do not always align to a calendar year, or holidays which may not be on the same date every year.

-- In our example company, the fiscal year starts on July 1 of the current calendar year, so Fiscal Year 2019 started on July 1, 2019 and goes through June 30, 2020. All of this information is in a table called dbo.Calendar.

-- Find Tuesdays in December for calendar years 2008-2010
SELECT
    c.Date
FROM dbo.Calendar c
WHERE
	c.MonthName = 'December'
    AND c.DayName = 'Tuesday'
    AND c.CalendarYear BETWEEN 2008 AND 2010
ORDER BY
	c.Date;

--     Joining to a calendar table
-- In the prior exercise, we looked at a new table, dbo.Calendar. This table contains pre-calculated date information stretching from January 1st, 2000 through December 31st, 2049. Now we want to use this calendar table to filter another table, dbo.IncidentRollup.

-- The Incident Rollup table contains artificially-generated data relating to security incidents at a fictitious company.

-- You may recall from prerequisite courses how to join tables. Here's an example of joining to a calendar table:

-- SELECT
--     t.Column1,
--     t.Column2
-- FROM dbo.Table t
--     INNER JOIN dbo.Calendar c
--         ON t.Date = c.Date;

SELECT
    ir.IncidentDate,
    c.FiscalDayOfYear,
    c.FiscalWeekOfYear
FROM dbo.IncidentRollup ir
    INNER JOIN dbo.Calendar c
    ON ir.IncidentDate = c.Date
WHERE
    -- Incident type 3
	ir.IncidentTypeID = 3
    -- Fiscal year 2019
    AND c.FiscalYear = 2019
    -- Fiscal quarter 3
    AND c.FiscalQuarter = 3;


-- Build dates from parts
-- The DATEFROMPARTS() function allows us to turn a series of numbers representing date parts into a valid DATE data type. In this exercise, we will learn how to use DATEFROMPARTS() to build dates from components in a calendar table.

-- Although the calendar table already has dates in it, this helps us visualize circumstances in which the base table has integer date components but no date value, which might happen when importing data from flat files directly into a database.

-- Create dates from component parts on the calendar table
SELECT TOP(10)
    DATEFROMPARTS(c.CalendarYear, c.CalendarMonth, c.Day) AS CalendarDate
FROM dbo.Calendar c
WHERE
	c.CalendarYear = 2017
ORDER BY
	c.FiscalDayOfYear ASC;

--     Build dates
-- and times from parts
-- SQL Server has several functions for generating date and time combinations from parts. In this exercise, we will look at DATETIME2FROMPARTS
-- () and DATETIMEFROMPARTS
-- ().

-- Neil Armstrong and Buzz Aldrin landed the Apollo 11 Lunar Module--nicknamed The Eagle--on the moon on July 20th, 1969 at 20:17 UTC. They remained on the moon for approximately 21 1/2 hours, taking off on July 21st, 1969 at 18:54 UTC.

SELECT
    -- Mark the date and time the lunar module touched down
    -- Use 24-hour notation for hours, so e.g., 9 PM is 21
    DATETIME2FROMPARTS(1969, 07, 20, 20, 17, 00, 000, 0) AS TheEagleHasLanded,
    -- Mark the date and time the lunar module took back off
    -- Use 24-hour notation for hours, so e.g., 9 PM is 21
    DATETIMEFROMPARTS(1969, 07, 21, 18, 54, 00, 000) AS MoonDeparture;

--     Build dates and times with offsets from parts
-- The DATETIMEOFFSETFROMPARTS() function builds a DATETIMEOFFSET out of component values. It has the most input parameters of any date and time builder function.

-- On January 19th, 2038 at 03:14:08 UTC (that is, 3:14:08 AM), we will experience the Year 2038 (or Y2.038K) problem. This is the moment that 32-bit devices will reset back to the date 1900-01-01. This runs the risk of breaking every 32-bit device using POSIX time, which is the number of seconds elapsed since January 1, 1970 at midnight UTC.

SELECT
    -- Fill in the millisecond PRIOR TO chaos
    DATETIMEOFFSETFROMPARTS(2038, 01, 19, 03, 14, 07, 999, 0, 0, 3) AS LastMoment,
    -- Fill in the date and time when we will experience the Y2.038K problem
    -- Then convert to the Eastern Standard Time time zone
    DATETIMEOFFSETFROMPARTS(2038, 01,19, 03, 14, 08, 0, 0, 0, 3) AT TIME ZONE 'Eastern Standard Time' AS TimeForChaos;


    