-- Converting
-- to Dates and Times

-- Cast strings to dates
-- The CAST() function allows us to turn strings into date and time data types. In this example, we will review many of the formats CAST() can handle.

-- Review the data in the dbo.Dates table which has been pre-loaded for you. Then use the CAST() function to convert these dates twice: once into a DATE type and once into a DATETIME2(7) type. Because one of the dates includes data down to the nanosecond, we cannot convert to a DATETIME type or any DATETIME2 type with less precision.

-- NOTE: the CAST() function is language- and locale-specific, meaning that for a SQL Server instance configured for US English, it will translate 08/23/2008 as 2008-08-23 but it will fail on 23/08/2008, which a SQL Server with the French Canadian locale can handle.

SELECT
    d.DateText AS String,
    -- Cast as DATE
    CAST(d.DateText AS DATE) AS StringAsDate,
    -- Cast as DATETIME2(7)
    CAST(d.DateText AS DATETIME2(7)) AS StringAsDateTime2
FROM dbo.Dates d;

-- Convert strings to dates
-- The CONVERT() function behaves similarly to CAST(). When translating strings to dates, the two functions do exactly the same work under the covers. Although we used all three parameters for CONVERT() during a prior exercise in Chapter 1, we will only need two parameters here: the data type and input expression.

-- In this exercise, we will once again look at a table called dbo.Dates. This time around, we will get dates in from our German office. In order to handle German dates, we will need to use SET LANGUAGE to change the language in our current session to German. This affects date and time formats and system messages.

-- Try querying the dbo.Dates table first to see how things differ from the prior exercise.

SET LANGUAGE 'GERMAN'

SELECT
    d.DateText AS String,
    -- Convert to DATE
    CONVERT(DATE, d.DateText) AS StringAsDate,
    -- Convert to DATETIME2(7)
    CONVERT(DATETIME2(7), d.DateText) AS StringAsDateTime2
FROM dbo.Dates d;

-- Parse strings
-- to dates
-- Changing our language for data loading is not always feasible. Instead of using the
-- SET LANGUAGE syntax, we can
-- instead
-- use the
-- PARSE
-- () function to parse a string as a date type using a specific locale.

-- We will once again
-- use the
-- dbo.Dates table, this time parsing all of the dates as German using the de-de locale.

SELECT
    d.DateText AS String,
    -- Parse as DATE using German
    PARSE(d.DateText AS DATE USING 'de-de') AS StringAsDate,
    -- Parse as DATETIME2(7) using German
    PARSE(d.DateText AS DATETIME2(7) USING 'de-de') AS StringAsDateTime2
FROM dbo.Dates d;

-- Changing a date
-- 's offset
-- We can use the SWITCHOFFSET() function to change the time zone of a DATETIME, DATETIME2, or DATETIMEOFFSET typed date or a valid date string. SWITCHOFFSET() takes two parameters: the date or string as input and the time zone offset. It returns the time in that new time zone, so 3:00 AM Eastern Daylight Time will become 2:00 AM Central Daylight Time.

-- The 2016 Summer Olympics in Rio de Janeiro started at 11 PM UTC on August 8th, 2016. Starting with a string containing that date and time, we can see what time that was in other locales.

DECLARE
	@OlympicsUTC NVARCHAR(50) = N'2016-08-08 23:00:00';

SELECT
    -- Fill in the time zone for Brasilia, Brazil
    SWITCHOFFSET(@OlympicsUTC, '-03:00') AS BrasiliaTime,
    -- Fill in the time zone for Chicago, Illinois
    SWITCHOFFSET(@OlympicsUTC, '-05:00') AS ChicagoTime,
    -- Fill in the time zone for New Delhi, India
    SWITCHOFFSET(@OlympicsUTC, '+05:30') AS NewDelhiTime;

--     Converting to a date offset
-- In addition to SWITCHOFFSET(), we can use the TODATETIMEOFFSET() to turn an existing date into a date type with an offset. If our starting time is in UTC, we will need to correct for time zone and then append an offset. To correct for the time zone, we can add or subtract hours (and minutes) manually.

-- Closing ceremonies for the 2016 Summer Olympics in Rio de Janeiro began at 11 PM UTC on August 21st, 2016. Starting with a string containing that date and time, we can see what time that was in other locales. For the time in Phoenix, Arizona, you know that they observe Mountain Standard Time, which is UTC -7 year-round. The island chain of Tuvalu has its own time which is 12 hours ahead of UTC.

DECLARE
	@OlympicsClosingUTC DATETIME2(0) = '2016-08-21 23:00:00';

