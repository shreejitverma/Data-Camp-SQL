-- In this chapter, we will
-- learn techniques to aggregate data over time. We will briefly review aggregation functions and statistical aggregation functions. We will cover upsampling and downsampling of data. Finally, we will look at the grouping operators.
-- Summarize data over a time frame
-- There are several useful aggregate functions in SQL Server which we can use to summarize our data over time frames and gain insights. In the following example, you will look at a set of incident reports at a fictional company. They have already rolled up their incidents to the daily grain, giving us a number of incidents per type and day. We would like to investigate further and review incidents over a three-month period, from August 1 through October 31st, and gain basic insights through aggregation.

-- The key aggregate functions we will use are COUNT(), SUM(), MIN(), and MAX(). In the next exercise, we will look at some of the statistical aggregate functions.

-- Fill in the appropriate aggregate functions
SELECT
    it.IncidentType,
    COUNT(1) AS NumberOfRows,
    SUM(ir.NumberOfIncidents) AS TotalNumberOfIncidents,
    MIN(ir.NumberOfIncidents) AS MinNumberOfIncidents,
    MAX(ir.NumberOfIncidents) AS MaxNumberOfIncidents,
    MIN(ir.IncidentDate) As MinIncidentDate,
    MAX(ir.IncidentDate) AS MaxIncidentDate
FROM dbo.IncidentRollup ir
    INNER JOIN dbo.IncidentType it
    ON ir.IncidentTypeID = it.IncidentTypeID
WHERE
	ir.IncidentDate BETWEEN '2019-08-01' AND '2019-10-31'
GROUP BY
	it.IncidentType;
-- Calculating
-- distinct counts
-- The COUNT
-- () function has a variant which can be quite
-- useful:
-- COUNT
-- (DISTINCT). This distinct count function allows us to calculate the number of unique elements in a data
-- set
-- , so COUNT
-- (DISTINCT x.Y) will get the unique number of values for column Y on the table aliased as x.

-- In this example, we will
-- continue
-- to look at incident rollup data in the dbo.IncidentRollup table. Management would like to know how many unique incident types we have in our three-month data
-- set
-- as well as the number of days
-- with incidents. They already know the total number of incidents because you gave them that information in the last exercise.

-- Fill in the functions and columns
SELECT
    COUNT(DISTINCT ir.IncidentTypeID) AS NumberOfIncidentTypes,
    COUNT(DISTINCT ir.IncidentDate) AS NumberOfDaysWithIncidents
FROM dbo.IncidentRollup ir
WHERE
ir.IncidentDate BETWEEN '2019-08-01' AND '2019-10-31';

-- Calculating filtered aggregates
-- If we want to count the number of occurrences of an event given some filter criteria, we can take advantage of aggregate functions like SUM
-- (), MIN
-- (), and MAX
-- (), as well as CASE expressions. For example, SUM
-- (CASE WHEN ir.IncidentTypeID = 1 THEN 1 ELSE 0
-- END) will
-- return the
-- count of incidents associated
-- with incident type 1.
-- If you include one SUM
-- () statement for each incident type, you have pivoted the data
-- set by incident type ID.

-- In this scenario, management would like us to tell them, by incident type, how many "big-incident" days we have had versus "small-incident" days. Management defines a big-incident
-- day as having more than 5 occurrences of the same incident type on the same day, and a small-incident day has between 1 and 5.

SELECT
    it.IncidentType,
    -- Fill in the appropriate expression
    SUM(CASE WHEN ir.NumberOfIncidents > 5 THEN 1 ELSE 0 END) AS NumberOfBigIncidentDays,
    -- Number of incidents will always be at least 1, so
    -- no need to check the minimum value, just that it's
    -- less than or equal to 5
    SUM(CASE WHEN ir.NumberOfIncidents <= 5 THEN 1 ELSE 0 END) AS NumberOfSmallIncidentDays
FROM dbo.IncidentRollup ir
    INNER JOIN dbo.IncidentType it
    ON ir.IncidentTypeID = it.IncidentTypeID
WHERE
	ir.IncidentDate BETWEEN '2019-08-01' AND '2019-10-31'
GROUP BY
it.IncidentType;


-- Working with statistical aggregate functions
-- SQL Server offers several aggregate functions for statistical purpose. The AVG() function generates the mean of a sample. STDEV() and STDEVP() give us the standard deviation of a sample and of a population, respectively. VAR() and VARP() give us the variance of a sample and a population, respectively. These are in addition to the aggregate functions we learned about in the previous exercise, including SUM(), COUNT(), MIN(), and MAX().

-- In this exercise, we will look once more at incident rollup and incident type data, this time for quarter 2 of calendar year 2020. We would like to get an idea of how much spread there is in incident occurrence--that is, if we see a consistent number of incidents on a daily basis or if we see wider swings.

-- Fill in the missing function names
SELECT
    it.IncidentType,
    AVG(ir.NumberOfIncidents) AS MeanNumberOfIncidents,
    AVG(CAST(ir.NumberOfIncidents AS DECIMAL(4,2))) AS MeanNumberOfIncidents,
    STDEV(ir.NumberOfIncidents) AS NumberOfIncidentsStandardDeviation,
    VAR(ir.NumberOfIncidents) AS NumberOfIncidentsVariance,
    COUNT(1) AS NumberOfRows
FROM dbo.IncidentRollup ir
    INNER JOIN dbo.IncidentType it
    ON ir.IncidentTypeID = it.IncidentTypeID
    INNER JOIN dbo.Calendar c
    ON ir.IncidentDate = c.Date
WHERE
	c.CalendarQuarter = 2
    AND c.CalendarYear = 2020
GROUP BY
it.IncidentType;

-- Calculating median
-- in SQL Server
-- There is no MEDIAN
-- () function in SQL Server. The closest we have is PERCENTILE_CONT
-- (), which finds the value at the nth percentile across a data
-- set.

-- We
-- would like to figure out how far the median differs from the mean by incident type in our incident rollup
-- set. To do so, we can compare the AVG
-- () function from the prior exercise to PERCENTILE_CONT
-- (). These are window functions, which we will cover in more detail in chapter 4. For now, know that PERCENTILE_CONT
-- () takes a parameter, the percentile
-- (a decimal ranging from from 0. to 1.). The percentile must be within an ordered group inside the WITHIN GROUP clause and OVER a certain range
-- if you need to partition the data. In the WITHIN GROUP section, we need to order by the column whose 50th percentile we want.

SELECT DISTINCT
    it.IncidentType,
    AVG(CAST(ir.NumberOfIncidents AS DECIMAL(4,2)))
	    OVER(PARTITION BY it.IncidentType) AS MeanNumberOfIncidents,
    --- Fill in the missing value
    PERCENTILE_CONT(0.5)
    	-- Inside our group, order by number of incidents DESC
    	WITHIN GROUP (ORDER BY ir.NumberOfIncidents DESC)
        -- Do this for each IncidentType value
        OVER (PARTITION BY it.IncidentType) AS MedianNumberOfIncidents,
    COUNT(1) OVER (PARTITION BY it.IncidentType) AS NumberOfRows
FROM dbo.IncidentRollup ir
    INNER JOIN dbo.IncidentType it
    ON ir.IncidentTypeID = it.IncidentTypeID
    INNER JOIN dbo.Calendar c
    ON ir.IncidentDate = c.Date
WHERE
	c.CalendarQuarter = 2
    AND c.CalendarYear = 2020;


--     Downsample to a daily grain
-- Rolling up data to a higher grain is a common analytical task. We may have a set of data with specific time stamps and a need to observe aggregated results. In SQL Server, there are several techniques available depending upon your desired grain.

-- For these exercises, we will look at a fictional day spa. Spa management sent out coupons to potential new customers for the period June 16th through 20th of 2020 and would like to see if this campaign spurred on new visits.

-- In this exercise, we will look at one of the simplest downsampling techniques: converting a DATETIME2 or DATETIME data type to a data type with just a date and no time component: the DATE type

SELECT
    -- Downsample to a daily grain
    -- Cast CustomerVisitStart as a date
    CAST(dsv.CustomerVisitStart AS DATE) AS Day,
    SUM(dsv.AmenityUseInMinutes) AS AmenityUseInMinutes,
    COUNT(1) AS NumberOfAttendees