SELECT
    -- Fill in 7 hours back and a -07:00 offset
    TODATETIMEOFFSET(DATEADD(HOUR, -7, @OlympicsClosingUTC), '-07:00') AS PhoenixTime,
    -- Fill in 12 hours forward and a +12:00 offset
    TODATETIMEOFFSET(DATEADD(HOUR, +12, @OlympicsClosingUTC), '+12:00') AS TuvaluTime;


--     Try out type
-- -safe date functions
-- In this exercise, we will try out the TRY_CONVERT
-- (), TRY_CAST
-- (), and TRY_PARSE
-- ()
-- set
-- of functions. Each of these functions will safely parse string data and attempt to convert to another type, returning NULL
-- if the conversion fails. Conversion to, e.g., a date type can fail for several reasons.
-- If the input string is not a date, conversion will fail.
-- If the input type is in a potentially ambiguous format, conversion might fail. An example of this is the date 04/01/2019 which has a different meaning in the United States
-- (April 1, 2019) versus most European countries
-- (January 4th, 2019).

DECLARE
	@GoodDateINTL NVARCHAR(30) = '2019-03-01 18:23:27.920',
	@GoodDateDE NVARCHAR(30) = '13.4.2019',
	@GoodDateUS NVARCHAR(30) = '4/13/2019',
	@BadDate NVARCHAR(30) = N'SOME BAD DATE';

SELECT
    -- Fill in the correct data type based on our input
    TRY_CONVERT(DATETIME2(3), @GoodDateINTL) AS GoodDateINTL,
    -- Fill in the correct function
    TRY_CONVERT(DATE, @GoodDateDE) AS GoodDateDE,
    TRY_CONVERT(DATE, @GoodDateUS) AS GoodDateUS,
    -- Fill in the correct input parameter for BadDate
    TRY_CONVERT(DATETIME2(3), @BadDate) AS BadDate;

--     Convert imported data to dates with time zones
-- Now that we have seen the three type-safe conversion functions, we can begin to apply them against real data sets. In this scenario, we will parse data from the dbo.ImportedTime table. We used a different application to load data from this table and looked at it in a prior exercise. This time, we will retrieve data for all rows, not just the ones the importing application marked as valid.

WITH
    EventDates
    AS
    (
        SELECT
            -- Fill in the missing try-conversion function
            TRY_CONVERT(DATETIME2(3), it.EventDate) AT TIME ZONE it.TimeZone AS EventDateOffset,
            it.TimeZone
        FROM dbo.ImportedTime it
            INNER JOIN sys.time_zone_info tzi
            ON it.TimeZone = tzi.name
    )
SELECT
    -- Fill in the approppriate event date to convert
    CONVERT(NVARCHAR(50), ed.EventDateOffset) AS EventDateOffsetString,
    CONVERT(DATETIME2(0), ed.EventDateOffset) AS EventDateLocal,
    ed.TimeZone,
    -- Convert from a DATETIMEOFFSET to DATETIME at UTC
    CAST(ed.EventDateOffset AT TIME ZONE 'UTC' AS DATETIME2(0)) AS EventDateUTC,
    -- Convert from a DATETIMEOFFSET to DATETIME with time zone
    CAST(ed.EventDateOffset AT TIME ZONE 'US Eastern Standard Time'  AS DATETIME2(0)) AS EventDateUSEast
FROM EventDates ed;

-- Test type-safe conversion function performance
-- In the last two exercises, we looked at the TRY_CAST(), TRY_CONVERT(), and TRY_PARSE() functions. These functions do not all perform equally well. In this exercise, you will run a performance test against all of the dates in our calendar table.

-- To make it easier, we have pre-loaded dates in the dbo.Calendar table into a temp table called DateText, where there is a single NVARCHAR(50) column called DateText.

-- For the first three steps, the instructions will be the same: fill in missing values to complete the relevant function call. After doing that, observe the amount of time each operation takes and keep the results in mind. You will then summarize your results in step 4.

-- Try out how fast the TRY_CAST() function is
-- by try-casting each DateText value to DATE
DECLARE @StartTimeCast DATETIME2(7) = SYSUTCDATETIME();
SELECT TRY_CAST(DateText AS DATE) AS TestDate
FROM #DateText;
DECLARE @EndTimeCast DATETIME2(7) = SYSUTCDATETIME();

-- Determine how much time the conversion took by
-- calculating the date difference from @StartTimeCast to @EndTimeCast
SELECT
    DATEDIFF(MILLISECOND, @StartTimeCast, @EndTimeCast) AS ExecutionTimeCast;

    