FROM dbo.DaySpaVisit dsv
WHERE
	dsv.CustomerVisitStart >= '2020-06-11'
    AND dsv.CustomerVisitStart < '2020-06-23'
GROUP BY
	-- When we use aggregation functions like SUM or COUNT,
    -- we need to GROUP BY the non-aggregated columns
	CAST(dsv.CustomerVisitStart AS DATE)
ORDER BY
	Day;

--     Downsample to a weekly grain
-- Management would like to see how well people have utilized the spa in 2020. They would like to see results by week, reviewing the total number of minutes of amenity usage, the number of attendees, and the customer with the largest customer ID that week to see if new customers are coming in.

-- We can use functions in SQL Server to downsample to a fixed grain like this. One such function is DATEPART().
SELECT
    -- Downsample to a weekly grain
    ___(___, dsv.CustomerVisitStart) AS Week,
    SUM(dsv.AmenityUseInMinutes) AS AmenityUseInMinutes,
    -- Find the customer with the largest customer ID for that week
    ___(dsv.___) AS HighestCustomerID,
    COUNT(1) AS NumberOfAttendees
FROM dbo.DaySpaVisit dsv
WHERE
	dsv.CustomerVisitStart >= '2020-01-01'
    AND dsv.CustomerVisitStart < '2021-01-01'
GROUP BY
	-- When we use aggregation functions like SUM or COUNT,
    -- we need to GROUP BY the non-aggregated columns
	___(___, dsv.CustomerVisitStart)
ORDER BY
	Week;

--     Downsample using a calendar table
-- Management liked the weekly report but they wanted to see every week in 2020, not just the weeks with amenity usage. We can use a calendar table to solve this problem: the calendar table includes all of the weeks, so we can join it to the dbo.DaySpaVisit table to find our answers.

-- Management would also like to see the first day of each calendar week, as that provides important context to report viewers.

SELECT
    -- Determine the week of the calendar year
    c.___,
    -- Determine the earliest DATE in this group
    MIN(c.___) AS FirstDateOfWeek,
    ISNULL(SUM(dsv.AmenityUseInMinutes), 0) AS AmenityUseInMinutes,
    ISNULL(MAX(dsv.CustomerID), 0) AS HighestCustomerID,
    COUNT(dsv.CustomerID) AS NumberOfAttendees
FROM dbo.Calendar c
    LEFT OUTER JOIN dbo.DaySpaVisit dsv
    -- Connect dbo.Calendar with dbo.DaySpaVisit
    -- To join on CustomerVisitStart, we need to turn 
    -- it into a DATE type
    ON c.Date = CAST(dsv.___ AS ___)
WHERE
	c.CalendarYear = 2020
GROUP BY
	-- When we use aggregation functions like SUM or COUNT,
    -- we need to GROUP BY the non-aggregated columns
	c.___
ORDER BY
	c.CalendarWeekOfYear;

--     Generate a summary
-- with ROLLUP
-- The ROLLUP operator works best when your non-measure attributes are hierarchical. Otherwise, you may
-- end up weird aggregation levels which don't make intuitive sense.

-- In this scenario, we wish to aggregate the total number of security incidents in the IncidentRollup table. Management would like to see data aggregated by the combination of calendar year, calendar quarter, and calendar month. In addition, they would also like to see separate aggregate lines for calendar year plus calendar quarter, as well as separate aggregate lines for each calendar year. Finally, they would like one more line for the grand total. We can do all of this in one operation.

SELECT
    c.CalendarYear,
    c.CalendarQuarterName,
    c.CalendarMonth,
    -- Include the sum of incidents by day over each range
    SUM(ir.NumberOfIncidents) AS NumberOfIncidents
FROM dbo.IncidentRollup ir
    INNER JOIN dbo.Calendar c
    ON ir.IncidentDate = c.Date
WHERE
	ir.IncidentTypeID = 2
GROUP BY
	-- GROUP BY needs to include all non-aggregated columns
	c.CalendarYear,
	c.CalendarQuarterName,
	c.CalendarMonth
-- Fill in your grouping operator
WITH ROLLUP
ORDER BY
	c.CalendarYear,
	c.CalendarQuarterName,
	c.CalendarMonth;

--     View all aggregations with CUBE
-- The CUBE operator provides a cross aggregation of all combinations and can be a huge number of rows. This operator works best with non-hierarchical data where you are interested in independent aggregations as well as the combined aggregations.

-- In this scenario, we wish to find the total number of security incidents in the IncidentRollup table but will not follow a proper hierarchy. Instead, we will focus on aggregating several unrelated attributes.

SELECT
    -- Use the ORDER BY clause as a guide for these columns
    -- Don't forget that comma after the third column if you
    -- copy from the ORDER BY clause!
    ir.IncidentTypeID,
    c.CalendarQuarterName,
    c.WeekOfMonth,
    SUM(ir.NumberOfIncidents) AS NumberOfIncidents
FROM dbo.IncidentRollup ir
    INNER JOIN dbo.Calendar c
    ON ir.IncidentDate = c.Date
WHERE
	ir.IncidentTypeID IN (3, 4)
GROUP BY
	-- GROUP BY should include all non-aggregated columns
	ir.IncidentTypeID,
	c.CalendarQuarterName,
	c.WeekOfMonth
-- Fill in your grouping operator
WITH CUBE
ORDER BY
	ir.IncidentTypeID,
	c.CalendarQuarterName,
	c.WeekOfMonth;

--     Generate custom groupings with GROUPING SETS
-- The GROUPING SETS operator allows us to define the specific aggregation levels we desire.

-- In this scenario, management would like to see something similar to a ROLLUP but without quite as much information. Instead of showing every level of aggregation in the hierarchy, management would like to see three levels: grand totals; by year; and by year, quarter, and month.

SELECT
    c.CalendarYear,
    c.CalendarQuarterName,
    c.CalendarMonth,
    SUM(ir.NumberOfIncidents) AS NumberOfIncidents
FROM dbo.IncidentRollup ir
    INNER JOIN dbo.Calendar c
    ON ir.IncidentDate = c.Date
WHERE
	ir.IncidentTypeID = 2
-- Fill in your grouping operator here
GROUP BY GROUPING SETS
(
  	-- Group in hierarchical order:  calendar year,
    -- calendar quarter name, calendar month
	(c.CalendarYear, c.CalendarQuarterName, c.CalendarMonth),
  	-- Group by calendar year
	(c.CalendarYear),
    -- This remains blank; it gives us the grand total
	()
)
ORDER BY
	c.CalendarYear,
	c.CalendarQuarterName,
	c.CalendarMonth;

--     Combine multiple aggregations in one query
-- In the last three exercises, we walked through the ROLLUP, CUBE, and GROUPING SETS grouping operators. Of these three, GROUPING SETS is the most customizable, allowing you to build out exactly the levels of aggregation you want. GROUPING SETS makes no assumptions about hierarchy (unlike ROLLUP) and can remain manageable with a good number of columns (unlike CUBE).

-- In this exercise, we want to test several conjectures with our data:

-- We have seen fewer incidents per month since introducing training in November of 2019.
-- More incidents occur on Tuesday than on other weekdays.
-- More incidents occur on weekends than weekdays.

SELECT
    c.CalendarYear,
    c.CalendarMonth,
    c.DayOfWeek,
    c.IsWeekend,
    SUM(ir.NumberOfIncidents) AS NumberOfIncidents
FROM dbo.IncidentRollup ir
    INNER JOIN dbo.Calendar c
    ON ir.IncidentDate = c.Date
GROUP BY GROUPING SETS
(
    -- Each non-aggregated column from above should appear once
  	-- Calendar year and month
	(c.CalendarYear, c.CalendarMonth),
  	-- Day of week
	(c.DayOfWeek),
  	-- Is weekend or not
	(c.IsWeekend),
    -- This remains empty; it gives us the grand total
	()
)
ORDER BY
	c.CalendarYear,
	c.CalendarMonth,
	c.DayOfWeek,
	c.IsWeekend;


    